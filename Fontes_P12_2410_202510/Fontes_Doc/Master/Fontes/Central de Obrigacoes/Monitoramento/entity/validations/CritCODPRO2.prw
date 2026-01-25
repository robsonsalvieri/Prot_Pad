#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODPRO2
Descricao: 	Critica referente ao Campo.
				-> BVT_CODPRO
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODPRO2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODPRO2

	_Super:New()
	self:setAlias('BVT')
	self:setCodCrit('M094')
	self:setMsgCrit('O campo Código do item assistencial fornecido é inválido.')
	self:setSolCrit('')
	self:setCpoCrit('BVT_CODPRO')
	self:setCodAns('')
Return Self

Method Validar() Class CritCODPRO2
	Local lRet			:= .T.

	If !(self:oEntity:getValue("tableCode") $ '00/90/98')
		If !ExisTabTiss(self:oEntity:getValue("procedureCode"),self:oEntity:getValue("tableCode"),.T.) 
			lRet	:= .F.
			self:setCodANS('2601')
			self:setSolCrit('Deve ser um código válido na tabela TUSS - Tabela 64 - Terminologia de Forma de envio de procedimentos e itens assistenciais para ANS')
		Else
			oColBVT	:= CenCltBVT():New()
			oColBVT:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
			oColBVT:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
			oColBVT:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
			oColBVT:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
			oColBVT:setValue("providerFormNumber",self:oEntity:getValue("providerFormNumber"))
			oColBVT:setValue("formProcDt",self:oEntity:getValue("formProcDt"))
			oColBVT:setValue("procedureGroup",self:oEntity:getValue("procedureGroup"))
			oColBVT:setValue("tableCode",self:oEntity:getValue("tableCode"))
			oColBVT:setValue("procedureCode",self:oEntity:getValue("procedureCode"))

			If oColBVT:qtdProcGui() > 1
				lRet := .F.
				self:setCodANS('5053')
				self:setSolCrit('Não deve haver repetição da tabela de referência em conjunto com o código do item assistencial no fornecimento direto de materiais e medicamentos.')
			EndIf 
			oColBVT:destroy()
			FreeObj(oColBVT)
			oColBVT := nil
		EndIf
	EndIf
Return lRet 
