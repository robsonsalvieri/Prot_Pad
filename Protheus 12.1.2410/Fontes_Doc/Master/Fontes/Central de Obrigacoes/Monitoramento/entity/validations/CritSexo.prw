#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritSexo
Descricao: 	Critica referente ao Campo Sexo do Beneficiario.
				-> B3K_SEXO
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritSexo From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritSexo
	_Super:New()
	self:setAlias('B3K')
	self:setCodCrit('M010')
	self:setMsgCrit('Indicador de Sexo do Beneficiário é Inválido.')
	self:setCpoCrit('B3K_SEXO')
	self:setCodAns('5029')
Return Self

Method Validar() Class CritSexo
	Local lRet	:= .T.
	Local cSexo := ''
	Local cCNS  := ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))

	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())  
		cSexo := oBenef:getSexo()
		cCNS := oBenef:getCNS()
		If (!Empty(cSexo) .AND. !(AllTrim(cSexo) $ '1/3')) .OR. (Empty(cSexo) .AND. Empty(cCNS))
			lRet := .F.
		EndIf
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil
	EndIf
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
