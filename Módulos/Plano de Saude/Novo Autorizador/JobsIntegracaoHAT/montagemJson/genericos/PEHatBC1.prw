#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBC1
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBC1 From PEHatGener

	Method New()
    
EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatBC1

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'healthProviderCode'}

Return self