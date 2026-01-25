#Include 'protheus.ch'

Class CNXOutBQC From PrjOutCNX

	Method new()
	Method buscar(oBenef,oClt)
	Method getChv(oBenef)
	Method save(oBenef)

EndClass

Method new() Class CNXOutBQC
	_Super:new()
Return self

Method buscar(oBenef,oClt) Class CNXOutBQC
	Local lSuccess := .F.

	oClt:setValue("BQC_CODIGO",self:cCodOpe+self:cCodCon)
	oClt:setValue("BQC_CODINT",self:cCodOpe)
	oClt:setValue("BQC_CODEMP",self:cCodEmp)
	oClt:setValue("BQC_NUMCON",self:cNumCon)
	oClt:setValue("BQC_VERCON",self:cVerCon)
	If !Empty(oBenef:getValue("cnpjEmpresaContratante"))
		oClt:setValue("BQC_CNPJ",oBenef:getValue("cnpjEmpresaContratante"))
	ElseIf !Empty(oBenef:getValue("ceiEmpresaContratante"))
		oClt:setValue("BQC_CEINSS",oBenef:getValue("ceiEmpresaContratante"))
	ElseIf !Empty(oBenef:getValue("caepfEmpresaContratante"))
		oClt:setValue("BQC_CAEPF",oBenef:getValue("caepfEmpresaContratante"))
	EndIf
	lSuccess := oClt:buscar()
Return lSuccess

//devolve a chave da tabela pegando ela do cache ou da tabela
Method getChv(oBenef) Class CNXOutBQC
	Local cChave := ""
	Local cChaveEmp := ""
	//buscar subcontrato no cache ou da tabela
	If !Empty(oBenef:getValue("cnpjEmpresaContratante"))
		cChaveEmp := oBenef:getValue("cnpjEmpresaContratante")
	ElseIf !Empty(oBenef:getValue("ceiEmpresaContratante"))
		cChaveEmp := oBenef:getValue("ceiEmpresaContratante")
	ElseIf !Empty(oBenef:getValue("caepfEmpresaContratante"))
		cChaveEmp := oBenef:getValue("caepfEmpresaContratante")
	EndIf
	If !self:oCache:get(cChaveEmp,@cChave)
		oCltBQC := PlsCltBQC():new() //BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
		If self:buscar(oBenef,oCltBQC)
			self:oCache:set(cChaveEmp,oCltBQC:getValue("subContract")+oCltBQC:getValue("subContractVersion"))
		EndIf
		oCltBQC:destroy()
		FreeObj(oCltBQC)
		oCltBQC := nil
	EndIf
Return cChave

