#include 'Protheus.ch'
#include 'FWMVCDef.ch' 

// Função apenas para o inspetor de objetos e validar a existência da classo com FindFunction no MATA020
Function MATA020OMS()
Return .T.

/*/{Protheus.doc} MATA020EVOMS
Eventos do MVC relacionados a integração de fornecedor com o Cockpit Logísitco (OMS).
Qualquer regra que seja referente ao OMS deve ser criada aqui.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type class
 
@author amanda.vieira
@since 12/04/2018
@version 12.1.17
/*/
CLASS MATA020EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD InTTS()
ENDCLASS

METHOD New() CLASS MATA020EVOMS
Return
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após as gravações,
porém antes do final da transação

@type method
 
@author amanda.vieira
@since 12/04/2018
@version 12.1.17
/*/
METHOD InTTS(oModel) CLASS MATA020EVOMS
	//Chamada de função OMS para verificar integração com o CPL
	If !(oModel:GetOperation() == MODEL_OPERATION_DELETE) .And. FindFunction("OMSXCPLINT")
		OMSXCPLINT("SA2")
	EndIf
Return