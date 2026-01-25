#include "PROTHEUS.CH"

CLASS T450ITestGroup FROM FWDefaultTestSuite
	METHOD T450ITestGroup() CONSTRUCTOR

ENDCLASS

METHOD T450ITestGroup() CLASS T450ITestGroup
	_Super:FWDefaultTestSuite()
	Self:AddTestCase( T450ITestCase():T450ITestCase() )

Return