Method save(oBenef) Class CNXOutBQC
	Local lSuccess := .T.
	Local lInclui := .F.
	Local cDesc	:= ""
	Local cChave	:= ""
	Local oCltBQC := PlsCltBQC():new() //BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
	lInclui := !self:buscar(oBenef,oCltBQC)
	If lInclui .OR. !self:lSoInclui
		If !Empty(oBenef:getValue("cnpjEmpresaContratante"))
			cDesc := "SUB CONTRATO CNPJ " + oBenef:getValue("cnpjEmpresaContratante")
			cChave := oBenef:getValue("cnpjEmpresaContratante")
		ElseIf !Empty(oBenef:getValue("ceiEmpresaContratante"))
			cDesc := "SUB CONTRATO CEI " + oBenef:getValue("ceiEmpresaContratante")
			cChave := oBenef:getValue("ceiEmpresaContratante")
		ElseIf !Empty(oBenef:getValue("caepfEmpresaContratante"))
			cDesc := "SUB CONTRATO CAEPF " + oBenef:getValue("caepfEmpresaContratante")
			cChave := oBenef:getValue("caepfEmpresaContratante")
		EndIf
		oCltBQC:setValue("subContractDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
		oCltBQC:setValue("description",cDesc)
		If lInclui
			oCltBQC:setValue("subContract",oCltBQC:nextSubCon())
			oCltBQC:setValue("subContractVersion","001")
			oCltBQC:setValue("chargeThisLevel","0")
			oCltBQC:setValue("allowsRefund","1")
			oCltBQC:setValue("discCont",0)
			oCltBQC:setValue("dueDateType","1")
			oCltBQC:setValue("dueDate",0)
			oCltBQC:setValue("operCostDueDateType","1")
			oCltBQC:setValue("operationalCostMaturity",1)
			oCltBQC:setValue("allowEditingDueDate","1")
			oCltBQC:setValue("noCharge","0")
			oCltBQC:setValue("chargeRetroactive","0")
			oCltBQC:setValue("calculateProRataCollec","0")
			oCltBQC:setValue("retroactLimitDay",0)
			oCltBQC:setValue("consideraCompetence","0")
			oCltBQC:setValue("sponsor","0")
			oCltBQC:setValue("secondCopyOfSlip",0)
			oCltBQC:setValue("adjustmentPeriodicity","12")
			oCltBQC:setValue("collectionLocation","1")
			oCltBQC:setValue("notifyAns","1")
			oCltBQC:setValue("issueMagneticCard","1")
			oCltBQC:setValue("allowToBuyProced","1")
			oCltBQC:setValue("periodOfRenewingWait",0)
			oCltBQC:setValue("callQuestionnaire","0")
			oCltBQC:setValue("chLimitInForm",0)
			oCltBQC:setValue("respPrchsPformsPgImm","1")
			oCltBQC:setValue("hadOtherEntries","0")
			oCltBQC:setValue("checkFinancialRules","1")
			oCltBQC:setValue("checkOperGrpRules","0")
			oCltBQC:setValue("chargeInterNextMonth","0")
			oCltBQC:setValue("dailyInterestPercentage",0)
			oCltBQC:setValue("dailyInterestAmount",0)
			oCltBQC:setValue("majority",0)
			oCltBQC:setValue("generateFormViaPos","1")
			oCltBQC:setValue("reasonForIndexation","REAJUSTE CONFORME CLAUSULA CONTRATUAL")
			oCltBQC:setValue("indexationCharact","4")
			oCltBQC:setValue("lineIndexation","1")
			oCltBQC:setValue("numberOfUs",0)
			oCltBQC:setValue("period",0)
			oCltBQC:setValue("monthsForSettlelm",0)
			oCltBQC:setValue("minimumValue",0)
			oCltBQC:setValue("minimumPercentage",0)
			oCltBQC:setValue("installmentValue",0)
			oCltBQC:setValue("minInstallm",0)
			oCltBQC:setValue("monthsNumber",0)
			oCltBQC:setValue("sponsorship",0)
			oCltBQC:setValue("nrOfDefaultDays",0)
			oCltBQC:setValue("patronalReimbrsmttblcode","000001")

			oCltBQD := PlsCltBQD():new()
			oCltBQD:setValue("code",self:cCodOpe+self:cCodEmp)
			oCltBQD:setValue("groupCompanyGroup",self:cNumCon)
			oCltBQD:setValue("version",self:cVerCon)
			oCltBQD:setValue("subContract",oCltBQC:getValue("subContract"))
			oCltBQD:setValue("subContractVersion",oCltBQC:getValue("subContractVersion"))
			oCltBQD:setValue("versionInitialDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
			lSuccess := oCltBQD:commit(!oCltBQD:bscChaPrim())
			self:tryExec(lSuccess, "Não foi possível incluir a versão do contrato " + self:cCodEmp + CRLF + oCltBQD:getError())
			oCltBQD:destroy()
			FreeObj(oCltBQD)
			oCltBQD := nil
		EndIf

		lSuccess := oCltBQC:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir a empresa " + oBenef:getValue("registroANS") + CRLF + oCltBQC:getError())
	EndIf
	self:oCache:set(cChave,oCltBQC:getValue("subContract")+oCltBQC:getValue("subContractVersion"))
	oCltBQC:destroy()
	FreeObj(oCltBQC)
	oCltBQC := nil
Return lSuccess
