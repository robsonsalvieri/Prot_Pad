#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritVltFOR
Descricao: 	Critica referente ao Campo.
				-> BKR_VLTFOR
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritVltFOR From CriticaB3F

	Method New() Constructor
	Method Validar()

EndClass

Method New() Class CritVltFOR

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M050' )
	self:setMsgCrit('O Valor Total Pago ao Fornecedores é inválido.')
	self:setCpoCrit('BKR_VLTFOR')

Return Self

Method Validar() Class CritVltFOR

	Local lRet			:= .T.
	Local cCodANS		:= ''
	Local cSolCrit		:= ''
	Local oBKS			:= Nil
	
	If Self:oEntity:getValue("materialsTotalValue") < 0
		lRet		:= .F.
		cCodANS	:= '5034'
		cSolCrit	:= 'O Valor pago aos Fornecedores não pode ser menor que 0.'
	// Else
	// 	oBKS	:= CenCltBKS():New()
		
	// 	oBKS:setValue("procedureGroup",Self:oEntity:getValue("procedureGroup"))   		//BKS_CODGRU
	// 	oBKS:setValue("operatorRecord",Self:oEntity:getValue("operatorRecord"))   		//BKS_CODOPE
	// 	oBKS:setValue("requirementCode",Self:oEntity:getValue("requirementCode")) 		//BKS_CDOBRI
	// 	oBKS:setValue("referenceYear",Self:oEntity:getValue("referenceYear")) 			//BKS_ANO
	// 	oBKS:setValue("commitmentCode",Self:oEntity:getValue("commitmentCode")) 		//BKS_CDCOMP
	// 	oBKS:setValue("operatorFormNumber",Self:oEntity:getValue("operatorFormNumber"))	//BKS_NMGOPE
	// 	oBKS:setValue("batchCode",Self:oEntity:getValue("batchCode"))       			//BKS_LOTE
	// 	oBKS:setValue("formProcDt",Self:oEntity:getValue("formProcDt"))   				//BKS_DTPRGU   
		
	// 	If oBKS:bscTotFor() != Self:oEntity:getValue("materialsTotalValue")
	// 		lRet	:= .F.
	// 		cCodANS		:= '5042'
	// 		cSolCrit		:= 'O Valor Pago aos Fornecedores é diferente do Somatório dos valores informados nos Procedimentos efetuados da Guia.
	// 	EndIf 

	EndIf 
		self:setCodAns(cCodANS)
		self:setSolCrit(cSolCrit)
Return lRet
	

