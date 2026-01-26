#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODMUN2
Descricao: 	Critica referente ao Campo.
				-> BVQ_MATRIC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODMUN2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODMUN2
	_Super:New()
	self:setAlias('BVQ')
	self:setCodCrit('M085')
	self:setCpoCrit('BVQ_MATRIC')
Return Self

Method Validar() Class CritCODMUN2

	Local lValido		:= .T.
	Local lValidMun := .T.
	Local cCNS      := ''
	Local cCodMun   := ''
	Local cCodANS	  := ''
  Local cMsgCrit  := ''
  Local cSolCrit  := ''
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	  := nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(Self:oEntity:getValue("operatorRecord"))
	
	//Encontrou a Matricula
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())
		cCNS := oBenef:getCNS()
		cCodMun := oBenef:getCodMun()
		lValidMun := GetCdMun(cCodMun)

		If Empty(cCNS) .AND. Empty(cCodMun)
			lValido		:= .F.
			cCodANS		:= '5029'
			cMsgCrit	:= 'Código do município e CNS do beneficiário em branco.'
			cSolCrit	:= 'Preencher o código do município e/ou código da CNS do beneficiário com um valor válido.'
		Elseif !(Empty(cCodMun)) .AND. !(lValidMun)
			lValido		:= .F.
			cCodANS		:= '5030'
			cMsgCrit	:= 'Código do Município do Executante Inválido.'
			cSolCrit	:= 'O Código do Município informado deve ser um código válido e incluso na base de dados de municípios do IBGE.'
		EndIf

		oBenef:destroy()

	else
		lValido		:= .F.
		cCodANS		:= '5029'
		cMsgCrit	:= 'Código de Município Inválido.'
		cSolCrit	:= 'Verifique se Beneficiário está cadastrado na tabela de Beneficiários.'
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
