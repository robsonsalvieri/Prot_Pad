#INCLUDE "PROTHEUS.CH"
//#INCLUDE "PCPA129.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PCPA120EVDEF
Eventos padrões da manutenção dos processos produtivos
@author brunno.costa
@since 26/06/2018
@version P12.1.17
/*/
CLASS PCPA129EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD Activate()

ENDCLASS

/*/{Protheus.doc} New
Construtor do modelo
@author brunno.costa
@since 26/06/2018
@version 1.0
@return .T.
/*/
METHOD New() CLASS  PCPA129EVDEF

Return

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author brunno.costa
@since 26/06/2018
@version 1.0
@return .T.
/*/
METHOD Activate(oModel, cModelId) Class PCPA129EVDEF

	Local lRet 			:= .T.

Return lRet
