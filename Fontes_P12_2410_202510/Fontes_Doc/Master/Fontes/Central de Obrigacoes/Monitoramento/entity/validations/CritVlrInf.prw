#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVlrInf
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTINF
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVlrInf From CriticaB3F

	Method New() Constructor
	Method Validar()

EndClass

Method New() Class CritVlrInf

	_Super:New()

	self:setAlias('BKR')
	self:setCodCrit('M041' )
	self:setMsgCrit('O valor total informado a Guia é diferente da somatória do valor informado dos itens.')
	self:setSolCrit('O valor informado da guia deve ser igual a soma dos valores informados de procedimentos ou itens assistenciais.')
	self:setCpoCrit('BKR_VLTINF')
	self:setCodAns('5042')

Return Self

Method Validar() Class CritVlrInf

	Local lRet			:= .T.
	Local oBKS			:= Nil

	If Self:oEntity:getValue("totalValueEntered") > 0 
	
		oBKS	:= CenCltBKS():New()
		
		oBKS:setValue("procedureGroup",Self:oEntity:getValue("procedureGroup"))			//BKS_CODGRU
		oBKS:setValue("operatorRecord",Self:oEntity:getValue("operatorRecord"))			//BKS_CODOPE
		oBKS:setValue("requirementCode",Self:oEntity:getValue("requirementCode"))		//BKS_CDOBRI
		oBKS:setValue("referenceYear",Self:oEntity:getValue("referenceYear"))			//BKS_ANO
		oBKS:setValue("commitmentCode",Self:oEntity:getValue("commitmentCode"))			//BKS_CDCOMP
		oBKS:setValue("operatorFormNumber",Self:oEntity:getValue("operatorFormNumber"))	//BKS_NMGOPE
		oBKS:setValue("batchCode",Self:oEntity:getValue("batchCode"))					//BKS_LOTE
		oBKS:setValue("formProcDt",Self:oEntity:getValue("formProcDt"))					//BKS_DTPRGU   

		If oBKS:contGuia() <= 1 .AND. (oBKS:bscTotInf() != Self:oEntity:getValue("totalValueEntered"))
			lRet	:= .F.
		EndIf 		
	Else
		lRet	:= .F.
	EndIf 

Return lRet
	

