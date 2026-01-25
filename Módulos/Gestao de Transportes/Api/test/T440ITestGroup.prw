#include "PROTHEUS.CH"

CLASS T440ITestGroup FROM FWDefaultTestSuite
	METHOD T440ITestGroup() CONSTRUCTOR

ENDCLASS

METHOD T440ITestGroup() CLASS T440ITestGroup
	_Super:FWDefaultTestSuite()
	Self:AddTestCase( T440ITestCase():T440ITestCase() )

Return