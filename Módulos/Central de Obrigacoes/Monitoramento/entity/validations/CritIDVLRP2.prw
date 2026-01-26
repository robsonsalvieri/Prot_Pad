#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIDVLRP2
Descricao: 	Critica referente ao Campo.
				-> B9T_IDVLRP
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIDVLRP2 From CriticaB3F
	Method New() Constructor
	Method Validar()
EndClass

Method New() Class CritIDVLRP2
	_Super:New()
	self:setAlias('B9T')
	self:setCodCrit('M080')
	self:setMsgCrit('O Identificador de contratação por valor pré-estabelecido é inválido.')
	self:setSolCrit('Preencha corretamente o campo com o Número atribuído pela operadora para identificar uma contratação por valor pré-estabelecido, na qual o valor contratado independe da realização de serviços.')
	self:setCpoCrit('B9T_IDVLRP')
	self:setCodAns('5053')
Return Self

Method Validar() Class CritIDVLRP2
	
	Local lRet		:= .T.
	Local oColB9T 	:= CenCltB9T():New()
	
	oColB9T:setValue("operatorRecord",self:oEntity:getValue("operatorRecord")) //B9T_CODOPE
	oColB9T:setValue("requirementCode",self:oEntity:getValue("requirementCode")) //B9T_CDOBRI
	oColB9T:setValue("referenceYear",self:oEntity:getValue("referenceYear")) //B9T_ANO
	oColB9T:setValue("commitmentCode",self:oEntity:getValue("commitmentCode")) //B9T_CDCOMP
	oColB9T:setValue("monitoringRecordType",self:oEntity:getValue("monitoringRecordType")) //B9T_TPRGMN
	oColB9T:setValue("presetValueIdent",self:oEntity:getValue("presetValueIdent")) //B9T_IDVLRP
	lRet := oColB9T:getQtdIdVPre() <= 1
	oColB9T:destroy()

Return lRet
