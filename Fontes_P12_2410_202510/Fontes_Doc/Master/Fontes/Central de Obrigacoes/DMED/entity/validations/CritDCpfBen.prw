#Include "Totvs.ch"

#Define CONJUGE    '03'  //Cônjuge/companheiro
#Define FILHO      '04'  //Filho/filha
#Define ENTEADO    '06'  //Enteado/enteada
#Define PAI_MAE    '08'  //Pai/mãe
#Define AGRE_OUTRO '10'  //Agregado/outros
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDCpfBen
Descricao: 	CriticaB3F referente ao Campo Numero do Lote.
				-> B2W_CPFBEN
@author lima.everton
@since 11/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDCpfBen From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritDCpfBen

	_Super:New()
	self:setAlias('B2W')
	self:setCodCrit('DM07')
	self:setMsgCrit('O campo CPF do dependente é inválido.')
	self:setSolCrit('O campo é de preenchimento obrigatório para declaração dos dependentes do titular, deve ser preenchido com um CPF válido.')
	self:setCpoCrit('B2W_CPFBEN')

Return Self

Method Validar() Class CritDCpfBen
	Local lValid := .T.

	If self:oEntity:getValue("dependenceRelationship") $ CONJUGE+','+FILHO+','+ENTEADO+','+PAI_MAE+','+AGRE_OUTRO
		If Empty(Self:oEntity:getValue("ssnBeneficiary"))
			If Calc_Idade( STOD(self:oEntity:getValue("referenceYear") +"12" + "31") , STOD(Self:oEntity:getValue("dependentBirthDate"))) < 18
				lValid := .T.
			Else
				lValid := .F.
			EndIf
		Else
			lValid := CGC(Self:oEntity:getValue("ssnBeneficiary")) .AND. Len(Self:oEntity:getValue("ssnBeneficiary")) == 11
		EndIf
	EndIf

Return lValid
