#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritSexo2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritSexo2 From CritSexo
	Method New() Constructor
	Method Validar()
EndClass
Method New() Class CritSexo2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M083')
	self:setMsgCrit('')
	self:setSolCrit('')
	self:setCpoCrit('BVQ_MATRIC')
Return Self

Method Validar() Class CritSexo2

	Local lRet		:= .F.
	Local cMsgCrit	:= 'O Sexo do beneficiário é inválido.'
	Local cSolCrit	:= 'Corrigir o conteúdo do Campo Sexo do Beneficiário com um código válido.'
	Local cCodANS	:= '5029'
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())
		lRet := !Empty(oBenef:getCNS()) .OR. (!Empty(oBenef:getSexo()) .AND. AllTrim(oBenef:getSexo()) $ '1/3')
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil		
	EndIf

	Self:SetCodANS(cCodANS)
	Self:setMsgCrit(cMsgCrit)
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet