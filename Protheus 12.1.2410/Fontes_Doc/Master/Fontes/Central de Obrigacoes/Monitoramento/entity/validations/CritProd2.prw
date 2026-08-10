#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritProd2
Descricao: 	Critica referente ao código do produto na API fornecimento direto.
				-> BKR_CNS
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritProd2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritProd2

	_Super:New()
	self:setAlias('B3K')
	self:setCodCrit('M117')
	self:setMsgCrit('')
	self:setSolCrit('')
	self:setCpoCrit('B3K_CODPRO')
	
Return Self

Method Validar() Class CritProd2

	Local lRet		:= .T.
	Local cMsgCrit	:= ''
	Local cSolCrit := ''
	Local cCodANS	:= ''
    Local cCodPro := ''
    Local cCodOpe := Self:oEntity:getValue("operatorRecord")
	Local oDaoBenef := DaoCenBenefi():new()
	Local oBscBenef := BscCenBenefi():new(oDaoBenef)
	Local oBenef	:= nil

	oDaoBenef:setMatric(Self:oEntity:getValue("registration"))
	oDaoBenef:setCodOpe(cCodOpe)
	
	//Encontrou a Matricula
	oBscBenef:buscar()
	If oBscBenef:hasNext()
		oBenef := oBscBenef:getNext()
		self:setDesOri(oBenef:getNomBen())

    	cCodPro := oBenef:getCodPro()
    	cCodPro := AllTrim(GetAdvFVal("B3J","B3J_CODIGO",xFilial("B3J")+cCodOpe+cCodPro,1,"Erro"))
		
		If cCodPro == "Erro" .OR. Empty(cCodPro)
			lRet	:= .F.	
			cCodANS	:= '1024'
			cMsgCrit := 'Código do produto do Beneficiário está vazio ou é Inválido.'
			cSolCrit := 'Alterar o código do produto do Beneficiário para um valor válido.'
		EndIf 
		oBenef:destroy()
		FreeObj(oBenef)
		oBenef := nil
	Else
		cCodANS := '5029'
		cMsgCrit := 'Código do produto do Beneficiário é Inválido.'
		cSolCrit := 'Verifique se Beneficiário está cadastrado na tabela de Beneficiários.'
		lRet := .F.
	EndIf

	Self:SetCodANS(cCodANS)
	Self:setMsgCrit(cMsgCrit)
	Self:setSolCrit(cSolCrit)
	
	oBscBenef:destroy()
	FreeObj(oBscBenef)
	oBscBenef := nil

Return lRet
