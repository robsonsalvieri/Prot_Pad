#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "PLSMGER.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBEA
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBEA From PEHatGener

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
Method New() Class PEHatBEA

    Default cPedido := ''
    
    _Super:New()
    self:_StSuccess := '3'
    self:_StError   := '5'
    self:cNodePrinc := 'guiasCancelamento'
    self:aNodeKey   := {'motivoCancelamento','idOnHealthInsurer'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBEA
Return