#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritDECOBI
Descricao: 	Critica referente ao Campo.
				-> BN0_DECNUM 
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDECOBI From CriticaB3F

	Method New() Constructor
	Method Validar()
EndClass
Method New() Class CritDECOBI

	_Super:New()
	self:setAlias('BKR')
	self:setCodCrit('M056' )
	self:setMsgCrit('O Numero da Declaração de Óbito é inválido.')
	self:setSolCrit('Preencha corretamente o campo Numero da Declaração de Óbito na versão que a guia foi enviada.')
	self:setCpoCrit('BN0_DECNUM')
	self:setCodAns('5034')

Return Self

Method Validar() Class CritDECOBI

	Local lRet		:= .T.
	Local oCltBN0	:= Nil

	If	AllTrim(Self:oEntity:getValue("aEventType")) $ '3' .And. ;
	  	AllTrim(Self:oEntity:getValue("eventOrigin")) $ '1/2/3' .And. ;
		AllTrim(Self:oEntity:getValue("outflowType")) == '41'

		oCltBN0	:= CenCltBn0():New()

		oCltBN0:SetValue('referenceYear'			,Self:oEntity:getValue("referenceYear"))   
		oCltBN0:SetValue('commitmentCode'		,Self:oEntity:getValue("commitmentCode"))
		oCltBN0:SetValue('requirementCode'		,Self:oEntity:getValue("requirementCode"))
		oCltBN0:SetValue('operatorRecord'		,Self:oEntity:getValue("operatorRecord"))
		oCltBN0:SetValue('formProcDt'				,Self:oEntity:getValue("formProcDt"))
		oCltBN0:SetValue('batchCode'				,Self:oEntity:getValue("batchCode"))
		oCltBN0:SetValue('operatorFormNumber'	,Self:oEntity:getValue("operatorFormNumber"))
		oCltBN0:SetValue('certificateType'	,Self:oEntity:getValue("certificateType"))
		oCltBN0:SetValue('certificateNumber'	,Self:oEntity:getValue("certificateNumber"))

		If oCltBN0:bscChaPrim() 
			If !oCltBN0:hasNext()
				lRet := .F.
			EndIf 
		Else
			lRet	:= .F.
		EndIf 

		oCltBN0:Destroy()
		FreeObj(oCltBN0)
		oCltBN0 := nil

	EndIf 

Return  lRet
