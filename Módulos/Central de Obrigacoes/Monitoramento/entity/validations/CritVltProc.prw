#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltProc
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTPRO
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltProc From CriticaB3F

	Method New() Constructor
	Method Validar()

EndClass

Method New() Class CritVltProc

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M042' )
	self:setMsgCrit('O valor processado da Guia é inválido.')
	self:setSolCrit('Valor total  processado pela operadora não corresponde ao valor informado da guia menos o valor de glosa da guia.')
	self:setCpoCrit('BKR_VLTPRO')
	self:setCodAns('5034')

Return Self

Method Validar() Class CritVltProc

	Local lRet		:= .T.

	If AllTrim(Self:oEntity:getValue("monitoringRecordType")) $ '1/2'
		If Self:oEntity:getValue("valueProcessed") < 0
			lRet		:= .F.
		EndIf 
		If (Self:oEntity:getValue("totalValueEntered") - Self:oEntity:getValue("formDisallowanceValue")) != Self:oEntity:getValue("valueProcessed")
			lRet 	:= .F.
		EndIf 
	EndIf 

Return lRet
	

