#Include 'protheus.ch'

Class CNXOutBA3 From PrjOutCNX

	Method new()
	Method save(oBenef)

EndClass

Method new() Class CNXOutBA3
	_Super:new()
Return self

Method save(oBenef) Class CNXOutBA3
	Local lSuccess := .T.
	Local lInclui := .T.
	Local oCltBA3 := PlsCltBA3():new() //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
	oCltBA3:setValue("operator",self:cCodOpe)
	oCltBA3:setValue("groupCompany",self:cCodEmp)
	oCltBA3:setValue("registration",oBenef:getValue("matricula"))
	oCltBA3:setValue("companyContract",self:cNumCon)
	oCltBA3:setValue("contractVersion",self:cVerCon)
	oCltBA3:setValue("subContract",oBenef:getValue("subContrato"))
	oCltBA3:setValue("subContractVersion",oBenef:getValue("versaoSubContrato"))

	lInclui := !oCltBA3:buscar()
	If lInclui .OR. !self:lSoInclui
		oCltBA3:setValue("zip",oBenef:getValue("cep"))
		oCltBA3:setValue("address",oBenef:getValue("logradouro"))
		oCltBA3:setValue("number",oBenef:getValue("numero"))
		oCltBA3:setValue("complement",oBenef:getValue("complemento"))
		oCltBA3:setValue("district",oBenef:getValue("bairro"))
		oCltBA3:setValue("cityCode",oBenef:getValue("codigoMunicipio"))
		oCltBA3:setValue("additionDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
		oCltBA3:setValue("adjustmentDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
		oCltBA3:setValue("dateOfTyping",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
		If lInclui
			oCltBA3:setValue("planCode",oBenef:getValue("plano"))
			oCltBA3:setValue("version",oBenef:getValue("versaoPlano"))
			oCltBA3:setValue("dueDate",1)
			oCltBA3:setValue("allowReimburs","1")
			oCltBA3:setValue("adjustmentMonth","01")
			oCltBA3:setValue("storeCode","01")
			oCltBA3:setValue("contractType","2")
			oCltBA3:setValue("store","01")
			oCltBA3:setValue("paymentMode","101")
			oCltBA3:setValue("paymentModality","1")
			oCltBA3:setValue("collectionLocation","1")
			oCltBA3:setValue("calculationRoutine","PLSPORFAI")
			oCltBA3:setValue("typePaymment","1")
		EndIf
		lSuccess := oCltBA3:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir a família do beneficiario " + oBenef:getValue("cco") + CRLF + oCltBA3:getError())
	EndIf
	oCltBA3:destroy()
	FreeObj(oCltBA3)
	oCltBA3 := nil
Return lSuccess
