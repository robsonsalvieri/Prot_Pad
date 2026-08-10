#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCPFCNPJ2
Descricao: 	Critica referente ao Campo.
				-> BVZ_CPFCNP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCPFCNPJ2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCPFCNPJ2
	_Super:New()
	self:setAlias('BVZ')
	self:setCodCrit('M100')
	self:setMsgCrit('O campo Número de cadastro do recebedor na Receita Federal é inválido.')
	self:setSolCrit('O CPF / CNPJ deve ser um número válido e existir na base de dados da Receita Federal.')
	self:setCpoCrit('BVZ_CPFCNP')
	self:setTpVld('1')
	self:setCodAns('1206')
Return Self

Method Validar() Class CritCPFCNPJ2
Return !Empty(Self:oEntity:getValue("providerCpfCnpj")) .And. (AllTrim(Self:oEntity:getValue("providerCpfCnpj")) != '00000000000000' .And. CGC(Self:oEntity:getValue("providerCpfCnpj"),,.F.))
