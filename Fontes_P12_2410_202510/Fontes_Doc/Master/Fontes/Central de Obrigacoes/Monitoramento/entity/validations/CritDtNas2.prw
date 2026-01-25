#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDtNas2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDtNas2 From CritDtNas
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritDtNas2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M084')
	self:setMsgCrit('A Data de nascimento do beneficiário é inválida')
	self:setSolCrit('')
	self:setCpoCrit('BVQ_MATRIC')
	self:setCodAns('1323')
Return Self

Method Validar() Class CritDtNas2

	Local lRet		:= .T.
	Local cSolCrit 	:= ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	oBscBenef:buscar()
	If !Empty(Self:oEntity:getValue("formProcDt"))
		If oBscBenef:hasNext()
			oBenef := oBscBenef:getNext()
			self:setDesOri(oBenef:getNomBen())  
			
			If (Empty(oBenef:getDatNas()) .AND. Empty(oBenef:getCNS())) .Or. oBenef:getDatNas() > StoD(Self:oEntity:getValue("formProcDt"))
				cSolCrit := 'Corrigir o conteudo do Campo Data de Nascimento do Beneficiario. O conteudo deve ser uma data valida e inferior ou igual a data de realizacao do procedimento.'	
				lRet	:= .F.
			EndIf
			oBenef:destroy()
			FreeObj(oBenef)
			oBenef := nil
		Else
			cSolCrit := 'Verifique o preenchimento da Data de Nascimento do Beneficiario.'
			lRet	:= .F.
		EndIf
	EndIf
	
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
