#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODTAB2
Descricao: 	Critica referente ao Campo.
				-> BVT_CODTAB
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODTAB2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODTAB2
	_Super:New()
	self:setAlias('BVT')
	self:setCodCrit('M092')
	self:setMsgCrit('O campo Tabela de referência do item assistencial fornecido é inválido.')
	self:setSolCrit('O conteúdo do Campo Tabela de Referência do Item Assistencial Fornecido deve ser um código válido na TUSS - Tabela 87 - Relação das terminologias unificadas na saúde suplementar.')
	self:setCpoCrit('BVT_CODTAB')
	self:setCodAns('5029')
Return Self

Method Validar() Class CritCODTAB2
Return ExisTabTiss(self:oEntity:getValue("tableCode"),'87')
