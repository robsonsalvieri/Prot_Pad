#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDtNas
Descricao: 	Critica referente ao Campo Data de Nascimento.
				-> B3K_DATNAS
@author Hermiro Jï¿½nior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDtNas From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritDtNas
	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M016')
	self:setMsgCrit('Data de Nascimento do Beneficiário é Inválida.')
	self:setSolCrit('')
	self:setCpoCrit('B3K_DATNAS')
	self:setCodAns('1323')
Return Self

Method Validar() Class CritDtNas

	Local lRet		:= .T.
	Local cSolCrit 	:= ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	oBscBenef:buscar()
	If !Empty(Self:oEntity:getValue("executionDate"))
		If oBscBenef:hasNext()
			oBenef := oBscBenef:getNext()
			self:setDesOri(oBenef:getNomBen())  
			
			If (Empty(oBenef:getDatNas()) .AND. Empty(oBenef:getCNS()) ) .Or. oBenef:getDatNas() > StoD(Self:oEntity:getValue("executionDate"))
				cSolCrit := 'Corrigir o conteudo do Campo Data de Nascimento do Beneficiário. O conteudo deve ser uma data valida e inferior ou igual a data de realização do procedimento.'	
				lRet	:= .F.
			EndIf
			oBenef:destroy()
			FreeObj(oBenef)
			oBenef := nil
		Else
			cSolCrit := 'Verifique o preenchimento da Data de Nascimento do Beneficiário.'
			lRet	:= .F.
		EndIf
	EndIf
	
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
