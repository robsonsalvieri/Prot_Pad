#include "PROTHEUS.CH"

CLASS T450ITestSuite FROM FWDefaultTestSuite

	DATA aParam

	METHOD T450ITestSuite() CONSTRUCTOR
	METHOD SetUpSuite()
	METHOD TearDownSuite()

ENDCLASS

METHOD T450ITestSuite() CLASS T450ITestSuite

	_Super:FWDefaultTestSuite()

	Self:AddTestSuite(T450ITestGroup():T450ITestGroup() )

Return

METHOD SetUpSuite() CLASS T450ITestSuite
    Local oHelper		:= FWTestHelper():New()

    If Select("SX2") == 0
        RPCSetEnv("99", "01")
        Conout("Setup realizado com sucesso!")
    EndIf

    If DUL->(DbSeek(XFilial("DUL") + "TESTE"))
        RecLock("DUL", .F.)
        DUL->(DBDelete())
        DUL->(MsUnlock())
    EndIf

    If DUL->(DbSeek(XFilial("DUL") + "TESTE2"))
        RecLock("DUL", .F.)
        DUL->(DBDelete())
        DUL->(MsUnlock())
    EndIf


Return oHelper

METHOD TearDownSuite() CLASS T450ITestSuite
    Local oHelper		:= FWTestHelper():New()

    oHelper:UTRestParam(::aParam)
    If DUL->(DbSeek(XFilial("DUL") + "TESTE"))
        RecLock("DUL", .F.)
        DUL->(DBDelete())
        DUL->(MsUnlock())
    EndIf

    If DUL->(DbSeek(XFilial("DUL") + "TESTE2"))
        RecLock("DUL", .F.)
        DUL->(DBDelete())
        DUL->(MsUnlock())
    EndIf

Return oHelper
