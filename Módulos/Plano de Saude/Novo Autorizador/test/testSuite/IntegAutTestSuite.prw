#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegAutTestSuite

@author karine.limp
@since 28/03/2018
@version 1.0
@see FWDefaultTestSuit , FWDefaultTestCase
/*/
//-------------------------------------------------------------------
CLASS IntegAutTestSuite FROM FWDefaultTestSuite

	DATA aParam
	
	Method IntegAutTestSuite() Constructor
	Method SetUpSuite()
	Method TearDownSuite()
	
EndCLass

//-----------------------------------------------------------------
/*/{Protheus.doc} IntegAutTestSuite
 Instancia os casos de teste de Integração com o autorizador
 
@author karine.limp
@since 28/03/2018
@version 1.0
/*/
//-----------------------------------------------------------------
Method IntegAutTestSuite() Class IntegAutTestSuite

	_Super:FWDefaultTestSuite()

	self:AddTestSuite(IntegAutTestGroup():IntegAutTestGroup() )
	
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetUpSuite
 Prepara o ambiente para execucao dos casos de teste de Integração com o autorizador
 
@author karine.limp
@since 28/03/2018
@version 1.0
/*/
//-----------------------------------------------------------------
METHOD SetUpSuite() CLASS IntegAutTestSuite
    
    Local oHelper := FwTestHelper():New()
    
    oHelper:UTOpenFilial("T1","M SP 01 ",,,"admin","")
    oHelper:Activate()

Return oHelper

//-----------------------------------------------------------------
/*/{Protheus.doc} TearDownSuite
 Finaliza o ambiente apos a execucao dos casos de teste de Integração com o autorizador
 
@author karine.limp
@since 28/03/2018
@version 1.0
/*/
//-----------------------------------------------------------------
METHOD TearDownSuite() CLASS IntegAutTestSuite
    
    Local oHelper := FwTestHelper():New()

    //-- Recupera parametro padrao do Sistema
    oHelper:UTRestParam(/*::aParam*/)
    oHelper:UTCloseFilial()

Return oHelper
