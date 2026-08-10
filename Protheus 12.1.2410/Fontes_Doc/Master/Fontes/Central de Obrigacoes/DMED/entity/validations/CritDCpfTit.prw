#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDCpfTit
Descricao: 	CriticaB3F referente ao Campo Numero do Lote.
				-> BKR_CNS
@author lima.everton
@since 11/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDCpfTit From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritDCpfTit

	_Super:New()
	self:setAlias('B2W')
	self:setCodCrit('DM05')
	self:setMsgCrit('O campo CPF do titular está inválido.')
	self:setSolCrit('O campo é de preenchimento obrigatório, deve ser preenchido com um CPF válido.')
	self:setCpoCrit('B2W_CPFTIT')

Return Self

Method Validar() Class CritDCpfTit
	Local lValidado := .T.

	If Self:oEntity:getValue("recordId") == '1'
		lValidado := CGC(Self:oEntity:getValue("ssnHolder"))
	EndIf

Return lValidado
