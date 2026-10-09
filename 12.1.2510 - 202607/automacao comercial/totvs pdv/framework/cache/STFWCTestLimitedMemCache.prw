#INCLUDE "PROTHEUS.CH"

Class STFWCTestLimitedMemCache From FWDefaultTestCase
	Method STFWCTestLimitedMemCache()	
	Method TestPut()
	Method TestPutWithExpired()
	Method TestUnlimited()
EndClass

Method STFWCTestLimitedMemCache() Class STFWCTestLimitedMemCache
	_Super:FWDefaultTestCase()
	Self:AddTestMethod("TestPut")
	Self:AddTestMethod("TestPutWithExpired")
	Self:AddTestMethod("TestUnlimited")
Return

Method TestPut() Class STFWCTestLimitedMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCLimitedMemCache():STFWCLimitedMemCache(10)
	
	oResult:AssertTrue(oMemCache:Put("KEY1", 1), "Não incluiu o KEY1, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY2", 1), "Não incluiu o KEY2, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY3", 1), "Não incluiu o KEY3, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY4", 1), "Não incluiu o KEY4, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY5", 1), "Não incluiu o KEY5, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY6", 1), "Não incluiu o KEY6, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY7", 1), "Não incluiu o KEY7, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY8", 1), "Não incluiu o KEY8, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY9", 1), "Não incluiu o KEY9, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY10", 1), "Não incluiu o KEY10, mas deveria.")
	oResult:AssertFalse(oMemCache:Put("KEY11", 1), "Incluiu o KEY11, mas não deveria.")
Return oResult

Method TestPutWithExpired() Class STFWCTestLimitedMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCLimitedMemCache():STFWCLimitedMemCache(10)
	
	oResult:AssertTrue(oMemCache:Put("KEY1", 1, 0.02), "Não incluiu o KEY1, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY2", 1, 0.02), "Não incluiu o KEY2, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY3", 1), "Não incluiu o KEY3, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY4", 1), "Não incluiu o KEY4, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY5", 1), "Não incluiu o KEY5, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY6", 1), "Não incluiu o KEY6, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY7", 1), "Não incluiu o KEY7, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY8", 1), "Não incluiu o KEY8, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY9", 1), "Não incluiu o KEY9, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY10", 1), "Não incluiu o KEY10, mas deveria.")
	Sleep(1000)
	oResult:AssertTrue(oMemCache:Put("KEY11", 1), "Não incluiu o KEY11, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY12", 1), "Não incluiu o KEY12, mas deveria.")
	oResult:AssertFalse(oMemCache:Put("KEY13", 1), "Incluiu o KEY13, mas não deveria.")
Return oResult

Method TestUnlimited() Class STFWCTestLimitedMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCLimitedMemCache():STFWCLimitedMemCache()
	
	oResult:AssertTrue(oMemCache:Put("KEY1", 1), "Não incluiu o KEY1, mas deveria.")
	oResult:AssertTrue(oMemCache:Put("KEY2", 1), "Não incluiu o KEY2, mas deveria.")
Return oResult