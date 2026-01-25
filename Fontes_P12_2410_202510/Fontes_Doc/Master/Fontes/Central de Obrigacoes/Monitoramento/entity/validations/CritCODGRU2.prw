#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODGRU2
Descricao: 	Critica referente ao Campo.
				-> BVT_CODGRU
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODGRU2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODGRU2
	_Super:New()
	self:setAlias('BVT')
	self:setCodCrit('M093')
	self:setMsgCrit('O campo Código do grupo do procedimento ou item assistencial é inválido.')
	self:setSolCrit('O conteúdo do Campo Código TUSS identificador do grupo de itens assistenciais fornecidos deve ser um código válido, conforme tabela de domínio nº 63.')
	self:setCpoCrit('BVT_CODGRU')
	self:setCodAns('5929')
Return Self

Method Validar() Class CritCODGRU2
	Local lRet			:= .T.

	If !Empty(self:oEntity:getValue("procedureGroup"))
		If !ExisTabTiss((Self:cAlias)->BVT_CODGRU,'63') 
			lRet	:= .F.
			self:setCodANS('5036')
			self:setSolCrit('Deve ser um código válido na base de termos da tabela TUSS - Tabela 63 - Terminologia de Grupos de procedimentos e itens assistenciais para envio para ANS')
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

			If oColBVT:qtdGrupo() > 1
				lRet := .F.
				self:setCodANS('5053')
				self:setSolCrit('Não deve haver repetição da tabela de referência em conjunto com o código do grupo ou item assistencial no fornecimento direto de materiais e medicamentos.')
			EndIf 
			oColBVT:destroy()
			FreeObj(oColBVT)
			oColBVT := nil
		EndIf
	EndIf
Return lRet 
