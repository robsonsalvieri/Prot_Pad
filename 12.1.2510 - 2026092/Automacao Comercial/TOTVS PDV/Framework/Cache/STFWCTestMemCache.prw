#INCLUDE "PROTHEUS.CH"

Class STFWCTestMemCache From FWDefaultTestCase
	Method STFWCTestMemCache()
	
	Method TestPut()
	Method TestContains()
	Method TestNotContains()
	Method TestGetValid()
	Method TestGetInvalid()
	Method TestRemove()
	Method TestInvalidate()
EndClass

Method STFWCTestMemCache() Class STFWCTestMemCache
	_Super:FWDefaultTestCase()
	Self:AddTestMethod("TestPut")
	Self:AddTestMethod("TestContains")
	Self:AddTestMethod("TestNotContains")
	Self:AddTestMethod("TestGetValid")
	Self:AddTestMethod("TestGetInvalid")
	Self:AddTestMethod("TestRemove")
	Self:AddTestMethod("TestInvalidate")
Return

Method TestPut() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oResult:AssertTrue(oMemCache:Put("KEY1", 1))
Return oResult

Method TestContains() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oMemCache:Put("KEY1", 1)
	
	oResult:AssertTrue(oMemCache:Contains("KEY1"))
Return oResult

Method TestNotContains() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oMemCache:Put("KEY1", 1)
	
	oResult:AssertFalse(oMemCache:Contains("KEY2"))
Return oResult

Method TestGetValid() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oMemCache:Put("KEY1", 1, 0.02)
	
	oResult:AssertTrue(oMemCache:Get("KEY1") == 1)
Return oResult

Method TestGetInvalid() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oMemCache:Put("KEY1", 1, 0.02)
	Sleep(1000)
	oResult:AssertTrue(oMemCache:Get("KEY1") == Nil)
Return oResult

Method TestRemove() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oMemCache:Put("KEY1", 1, 0.10)
	oMemCache:Remove("KEY1")
	oResult:AssertFalse(oMemCache:Contains("KEY1"))
Return oResult

Method TestInvalidate() Class STFWCTestMemCache
	Local oResult		:= FWTestResult():FWTestResult()
	Local oMemCache	:= STFWCMemCache():STFWCMemCache()
	
	oMemCache:Put("KEY1", 1)
	oMemCache:Put("KEY2", 1, 1)
	oMemCache:Invalidate()
	oResult:AssertFalse(oMemCache:Contains("KEY1"))
	oResult:AssertTrue(oMemCache:Get("KEY2") == Nil)
Return oResult