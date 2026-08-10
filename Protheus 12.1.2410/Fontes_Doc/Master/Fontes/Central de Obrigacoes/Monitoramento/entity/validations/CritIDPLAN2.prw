#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDPLAN2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDPLAN2 From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritIDPLAN2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M086')
	self:setMsgCrit('Número de registro do plano do beneficiário (RPS) ou número de cadastro do plano (SCPA) é inválido.')
	self:setSolCrit('Corrija o conteúdo do campo Número de registro do plano do beneficiário (RPS) ou número de cadastro do plano do beneficiário (SCPA).')
	self:setCpoCrit('BVQ_MATRIC')
	self:setCodAns('1024')
Return Self

Method Validar() Class CritIDPLAN2
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
			lRet := .F.
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
