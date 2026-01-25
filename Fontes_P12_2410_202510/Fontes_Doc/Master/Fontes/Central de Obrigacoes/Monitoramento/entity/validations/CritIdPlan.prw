#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIdPlan
Descricao: 	Critica referente aos Campos de Id Plano de Saúde
				-> B3K_SUSEP
				-> B3K_SCPA
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIdPlan From CriticaB3F

	Method New() Constructor
	Method Validar()

EndClass

Method New() Class CritIdPlan

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M005')
	self:setMsgCrit('Número de registro do plano do beneficiário (RPS) ou número de cadastro do plano (SCPA) é inválido.')
	self:setSolCrit('Corrija o conteúdo do campo Número de registro do plano do beneficiário (RPS) ou número de cadastro do plano do beneficiário (SCPA) .')
	self:setCpoCrit('B3K_SCPA')//,B3K_SUSEP')
	self:setCodAns('1024')

Return Self

Method Validar() Class CritIdPlan

	Local lRet		:= .T.
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())  
		self:setRecno(BKR->(Recno()))

		If Empty(oBenef:getSusep()) .And. Empty(oBenef:getScpa())
			lRet	:= .F.
		EndIf
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil
	Else
		lRet	:= .F.
	EndIf
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
