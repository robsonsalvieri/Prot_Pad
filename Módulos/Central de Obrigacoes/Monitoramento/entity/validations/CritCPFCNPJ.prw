#Include "Totvs.ch"

#DEFINE CNPJF '1'
#DEFINE CPF '2'
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCPFCNPJ
Descricao: 	Critica referente ao Campo.
				-> B9T_CPFCNP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0

@version 2.0
@author p.drivas
@since 19/06/2020
Inserido validação de se o conteudo do CPF ou CNPJ corresponde ao
tipo de identificador informado
/*/
//-------------------------------------------------------------------
Class CritCPFCNPJ From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCPFCNPJ
	_Super:New()
	self:setAlias('B9T')
	self:setCodCrit('M076')
	self:setMsgCrit('O Número de cadastro do prestador executante na Receita Federal (CNPJ/CPF) é inválido.')
	self:setSolCrit('Preencha corretamente o Número de cadastro do prestador com um dado válido.')
	self:setCpoCrit('B9T_CPFCNP')
	self:setTpVld('1')
	self:setCodAns('1206')
Return Self

Method Validar() Class CritCPFCNPJ

    Local cType     := Self:oEntity:getValue("providerIdentifier") 
    Local cRegister := Self:oEntity:getValue("providerCpfCnpj") 
    Local fValidado := .T.

    fValidado := CGC(cRegister,,.F.)
    If !(fValidado)
        Return fValidado
    ElseIf cType == '1' .AND. (len(cRegister) != 14)
        fValidado := .F.
    ElseIf cType == '2' .AND. (len(cRegister) == 14)
        fValidado := .F.
    EndIf

    If !(fValidado)
        self:setCodCrit('M075')
        self:setMsgCrit('O Tipo da identificação do prestador executante é diferente do CPF/CNPJ informado')
        self:setSolCrit('Preencha corretamente o Tipo da identificação do prestador de acordo com CPF/CNPJ informado.')
        self:setCpoCrit('B9T_IDEPRE')
        self:setCodAns('M075')
        Return fValidado
    EndIf

Return fValidado
