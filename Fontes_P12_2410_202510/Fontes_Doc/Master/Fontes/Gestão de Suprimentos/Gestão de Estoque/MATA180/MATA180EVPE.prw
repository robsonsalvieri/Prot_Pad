#Include "PROTHEUS.CH"
#include "Mata180.ch"
#include "FWMVCDef.ch"

/*/{Protheus.doc} MATA180EVPE
Eventos especificos para tratar chamadas a pontos de entrada já suportados pelo MVC.

Essa classe existe para manter o legado dos pontos de entrada do MATA180 quando não era MVC.
Os pontos de entrada são chamados nos mesmos momentos que é chamado no MATA180 sem MVC.

O ideal é que os clientes passem a usar o ponto de entrada do MVC e aos poucos não exista 
mais a necessidade de manter a compatibilidade com o legado. Quando isso acontecer, basta
remover a instalação dessa classe no modelo MATA180.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA180EVPE FROM FWModelEvent
	
	DATA nOpc
	DATA cIDSB5
	
	DATA lMT180INC
	DATA lMT180TOK
	DATA lMT180GRV
		
	METHOD New() CONSTRUCTOR
	METHOD FieldPosVld()
	METHOD After()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cID) CLASS MATA180EVPE
Default cID := "SB5MASTER"

	::cIDSB5 := cID
	::lMT180INC := ExistBlock("MT180INC")
	::lMT180TOK := ExistBlock("MA180TOK")
	::lMT180GRV  := ExistBlock("MT180GRV")
Return

METHOD FieldPosVld(oSubModel, cID) CLASS MATA180EVPE
Local lRet := .T.
	
	If cID == ::cIDSB5
		::nOpc := oSubModel:GetOperation()
		
		If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
			If ::lMT180INC
				ExecBlock("MT180INC",.F.,.F.)
			EndIf
						
			If ::lMT180TOK
				lRet := ExecBlock("MA180TOK",.F.,.F.)
				If ValType(lRet) # "L"
					lRet := .T.
				EndIf
			EndIf
		EndIf	
	EndIf
	
Return lRet

METHOD After(oSubModel, cID, cAlias, lNewRecord) CLASS MATA180EVPE	
	
	If cID == ::cIDSB5
		If ::lMT180GRV
			ExecBlock("MT180GRV",.F.,.F.,{::nOpc})
		EndIf
	EndIf
	
Return
