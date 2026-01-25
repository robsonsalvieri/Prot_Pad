#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNPJFR
Descricao: 	Critica referente ao Campo.
				-> BKS_CNPJFR  
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNPJFR From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCNPJFR
	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M068')
	self:setMsgCrit('O Cadastro  Nacional de Pessoa Jurídica do fornecedor do item assistencial é inválido.')
	self:setSolCrit('Preencha corretamente o campo CNPJ - Cadastro  Nacional de Pessoa Jurídica do fornecedor do item assistencial conforme guia enviada.')
	self:setCpoCrit('BKS_CNPJFR')
	self:setCodAns('1206')
Return Self

Method Validar() Class CritCNPJFR
Return  Self:oEntity:getValue("valuePaidSupplier") == 0 .Or. (!Empty(Self:oEntity:getValue("supplierCnpj")) .And. AllTrim(Self:oEntity:getValue("supplierCnpj")) != "00000000000000" .And. CGC(Self:oEntity:getValue("supplierCnpj"),,.F.))
