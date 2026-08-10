#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritTABPAC
Descricao: 	Critica referente ao Campo.
				-> BKS_PACOTE
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritTABPAC From CriticaB3F

	Method New() Constructor
	Method Validar()

EndClass

Method New() Class CritTABPAC

	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M070' )
	self:setMsgCrit('O Tabela de referência do procedimento ou item assistencial realizado que compõe o pacote é inválido.')
	self:setSolCrit('Preencha corretamente o campo Tabela de referência do procedimento ou item assistencial realizado que compõe o pacote conforme tabela de domínio nº 87.')
	self:setCpoCrit('BKS_PACOTE')
	self:setCodAns('5029')

Return Self

Method Validar() Class CritTABPAC

	Local lRet		:= .T.
	Local oColBKT	:= CenCltBKT():New()

	If AllTrim(Self:oEntity:getValue("tableCode")) $ '90/98'

		oColBKT:SetValue('operatorRecord'		,Self:oEntity:getValue("operatorRecord"))   
		oColBKT:SetValue('operatorFormNumber'	,Self:oEntity:getValue("operatorFormNumber"))
		oColBKT:SetValue('requirementCode'		,Self:oEntity:getValue("requirementCode"))
		oColBKT:SetValue('referenceYear'			,Self:oEntity:getValue("referenceYear"))
		oColBKT:SetValue('commitmentCode'		,Self:oEntity:getValue("commitmentCode"))
		oColBKT:SetValue('formProcDt'				,Self:oEntity:getValue("formProcDt"))
		oColBKT:setValue("tableCode"				,Self:oEntity:getValue("tableCode"))
		oColBKT:setValue("procedureCode"			,Self:oEntity:getValue("procedureCode"))
		oColBKT:setValue("batchCode"				,Self:oEntity:getValue("batchCode"))

		lRet := oColBKT:bscCodPac()
		
		oColBKT:destroy()
		FreeObj(oColBKT)
		oColBKT := nil
		
	EndIf 

Return lRet
