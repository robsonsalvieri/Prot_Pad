#Include 'protheus.ch'

Class CNXOutBG9 From PrjOutCNX

	Method new()
	Method save(oBenef)

EndClass

Method new() Class CNXOutBG9
	_Super:new()
Return self

Method save(oBenef) Class CNXOutBG9
	Local lSuccess := .T.
	Local lInclui := .F.
	Local oCltBG9 := PlsCltBG9():new() //BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
	oCltBG9:setValue("operator",self:cCodOpe)
	oCltBG9:setValue("code",self:cCodEmp)
	oCltBG9:setValue("groupType","2")
	lInclui := !oCltBG9:buscar()
	If lInclui
		oCltBG9:setValue("descrOfGroupCompanyC","Empresa CNX")
		oCltBG9:setValue("supplierStore","01")
		oCltBG9:setValue("dueDate",10)
		oCltBG9:setValue("use","1")
		oCltBG9:setValue("userMinCollecValue",0)
		oCltBG9:setValue("chargeInterestNextMont","0")
		oCltBG9:setValue("dailyInterest",0)
		oCltBG9:setValue("dailyInterestValue",0)
		oCltBG9:setValue("majority",0)
		lSuccess := oCltBG9:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir a empresa " + oBenef:getValue("registroANS") + CRLF + oCltBG9:getError())
	Endif
	oCltBG9:destroy()
	FreeObj(oCltBG9)
	oCltBG9 := nil
Return lSuccess
