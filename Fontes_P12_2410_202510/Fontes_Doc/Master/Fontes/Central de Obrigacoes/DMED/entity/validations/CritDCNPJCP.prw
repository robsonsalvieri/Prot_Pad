#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDCNPJCP
Descricao: 	CriticaB3F referente ao Campo Numero do Lote.
				-> B2W_CPFPRE
@author lima.everton
@since 11/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDCNPJCP From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritDCNPJCP

	_Super:New()
	self:setAlias('B2W')
	self:setCodCrit('DM06')
	self:setMsgCrit('O campo CPF/CNPJ do prestador inválido.')
	self:setSolCrit('O campo é de preenchimento obrigatório, deve ser preenchido com um CPF ou CNPJ válido.')
	self:setCpoCrit('B2W_CPFPRE')

Return Self

Method Validar() Class CritDCNPJCP
	Local lValidado := .T.

	If Self:oEntity:getValue("recordId") $ '2/4'     //1=TOP;2=RTOP;3=DTOP;4=RDTOP   B2W_IDEREG
		lValidado := CGC(Self:oEntity:getValue("providerEinSsn"))
	EndIf

Return lValidado
