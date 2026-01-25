#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDEREC
Descricao: 	Critica referente ao Campo.
				-> BVZ_IDEREC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDEREC From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritIDEREC
	_Super:New()
	self:setAlias('BVZ')
	self:setCodCrit('M102')
	self:setMsgCrit('O campo Tipo da identificação do recebedor é inválido.')
	self:setSolCrit('O Campo Tipo da identificação do recebedor, sendo: 1-CNPJ OU 2-CPF')
	self:setCpoCrit('BVZ_IDEREC')
	self:setTpVld('1')
	self:setCodAns('M102')
Return Self

Method Validar() Class CritIDEREC
Return Empty(Self:oEntity:getValue("providerCpfCnpj")) .Or. (Len(Self:oEntity:getValue("providerCpfCnpj"))==11 .And. Self:oEntity:getValue("identReceipt")=='2') .Or. (Len(Self:oEntity:getValue("providerCpfCnpj"))==14 .And. Self:oEntity:getValue("identReceipt")=='1')
