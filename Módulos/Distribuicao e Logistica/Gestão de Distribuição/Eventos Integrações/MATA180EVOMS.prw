#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0066
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author  Squad OMS
@since   18/02/2019
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0066()
Return Nil

/*/{Protheus.doc} MATA010EVOMS
Eventos do MVC relacionados a integração de complemento de produto com o Cockpit Logístico

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    class
@author  guilherme.metzger
@since   05/12/2018
@version 12
/*/
CLASS MATA180EVOMS FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD InTTS()
ENDCLASS

METHOD New() CLASS MATA180EVOMS
Return

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após as gravações,
porém antes do final da transação

@type    method
@author  guilherme.metzger
@since   05/12/2018
@version 12
/*/
METHOD InTTS(oModel) CLASS MATA180EVOMS
	//Chamada de função OMS para verificar integração com o CPL
	If !(oModel:GetOperation() == MODEL_OPERATION_DELETE) .And. FindFunction("OMSXCPLINT")
		OMSXCPLINT("SB5")
	EndIf
Return
