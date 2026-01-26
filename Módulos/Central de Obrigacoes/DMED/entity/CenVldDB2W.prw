#Include "TOTVS.CH"
#DEFINE INVALIDO		"3" // Invalido

//-------------------------------------------------------------------
/*/{Protheus.doc} CenVldDB2W
Descricao:  Classe Responsavel por Validar as Criticas da Obrigação
				.-> DMED

@author lima.everton
@since 11/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CenVldDB2W From CenVldCrit

	Method New() Constructor
	Method initCritInd()
	Method initCritGrp()
	Method vldGrupo(oCollection)

EndClass

Method New() Class CenVldDB2W
	_Super:new()
Return Self

Method initCritInd() Class CenVldDB2W
	Self:aCritInd := {}
	aAdd(self:aCritInd,CritDCpfTit():New())
	aAdd(self:aCritInd,CritDCNPJCP():New())
	aAdd(self:aCritInd,CritDCpfBen():New())
	aAdd(self:aCritInd,CritDValTit():New())
Return

Method initCritGrp() Class CenVldDB2W
	Self:aCritGrp := {}
	aAdd(self:aCritGrp,CritDNomBen():New())
	aAdd(self:aCritGrp,CritDNomPre():New())
	aAdd(self:aCritGrp,CritDRelDep():New())
	aAdd(self:aCritGrp,CritDReRTop():New())
	aAdd(self:aCritGrp,CritDDtNas():New())
	aAdd(self:aCritGrp,CritDReDtop():New())
	aAdd(self:aCritGrp,CritDRRDTop():New())
	aAdd(self:aCritGrp,CritDResArq():New())

Return

Method vldGrupo(oCollection) Class CenVldDB2W
	Local lValido		:= .T.
	Local aCriticas 	:= self:getCritGrp()
	Local nLen 			:= len(aCriticas)
	Local oCltCrit		:= CenCltCrit():New()
	Local nCritica		:= 0
	Local cConcat     := IIf(SubStr(Alltrim(Upper(TCGetDb())),1,5) == "MSSQL","+","||")

	For nCritica := 1 to nLen

		oCltCrit:setValue("operatorRecord",self:getOper())
		oCltCrit:setValue("requirementCode",self:getObrig())
		oCltCrit:setValue("commitReferenceYear",self:getAno())
		oCltCrit:setValue("commitmentCode",self:getComp())
		oCltCrit:setValue("reviewOrigin",aCriticas[nCritica]:getAlias())
		oCltCrit:setValue("reviewCode",aCriticas[nCritica]:getCodCrit())
		oCltCrit:ajuCriStatus("B2W_CODOPE"+cConcat+"B2W_CODOBR"+cConcat+"B2W_ANOCMP"+cConcat+"B2W_CDCOMP"+cConcat+"B2W_CPFTIT"+cConcat+"B2W_CPFBEN"+cConcat+"B2W_DTNASD"+;
			cConcat+"B2W_NOMBEN"+cConcat+"B2W_CPFPRE"+cConcat+"B2W_IDEREG")

		oCltCrit:lmpCriticas()

		aCriticas[nCritica]:setOper(self:getOper())
		aCriticas[nCritica]:setObrig(self:getObrig())
		aCriticas[nCritica]:setAno(self:getAno())
		aCriticas[nCritica]:setComp(self:getComp())
		lValido := oCltCrit:insCritGrp(aCriticas[nCritica]:getQryCrit())
		If oCollection <> nil
			oCollection:atuStatGrp(INVALIDO,aCriticas[nCritica]:getAlias(),aCriticas[nCritica]:getWhereCrit())
		EndIf
	Next nCritica

Return lValido