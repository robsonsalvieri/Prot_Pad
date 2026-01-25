#include 'protheus.ch'

function DMS00001()
return .t.

/*/{Protheus.doc} OFDMSMachineState
	Classe que representa um estado da maquina de estados
	
	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/ 
Class OFDMSMachineState
	Data cState
	Data aPermitted
	Data uValue

	Method New() CONSTRUCTOR
	Method getState()
	Method getDefinition()
EndClass 

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method New(cState, cValue, aPermitted) Class OFDMSMachineState 
	default cValue  := cState
	self:uValue     := cValue
	self:cState     := cState
	self:aPermitted := aPermitted
Return SELF 

/*/{Protheus.doc} GetState
	pega o identificador do estado

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method getState() Class OFDMSMachineState
Return self:cState

/*/{Protheus.doc} getDefinition
	Pega os estados permitidos

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method getDefinition() Class OFDMSMachineState	
Return self:aPermitted
