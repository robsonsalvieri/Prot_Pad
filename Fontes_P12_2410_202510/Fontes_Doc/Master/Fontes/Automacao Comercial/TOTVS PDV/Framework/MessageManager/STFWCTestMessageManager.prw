#INCLUDE "PROTHEUS.CH"

Class STFWCTestMessageManager From FWDefaultTestCase
	Method STFWCTestMessageManager()
	
	Method TestHasNoMessage()
	Method TestHasMessage()
	Method TestHasSMessage()
	Method TestHasWarning()
	Method TestHasSWarning()
	Method TestHasNoSWarning()
	Method TestMultiThrow()
	Method TestClear()
	Method TestShow()
EndClass

Method STFWCTestMessageManager() Class STFWCTestMessageManager
	_Super:FWDefaultTestCase()
	Self:AddTestMethod("TestHasNoMessage")
	Self:AddTestMethod("TestHasSMessage")
	Self:AddTestMethod("TestHasWarning")	
	Self:AddTestMethod("TestHasSWarning")
	Self:AddTestMethod("TestHasNoSWarning")
	Self:AddTestMethod("TestMultiThrow")
	Self:AddTestMethod("TestClear")
	//Self:AddTestMethod("TestShow")
Return

Method TestHasNoMessage() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oResult:AssertFalse( oMessageManager:HasMessage() ) 
Return oResult

Method TestHasMessage() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroA", 1, "Ocorreu o erro no TCP" ) )	
	oResult:AssertTrue( oMessageManager:HasMessage() ) 
Return oResult

Method TestHasSMessage() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroB", 1, "Não foi possivel efetuar o download." ) )	
	oResult:AssertTrue( oMessageManager:HasMessage("ErroB") ) 
Return oResult

Method TestHasWarning() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 2, "Não foi possivel efetuar carga" ) )
	oResult:AssertTrue( oMessageManager:HasWarning() ) 
Return oResult

Method TestHasSWarning() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 2, "Não foi possivel efetuar carga" ) )
	oResult:AssertTrue( oMessageManager:HasWarning("ErroC") ) 
Return oResult

Method TestHasNoSWarning() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 2, "Não foi possivel efetuar carga" ) )
	oResult:AssertFalse( oMessageManager:HasWarning("ErroD") ) 
Return oResult

Method TestMultiThrow() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 2, "Não foi possivel efetuar carga" ) )
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroD", 2, "Não foi possivel efetuar carga" ) )
	oResult:AssertTrue( oMessageManager:HasWarning("ErroC") ) 
Return oResult

Method TestClear() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 2, "Não foi possivel efetuar carga" ) )
	oMessageManager:Clear()
	oResult:AssertFalse( oMessageManager:HasWarning("ErroC") )
Return oResult

Method TestShow() Class STFWCTestMessageManager
	Local oMessageManager		:= STFWCMessageManager():STFWCMessageManager()
	Local oResult				:= FWTestResult():FWTestResult()
	
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroC", 1, "Deu problema no pacote TCP." ) )
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroD", 1, "Deu problema na comunicação" ) )
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroE", 1, "Download não foi efetuado." ) )
	oMessageManager:ThrowMessage( STFWCMessage():STFWCMessage( "ErroF", 1, "A carga não subiu." ) )
	oMessageManager:Show("Ih, aconteceu alguma coisa.")
Return oResult