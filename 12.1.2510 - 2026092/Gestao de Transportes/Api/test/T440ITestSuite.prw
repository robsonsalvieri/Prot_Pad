#include "PROTHEUS.CH"

CLASS T440ITestSuite FROM FWDefaultTestSuite

	DATA aParam

	METHOD T440ITestSuite() CONSTRUCTOR
	METHOD SetUpSuite()
	METHOD TearDownSuite()

ENDCLASS

METHOD T440ITestSuite() CLASS T440ITestSuite

	_Super:FWDefaultTestSuite()

	Self:AddTestSuite(T440ITestGroup():T440ITestGroup() )

Return

METHOD SetUpSuite() CLASS T440ITestSuite
    Local oHelper		:= FWTestHelper():New()

    If Select("SX2") == 0
        RPCSetEnv("99", "01")
        Conout("Setup realizado com sucesso!")
    EndIf

    If DUE->(DbSeek(XFilial("DUE") + "TESTE"))
        DVJ->(MsSeek(cSeek := xFilial('DVJ')+DUE->DUE_CODSOL))

        While DVJ->( ! Eof() .And. DVJ->DVJ_FILIAL+DVJ->DVJ_CODSOL == cSeek )
            RecLock("DVJ", .F.)
            DVJ->(DBDelete())
            DVJ->(MsUnlock())
            DVJ->(DbSkip())
        EndDo
        RecLock("DUE", .F.)
        DUE->(DBDelete())
        DUE->(MsUnlock())

    EndIf

    If DUE->(DbSeek(XFilial("DUE") + "TESTE2"))
        DVJ->(MsSeek(cSeek := xFilial('DVJ')+DUE->DUE_CODSOL))

        While DVJ->( ! Eof() .And. DVJ->DVJ_FILIAL+DVJ->DVJ_CODSOL == cSeek )
            RecLock("DVJ", .F.)
            DVJ->(DBDelete())
            DVJ->(MsUnlock())
            DVJ->(DbSkip())
        EndDo

        RecLock("DUE", .F.)
        DUE->(DBDelete())
        DUE->(MsUnlock())

    EndIf

Return oHelper

METHOD TearDownSuite() CLASS T440ITestSuite
    Local oHelper		:= FWTestHelper():New()

    If DUE->(DbSeek(XFilial("DUE") + "TESTE"))
        DVJ->(MsSeek(cSeek := xFilial('DVJ')+DUE->DUE_CODSOL))

        While DVJ->( ! Eof() .And. DVJ->DVJ_FILIAL+DVJ->DVJ_CODSOL == cSeek )
            RecLock("DVJ", .F.)
            DVJ->(DBDelete())
            DVJ->(MsUnlock())
            DVJ->(DbSkip())
        EndDo
        RecLock("DUE", .F.)
        DUE->(DBDelete())
        DUE->(MsUnlock())

    EndIf

    If DUE->(DbSeek(XFilial("DUE") + "TESTE2"))
        DVJ->(MsSeek(cSeek := xFilial('DVJ')+DUE->DUE_CODSOL))

        While DVJ->( ! Eof() .And. DVJ->DVJ_FILIAL+DVJ->DVJ_CODSOL == cSeek )
            RecLock("DVJ", .F.)
            DVJ->(DBDelete())
            DVJ->(MsUnlock())
            DVJ->(DbSkip())
        EndDo

        RecLock("DUE", .F.)
        DUE->(DBDelete())
        DUE->(MsUnlock())

    EndIf

Return oHelper
