#Include 'protheus.ch'

Class CNXOutBA0 From PrjOutCNX

	Method new()
	Method save(oBenef)

EndClass

Method new() Class CNXOutBA0
	_Super:new()
Return self

Method save(oBenef) Class CNXOutBA0
	Local lSuccess := .T.
	Local lInclui := .F.
	oCltBA0 := PlsCltBA0():new()
	oCltBA0:setValue("ansRegistrationNumber",oBenef:getValue("registroANS"))
	lInclui := !oCltBA0:buscar()
	If lInclui
		oCltBA0:setValue("companyIdentCode",SubStr(self:cCodOpe,1,1))
		oCltBA0:setValue("operatorCode",SubStr(self:cCodOpe,2,3)) //TODO tornar esse numero dinamico
		oCltBA0:setValue("operatorName","Operadora " + oBenef:getValue("registroANS"))
		oCltBA0:setValue("operatorClass","01")
		oCltBA0:setValue("operatorGroup","01")
		oCltBA0:setValue("unit","01")
		oCltBA0:setValue("relationship","1")
		oCltBA0:setValue("slip2NdCopyValue",0)
		oCltBA0:setValue("oprCostStd",0)
		oCltBA0:setValue("dueDate",1)
		oCltBA0:setValue("typeOfDueDate","1")
		oCltBA0:setValue("oprCostDueDate",1)
		oCltBA0:setValue("tpOpCostDueDate","1")
		oCltBA0:setValue("onLineOperCia","0")
		oCltBA0:setValue("retroacLimitDay",0)
		oCltBA0:setValue("interAuthLimit",0)
		oCltBA0:setValue("validLevel","0")
		oCltBA0:setValue("totalActions",0)
		lSuccess := oCltBA0:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir a operadora " + oBenef:getValue("registroANS") + CRLF + oCltBA0:getError())
	Endif
	oCltBA0:destroy()
	FreeObj(oCltBA0)
	oCltBA0 := nil
Return lSuccess
