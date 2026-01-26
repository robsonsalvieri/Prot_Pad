#Include "Totvs.ch"

#Define CONJUGE    '03'  //Cônjuge/companheiro
#Define FILHO      '04'  //Filho/filha
#Define ENTEADO    '06'  //Enteado/enteada
#Define PAI_MAE    '08'  //Pai/mãe
#Define AGRE_OUTRO '10'  //Agregado/outros

//-------------------------------------------------------------------
/*/{Protheus.doc} CritDDatNas
Descricao: 	CriticaB3F referente ao Campo.
				-> B2W_VLRDES
@author lima.everton
@since 10/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDValTit From CriticaB3F
	Method New() Constructor
	Method Validar()
	Method relDeps()
EndClass


Method New() Class CritDValTit

	_Super:New()
	self:setAlias('B2W')
	self:setCodCrit('DM08')
	self:setMsgCrit('O campo valor da despesa inválido.')
	self:setSolCrit('Quando o titular não possui dependente, o campo Valor da Despesa deve possuir valor maior que zero ( B2W_VLRDES > 0) .')
	self:setCpoCrit('B2W_VLRDES')

Return Self

Method Validar() Class CritDValTit

	Local oCenCltB2W    := CenCltB2W():New()
	Local oCenB2W       := nil
	Local lTemDep       := .F.
	Local lValid        := .T.
	Local nValDep       := self:oEntity:getValue("expenseAmount")
	Local aAreaB2W		:= B2W->(GetArea())

	oCenCltB2W:setValue("ssnHolder", self:oEntity:getValue("ssnHolder"))
	oCenCltB2W:setValue("commitmentYear", self:oEntity:getValue("commitmentYear"))

	//Se eu sou um titular verifico se tenho dependente
	If Empty(self:oEntity:getValue("dependenceRelationship"))
		If oCenCltB2W:buscar()
			while oCenCltB2W:HasNext()
				oCenB2W := oCenCltB2W:GetNext()
				If oCenB2W:getValue("dependenceRelationship") $ self:relDeps()
					lTemDep := .T.
				EndIf
				oCenB2W:destroy()
			endDo
			FreeObj(oCenB2W)
		endIf
		//Se eu não tenho dependente e declarei o valor da despesa Zerado, está invalido
		If !lTemDep .AND. nValDep <= 0
			lValid := .F.
		EndIf
	EndIf

	oCenCltB2W:destroy()
	FreeObj(oCenCltB2W)
	B2W->(RestArea(aAreaB2W))
Return lValid

Method relDeps() Class CritDValTit
return CONJUGE+','+FILHO+','+ENTEADO+','+PAI_MAE+','+AGRE_OUTRO
