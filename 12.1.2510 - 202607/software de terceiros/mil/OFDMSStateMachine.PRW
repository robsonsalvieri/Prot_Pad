#include 'protheus.ch'

function DMS00002()
return .t.

/*/{Protheus.doc} OFDMSStateMachine
	Classe que tem tudo para controle de estado via state machine
	
	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/ 
Class OFDMSStateMachine
	Data aStateMap
	Data cState

	method New() CONSTRUCTOR
	method changeState()
	method canChangeTo()
	method getDefinition()
EndClass 

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method New(aMap, cIniState) Class OFDMSStateMachine
	::aStateMap := aMap
	::cState    := cIniState
Return SELF

/*/{Protheus.doc} changeState
	Muda de estado se for permitido de acordo com mapa

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method changeState(cNewState) Class OFDMSStateMachine
	local cAtual := self:cState
	local oDef   := Nil

	if Empty(cAtual) .OR. self:canChangeTo(cNewState)
//		 oDef := self:getDefinition()
//		 oDef:AfterCallback(cAtual, cNewState)
		 self:cState := cNewState
//		 oDef:ChangeStateCallback(cAtual, cNewState)
		return .T.
	endif
Return .F.

/*/{Protheus.doc} canChangeTo
	Verifica se o estado é permitido
	
	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method canChangeTo(cNewState) Class OFDMSStateMachine
	local aPermitted := self:getDefinition()
	local nX         := 1
	if aPermitted != Nil
		for nX := 1 to Len(aPermitted)
			if cNewState == aPermitted[nX]
				return .T.
			endif
		next
	else
		return .F.
	endif
Return .F.

/*/{Protheus.doc} getDefinition
	Pega a definicao do estado atual para verificacoes e execucoes

	@type function
	@author Vinicius Gati
	@since 13/03/2018
/*/
Method getDefinition(cState) Class OFDMSStateMachine
	local nX := 1
	Default cState := self:cState
	For nX:= 1 to Len(self:aStateMap)
		if self:aStateMap[nX]:getState() == cState
			return self:aStateMap[nX]:getDefinition()
		endif
	Next
Return Nil
