#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCDFAC1
Descricao: 	CriticaB3F referente ao Campo.
				-> BKS_CDFACE 
@author José Paulo
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCDFAC1 From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritCDFAC1
	_Super:New()
	self:setAlias('BKS')
	self:setCodCrit('M116')
	self:setMsgCrit('Face informada é diferente da anterior.')
	self:setSolCrit('Preencha corretamente o campo da face, conforme tabela de domínio.')
	self:setCpoCrit('BKS_CDFACE')
	self:setCodAns('5029')
Return Self

Method Validar() Class CritCDFAC1
	Local lRet			:= .T.

	If  !Empty(self:oEntity:getValue('toothFaceCode')) .Or. !Empty(self:oEntity:getValue('toothCode')) .Or. !Empty(self:oEntity:getValue('regionCode')) .Or. self:oEntity:getValue('tableCode')=='17'
		If Empty(self:oEntity:getValue("procedureCode"))    
			lRet	:= .F.   
/*		Else
	    	oColBKS	:= CenCltBKS():New()
			oColBKS:setValue("operatorRecord",self:oEntity:getValue("operatorRecord"))
			oColBKS:setValue("requirementCode",self:oEntity:getValue("requirementCode"))
			oColBKS:setValue("referenceYear",self:oEntity:getValue("referenceYear"))
			oColBKS:setValue("commitmentCode",self:oEntity:getValue("commitmentCode"))
			oColBKS:setValue("operatorFormNumber",self:oEntity:getValue("operatorFormNumber"))
			oColBKS:setValue("formProcDt",self:oEntity:getValue("formProcDt"))
			oColBKS:setValue("procedureGroup",self:oEntity:getValue("procedureGroup"))
			oColBKS:setValue("tableCode",self:oEntity:getValue("tableCode"))
			oColBKS:setValue("toothCode",self:oEntity:getValue("toothCode"))
			oColBKS:setValue("procedureCode",self:oEntity:getValue("procedureCode"))
			oColBKS:setValue("regionCode",self:oEntity:getValue("regionCode"))
			oColBKS:setValue("toothFaceCode",self:oEntity:getValue("toothFaceCode"))

			If !Empty(self:oEntity:getValue('toothFaceCode')) .And. Len(self:oEntity:getValue('toothFaceCode')) <= 5 

				If oColBKS:qtdProcFa() >= 1
					lRet := .F.
					self:setSolCrit('Preencha a face igual a que já foi informado anteriormente para esta guia/procedimento/região.')
				EndIf 

				oColBKS:destroy()
				FreeObj(oColBKS)
				oColBKS := nil
			EndIf */
		EndIf	
	EndIf
Return lRet 
