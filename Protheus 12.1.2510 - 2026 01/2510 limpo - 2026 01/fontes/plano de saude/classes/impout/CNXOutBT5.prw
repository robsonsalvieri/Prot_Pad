#Include 'protheus.ch'

Class CNXOutBT5 From PrjOutCNX

	Method new()
	Method save(oBenef)

EndClass

Method new() Class CNXOutBT5
	_Super:new()
Return self

Method save(oBenef) Class CNXOutBT5
	Local lSuccess := .T.
	Local lInclui := .F.
	Local oCltBT5 := PlsCltBT5():new() //BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO
	oCltBT5:setValue("operator",self:cCodOpe)
	oCltBT5:setValue("code",self:cCodCon)
	oCltBT5:setValue("contractNumber",self:cNumCon)
	oCltBT5:setValue("version",self:cVerCon)
	lInclui := !oCltBT5:buscar()
	If lInclui .OR. !self:lSoInclui
		oCltBT5:setValue("contractDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
		If lInclui
			oCltBT5:setValue("contractType","1"  )
			oCltBT5:setValue("chargeThisLevel","0")
			oCltBT5:setValue("store","01")
			oCltBT5:setValue("storeSupplier","01")
			oCltBT5:setValue("dueDate",0)
			oCltBT5:setValue("paymentMode","2")
			oCltBT5:setValue("notifyAns","1")
			oCltBT5:setValue("chargeInterNextMonth","0")
			oCltBT5:setValue("dailyInterestPercentage","0")
			oCltBT5:setValue("dailyInterestAmount","0")
			oCltBT5:setValue("majority","0")
			oCltBT5:setValue("allowReimburs","1")
			oCltBT5:setValue("nrOfDefaultDays","0")

			oCltBQB := PlsCltBQB():new()
			oCltBQB:setValue("code",self:cCodOpe+self:cCodEmp)
			oCltBQB:setValue("operatorCode",self:cCodOpe)
			oCltBQB:setValue("companyCode",self:cCodEmp)
			oCltBQB:setValue("groupCompanyGroup",self:cNumCon)
			oCltBQB:setValue("version",self:cVerCon)
			oCltBQB:setValue("versionInitialDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
			lSuccess := oCltBQB:commit(!oCltBQB:bscChaPrim())
			self:tryExec(lSuccess, "Não foi possível incluir a versão do contrato " + self:cCodEmp + CRLF + oCltBQB:getError())
			oCltBQB:destroy()
			FreeObj(oCltBQB)
			oCltBQB := nil
		Endif
		lSuccess := oCltBT5:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir a empresa " + oBenef:getValue("registroANS") + CRLF + oCltBT5:getError())
	EndIf
	oCltBT5:destroy()
	FreeObj(oCltBT5)
	oCltBT5 := nil
Return lSuccess
