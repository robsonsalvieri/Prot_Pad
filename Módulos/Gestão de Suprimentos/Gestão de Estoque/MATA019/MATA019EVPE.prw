#include "MATA019.CH"
#include "Protheus.CH"
#include "FWMVCDef.CH"

/*/{Protheus.doc} MATA019EVPE
Eventos especificos para tratar chamadas a pontos de entrada já suportados pelo MVC.

Essa classe existe para manter o legado dos pontos de entrada do MATA019 quando não era MVC.
Os pontos de entrada são chamados nos mesmos momentos que é chamado no MATA019 sem MVC.

O ideal é que os clientes passem a usar o ponto de entrada do MVC e aos poucos não exista 
mais a necessidade de manter a compatibilidade com o legado. Quando isso acontecer, basta
remover a instalação dessa classe no modelo MATA019.

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA019EVPE FROM FWModelEvent
	
	DATA cIDSBZ
	DATA cIDSB1
	
	DATA lMT019Log
	DATA lMT019Grv
	
	METHOD New() CONSTRUCTOR
	
	METHOD Before()
	METHOD After()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cIDSB1, cIDSBZ) CLASS MATA019EVPE
Default cIDSB1 := "SB1MASTER"
Default cIDSBZ := "SBZDETAIL"
	
	::cIDSB1 := cIDSB1
	::cIDSBZ := cIDSBZ
	
	::lMT019Log := ExistBlock("M019LOG")
	::lMT019Grv := ExistBlock("M019GRV")
Return

METHOD Before(oSubModel, cID) CLASS MATA019EVPE
Local nOpc := oSubModel:GetOperation()
	
	If cID == ::cIDSBZ
		If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE	
			//Ponto de entrada para comparação de alteração da tabela SBZ
			If ::lMT019Log
				ExecBlock("M019LOG",.F.,.F.,{oSubModel:aHeader,oSubModel:aCols})
			EndIf
		EndIf
	EndIf
Return

METHOD After(oSubModel, cID) CLASS MATA019EVPE
Local nOpc := oSubModel:GetOperation()
		
	If cID == ::cIDSBZ
		If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
			//Ponto de entrada apos gravacao da tabela SBZ
			If ::lMT019Grv
				ExecBlock("M019GRV",.F.,.F.,{oSubModel:aHeader,oSubModel:aCols})
			Endif
		EndIf	
	EndIf
Return