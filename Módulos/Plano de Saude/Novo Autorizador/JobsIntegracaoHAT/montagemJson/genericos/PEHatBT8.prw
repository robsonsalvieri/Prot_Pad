#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBT8
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBT8 From PEHatGener

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
Method New() Class PEHatBT8

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'companyId','contractNumber','contractVersion', ;
				        'subContractNumber','subContractVersion','healthProductCode', ;
                        'healthProductVersion','procedureTableCode','procedureCode'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBT8

	oObj['healthInsurerId']        := self:cCodOpe
	oObj['ansRegistry']            := self:cSusep 
    oObj['coverageProcedureLevel'] := 'empresa'
    
Return