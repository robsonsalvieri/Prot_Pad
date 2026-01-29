#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include 'MATA010.ch'

/*/{Protheus.doc} MATA010EVTE
Eventos especificos para tratar chamadas a templates do MATA010.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA010EVTE FROM FWModelEvent
	DATA nOpc
		
	DATA l010TOkT
	DATA l010TInc
	DATA l010TAlt
	DATA l010TExc
	
	METHOD New() CONSTRUCTOR
	METHOD ModelPosVld()
	METHOD InTTS()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010EVTE
	::l010TOkT  := ExistTemplate("A010TOK")
	::l010TInc  := ExistTemplate("MT010INC")
	::l010TAlt  := ExistTemplate("MT010ALT")
	::l010TExc  := ExistTemplate("MTA010E")
Return

METHOD ModelPosVld(oModel) CLASS MATA010EVTE
Local lRet := .T.

	::nOpc := oModel:getOperation()
	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE	
		If ::l010TOkT
			lRet:= ExecTemplate("A010TOK",.F.,.F.)
			If ValType(lRet) # "L"
				lRet :=.T.
			EndIf
		EndIf
	EndIf
		
Return lRet

METHOD InTTS() CLASS MATA010EVTE
	If ::l010TInc .And. ::nOpc == MODEL_OPERATION_INSERT
		ExecTemplate("MT010INC")
	EndIf
	
	If ::l010TAlt .And. ::nOpc == MODEL_OPERATION_UPDATE
		ExecTemplate("MT010ALT",.f.,.f.)
	EndIf
	
	If ::l010TExc .And. ::nOpc == MODEL_OPERATION_DELETE
		ExecTemplate("MTA010E",.f.,.f.)
	EndIf
	
Return