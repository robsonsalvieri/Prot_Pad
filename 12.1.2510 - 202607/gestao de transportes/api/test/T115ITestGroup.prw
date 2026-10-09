#include "PROTHEUS.CH"

CLASS T115ITestGroup FROM FWDefaultTestSuite
	METHOD T115ITestGroup() CONSTRUCTOR

ENDCLASS

METHOD T115ITestGroup() CLASS T115ITestGroup
	_Super:FWDefaultTestSuite()
	Self:AddTestCase( T115ITestCase():T115ITestCase() )

Return