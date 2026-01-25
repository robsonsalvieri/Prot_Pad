#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCNPJ
Descricao: 	Critica referente ao Campo de CNPJ ou CPF.
				-> BKR_CPFCNP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCNPJ From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCNPJ

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M017' )
	self:setMsgCrit('CPF / CNPJ Inválido.')
	self:setSolCrit('O CPF / CNPJ deve ser um número válido e existir na base de dados da Receita Federal.')
	self:setCpoCrit('BKR_CPFCNP')
	self:setCodAns('1206')

Return Self

Method Validar() Class CritCNPJ

    Local cType     := Self:oEntity:getValue("executerId") 
    Local cRegister := Self:oEntity:getValue("providerCpfCnpj") 
    Local fValidado := .T.

    If(len(cType)!=1) .OR. ( (cType != '2') .AND. (cType != '1') )
        fValidado := .F.
        Return fValidado
    EndIf

    fValidado := CGC(cRegister,,.F.)
    If !(fValidado)
        Return fValidado
    EndIf

Return fValidado
