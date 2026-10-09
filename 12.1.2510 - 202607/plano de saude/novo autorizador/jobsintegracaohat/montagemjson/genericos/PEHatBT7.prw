#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBT7
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBT7 From PEHatGener

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
Method New() Class PEHatBT7

    Default cPedido := ''
    
    _Super:New()
    self:nInd       := 1
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'coverageGroupCode','companyId','contractNumber','contractVersion', ;
				        'subcontractNumber','subcontractVersion','healthProductCode','healthProductVersion'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBT7

	oObj['healthInsurerId']    := self:cCodOpe
	oObj['ansRegistry']        := self:cSusep 
    oObj['coverageGroupLevel'] := 'empresa'
    
Return