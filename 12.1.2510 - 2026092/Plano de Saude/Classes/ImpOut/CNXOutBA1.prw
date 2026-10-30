#Include 'protheus.ch'

Class CNXOutBA1 From PrjOutCNX
	Data oCnxOutBqc
	Data oCnxOutBi3
	Data oCnxOutBts
	Data oCnxOutBA3

	Method new()
	Method buscar(oBenef,oClt)
	Method getChv(oBenef,oClt)
	Method save(oBenef)

EndClass

Method new() Class CNXOutBA1
	_Super:new()
Return self

Method buscar(oBenef,oClt) Class CNXOutBA1
	Local lSuccess := .F.
	oClt:setValue("BA1_CODCCO",oBenef:getValue("cco"))
	lSuccess := oClt:buscar()
Return lSuccess

//devolve a chave da tabela pegando ela do cache ou da tabela
Method getChv(oBenef,oClt) Class CNXOutBA1
	Local cMatric := ""
	If Empty(oBenef:getValue("ccoBeneficiarioTitular"))
		If !self:oCache:get(oBenef:getValue("cco"), @cMatric)
			cMatric := oClt:getNextMatric()
			self:oCache:set(oBenef:getValue("cco"),cMatric)
		EndIf
	Else
		If !self:oCache:get(oBenef:getValue("ccoBeneficiarioTitular"), @cMatric)
			cMatric := oClt:matByCco(oBenef:getValue("ccoBeneficiarioTitular"))
			self:oCache:set(oBenef:getValue("ccoBeneficiarioTitular"),cMatric)
		EndIf
	EndIf
Return cMatric

Method save(oBenef) Class CNXOutBA1
	Local lSuccess := .T.
	Local lInclui := .T.
	Local oCltBA1 := PlsCltBA1():new() //BA1_FILIAL+BA1_CODCCO
	Local cTipReg := ""
	Local cMatric := ""
	Local cMatVida := ""
	Local cSub := ""
	Local cProd := ""

	lInclui := !self:buscar(oBenef,oCltBA1)
	If lInclui .OR. !self:lSoInclui
		If lInclui
			oCltBA1:setValue("operator",self:cCodOpe)
			oCltBA1:setValue("companyCode",self:cCodEmp)
			oCltBA1:setValue("companyContract",self:cNumCon)
			oCltBA1:setValue("contractVersion",self:cVerCon)

			//buscar subcontrato no cache ou da BQC
			cSub := self:oCnxOutBqc:getChv(oBenef)
			oCltBA1:setValue("subContract",SubStr(cSub,1,9))
			oCltBA1:setValue("subContractVersion",SubStr(cSub,10,3))
			oBenef:setValue("subContrato",SubStr(cSub,1,9))
			oBenef:setValue("versaoSubContrato",SubStr(cSub,10,3))
			//pegar produto do cache ou da BI3
			cProd := self:oCnxOutBi3:getChv(oBenef)
			oCltBA1:setValue("planCode",SubStr(cProd,1,4))
			oCltBA1:setValue("planVersion",SubStr(cProd,5,3))
			oBenef:setValue("plano",SubStr(cProd,1,4))
			oBenef:setValue("versaoPlano",SubStr(cProd,5,3))
			//pegar matvid do cache ou da BTS
			cMatVida := self:oCnxOutBts:getChv(oBenef)
			oCltBA1:setValue("lifeRegistration",cMatVida)
			//pegar matricula do cache ou gerar uma nova
			cMatric := self:getChv(oBenef,oCltBA1)
			oCltBA1:setValue("beneficiaryRegistration",cMatric)
			oBenef:setValue("matricula",cMatric)
			oCltBA1:setValue("beneficiaryType",IIf(Empty(oBenef:getValue("ccoBeneficiarioTitular")),"T","D"))
			oCltBA1:setValue("kinshipDegree",StrZero(Val(oBenef:getValue("relacaoDependencia")),2))
			//calcular campos
			cTipReg := IIf(oCltBA1:getValue("beneficiaryType") == "T", "00",oCltBA1:nextTipReg())
			oCltBA1:setValue("recordType",cTipReg)
			oCltBA1:setValue("digit",Modulo11(self:cCodOpe+self:cCodEmp+oCltBA1:getValue("BA1_MATRIC")+cTipReg) )
			oCltBA1:setValue("blockDate",SToD(strTran(oBenef:getValue("dataCancelamento"),"-","")))
			oCltBA1:setValue("reasonForBlocking",oBenef:getValue("motivoCancelamento"))//"dataReativacao"
			oCltBA1:setValue("image","ENABLE")
			oCltBA1:setValue("formerRegistration",oBenef:getValue("codigoBeneficiario"))
			oCltBA1:setValue("beneficiaryCpf",oBenef:getValue("cpf"))
			oCltBA1:setValue("dateOfBirth",SToD(strTran(oBenef:getValue("dataNascimento"),"-","")))
			oCltBA1:setValue("dateOfAdditionOfUser",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
			oCltBA1:setValue("waitPeriodBaseDate",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
			oCltBA1:setValue("maritalStatus","O")
			oCltBA1:setValue("motherSName",oBenef:getValue("nomeMae"))
			oCltBA1:setValue("beneficiaryName",oBenef:getValue("nome"))
			oCltBA1:setValue("pisPasepNumber",oBenef:getValue("pisPasep"))
			oCltBA1:setValue("sex",IIf(oBenef:getValue("sexo")=="1","1","2"))
			oCltBA1:setValue("beneficiaryZipCode",oBenef:getValue("cep"))
			oCltBA1:setValue("beneficiaryAddress",oBenef:getValue("logradouro"))
			oCltBA1:setValue("addressNumber",oBenef:getValue("numero"))
			oCltBA1:setValue("addressComplement",oBenef:getValue("complemento"))
			oCltBA1:setValue("beneficiaryDistrict",oBenef:getValue("bairro"))
			oCltBA1:setValue("beneficiaryCity",oBenef:getValue("codigoMunicipio"))
			oCltBA1:setValue("cityCode",oBenef:getValue("codigoMunicipioResidencia"))
			oCltBA1:setValue("originOfAddress","4")
			oCltBA1:setValue("newborn","0")
			oCltBA1:setValue("considerAns","1")

		EndIf
		lSuccess := oCltBA1:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir o beneficiario " + oBenef:getValue("cco") + CRLF + oCltBA1:getError())
		lSuccess := self:oCnxOutBA3:save(oBenef)
		self:tryExec(lSuccess, self:oCnxOutBA3:getError())
	EndIf
	oCltBA1:destroy()
	FreeObj(oCltBA1)
	oCltBA1 := nil
Return lSuccess