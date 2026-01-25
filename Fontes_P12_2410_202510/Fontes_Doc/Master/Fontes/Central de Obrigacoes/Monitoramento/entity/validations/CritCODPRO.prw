#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCODPRO
Descricao: 	Critica referente ao Campo.
				-> BKS_CODPRO 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCODPRO From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCODPRO
	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M059')
	self:setMsgCrit('O Código identificador do procedimento ou item assistencial realizado pelo prestador é inválido.')
	self:setSolCrit('Preencha corretamente o campo Código identificador do procedimento ou item assistencial realizado pelo prestador, conforme tabela de domínio.')
	self:setCpoCrit('BKS_CODPRO')
	self:setCodAns('1801')
Return Self

Method Validar() Class CritCODPRO
	Local lRet			:= .T.
	If !(self:oEntity:getValue("tableCode") $ '00/90/98')
		If Empty(self:oEntity:getValue("procedureCode"))
			lRet	:= .F.
		else
			lRet := ExisTabTiss(self:oEntity:getValue("procedureCode"),self:oEntity:getValue("tableCode"),.T.) 
		EndIf
	EndIf

	// Else
	// 	oColBKS	:= CenCltBKS():New()
	// 	oColBKS:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
	// 	oColBKS:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
	// 	oColBKS:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
	// 	oColBKS:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
	// 	oColBKS:setValue("operatorFormNumber",self:oEntity:getValue("operatorFormNumber"))
	// 	oColBKS:setValue("formProcDt",self:oEntity:getValue("formProcDt"))
	// 	oColBKS:setValue("procedureGroup",self:oEntity:getValue("procedureGroup"))
	// 	oColBKS:setValue("tableCode",self:oEntity:getValue("tableCode"))
	// 	oColBKS:setValue("procedureCode",self:oEntity:getValue("procedureCode"))

	// 	If oColBKS:qtdProcGui() > 1
	// 		lRet := .F.
	// 		self:setSolCrit('Não deve haver repetição da tabela de referência em conjunto com o código do grupo ou item assistencial no fornecimento direto de materiais e medicamentos.')
	// 	EndIf 
	// 	oColBKS:destroy()
	// 	FreeObj(oColBKS)
	// 	oColBKS := nil
Return lRet 
