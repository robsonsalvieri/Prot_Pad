#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCDPRIT
Descricao: 	Critica referente ao Campo.
				-> BKT_CDPRIT/BKT_CODPRO
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCDPRIT From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCDPRIT
	_Super:New()
	self:setAlias('BKT')
	self:setCodCrit('M071')
	self:setMsgCrit('O Código do procedimento realizado ou item assistencial utilizado que compõe o pacote é inválido.')
	self:setSolCrit('Preencha corretamente o campo Código do procedimento realizado ou item assistencial utilizado que compõe o pacote conforme Guia enviada.')
	self:setCpoCrit('BKT_CODPRO')
	self:setCodAns('1801')
Return Self

Method Validar() Class CritCDPRIT
	Local lRet		:= .T.

	If !Empty(self:oEntity:getValue("tableCode"))
		lRet := ExisTabTiss(self:oEntity:getValue("procedureCode"),self:oEntity:getValue("tableCode"),.T.)
	EndIf
	If !Empty(self:oEntity:getValue("itemTableCode"))
		lRet := ExisTabTiss(self:oEntity:getValue("itemProCode"),self:oEntity:getValue("itemTableCode"),.T.)
	EndIf
Return lRet
