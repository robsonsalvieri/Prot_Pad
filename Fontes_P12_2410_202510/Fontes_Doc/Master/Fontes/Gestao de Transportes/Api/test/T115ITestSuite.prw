#include "PROTHEUS.CH"

CLASS T115ITestSuite FROM FWDefaultTestSuite

	DATA aParam

	METHOD T115ITestSuite() CONSTRUCTOR
	METHOD SetUpSuite()
	METHOD TearDownSuite()

ENDCLASS

METHOD T115ITestSuite() CLASS T115ITestSuite

	_Super:FWDefaultTestSuite()

	Self:AddTestSuite(T115ITestGroup():T115ITestGroup() )

Return

METHOD SetUpSuite() CLASS T115ITestSuite
    Local oHelper		:= FWTestHelper():New()

    // oHelper:UTOpenFilial("99","01", "SIGATMS")
    // oHelper:UTOpenFilial("99","01")

    // oHelper:Activate()

    RPCSetEnv("99", "01")
    Conout("Setup realizado com sucesso!")

    If DUY->(DbSeek(XFilial("DUY") + "TESTE"))
        RecLock("DUY", .F.)
        DUY->(DBDelete())
        DUY->(MsUnlock())
    EndIf

    If DUY->(DbSeek(XFilial("DUY") + "TESTE2"))
        RecLock("DUY", .F.)
        DUY->(DBDelete())
        DUY->(MsUnlock())
    EndIf


Return oHelper

METHOD TearDownSuite() CLASS T115ITestSuite
    Local oHelper		:= FWTestHelper():New()

    oHelper:UTRestParam(::aParam)
    // oHelper:UTCloseFilial()
    If DUY->(DbSeek(XFilial("DUY") + "TESTE"))
        RecLock("DUY", .F.)
        DUY->(DBDelete())
        DUY->(MsUnlock())
    EndIf

    If DUY->(DbSeek(XFilial("DUY") + "TESTE2"))
        RecLock("DUY", .F.)
        DUY->(DBDelete())
        DUY->(MsUnlock())
    EndIf

    RpcClearEnv()
Return oHelper
