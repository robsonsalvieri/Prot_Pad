#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegAutTestGroup

@author karine.limp
@since 28/03/2018
@version 1.0
@see FWDefaultTestSuit , FWDefaultTestCase
/*/
//-------------------------------------------------------------------
Class IntegAutTestGroup From FWDefaultTestSuite

	Method IntegAutTestGroup() Constructor
	
EndClass

//-----------------------------------------------------------------
/*/{Protheus.doc} IntegAutTestGroup
 Instancia os casos de teste de Integração com o autorizador
 
@author karine.limp
@since 28/03/2018
@version 1.0
/*/
//-----------------------------------------------------------------
Method IntegAutTestGroup() Class IntegAutTestGroup
	_Super:FWDefaultTestSuite()

	Self:AddTestCase(PLSAutExameTestCase():PLSAutExameTestCase())
	Self:AddTestCase(PlsAutConsultaTestCase():PlsAutConsultaTestCase())
	Self:AddTestCase(PlsAutExecTestCase():PlsAutExecTestCase())
			
Return
