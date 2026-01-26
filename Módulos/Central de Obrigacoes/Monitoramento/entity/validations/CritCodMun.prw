#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCodMun
Descricao: 	Critica referente ao Campo de Código de Municipio
				-> BKR_CDMNEX
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCodMun From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCodMun

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M020')
	self:setMsgCrit('Código do Município do Executante Inválido.')
	self:setSolCrit('O Código do Município informado deve ser um código válido e incluso na base de dados de municípios do IBGE.')
	self:setCpoCrit('BKR_CDMNEX')
	self:setCodAns('5030')

Return Self

Method Validar() Class CritCodMun
	Local lValido   := .T.
	Local lValidMun := .T.
	Local cCNS      := ''
	Local cCodMun   := ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	  := nil
	Local cCodANS	  := ''
	Local cMsgCrit  := ''
	Local cSolCrit  := ''

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	//Encontrou a Matricula
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())
		cCNS := oBenef:getCNS()
		cCodMun := Self:oEntity:getValue("executingCityCode")

		lValidMun := GetCdMun(cCodMun)

		// If Empty(cCNS) .AND. Empty(cCodMun)
		// 	lValido   := .F.
		// 	cCodANS		:= '5029'
		// 	cMsgCrit	:= 'Código do município e CNS do beneficiário em branco.'
		// 	cSolCrit	:= 'Preencher o código do município e/ou código da CNS do beneficiário com um valor válido.'
		If !(Empty(cCodMun)) .AND. !(lValidMun)
			lValido   := .F.
			cCodANS		:= '5030'
			cMsgCrit	:= 'Código do Município do Executante Inválido.'
			cSolCrit	:= 'O Código do Município informado deve ser um código válido e incluso na base de dados de municípios do IBGE.'
		EndIf

		oBenef:destroy()
	Else
		cCodANS		:= '5029'
		cMsgCrit	:= 'Código de Município Inválido.'
		cSolCrit	:= 'Verifique se Beneficiário está cadastrado na tabela de Beneficiários.'
		lValido		:= .F.
	EndIf

	Self:SetCodANS(cCodANS)
	Self:setMsgCrit(cMsgCrit)
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	oBscBenef := nil
	oBenef := nil
	FreeObj(oBscBenef)
	FreeObj(oBenef)

Return lValido
