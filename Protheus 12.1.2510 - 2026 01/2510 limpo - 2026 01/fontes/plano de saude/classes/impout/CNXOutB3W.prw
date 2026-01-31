#Include 'protheus.ch'

Class CNXOutB3W From PrjOutCNX
	Data lCaepf

	Method new()
	Method save(oBenef)

EndClass

Method new() Class CNXOutB3W
	_Super:new()
	self:lCaepf	:= B3W->(FieldPos("B3W_CAEPF")) > 0
Return self

Method save(oBenef) Class CNXOutB3W
	Local lSuccess := .T.
	Local lInclui := .F.
	oCltB3W := CenCltB3W():new()
	oCltB3W:setValue("operatorRecord",oBenef:getValue("registroANS"))
	oCltB3W:setValue("operationControlCode",oBenef:getValue("cco"))
	lInclui := !oCltB3W:bscChaPrim()

	/* Atributos */
	oCltB3W:setValue("statusAns",oBenef:getValue("situacao"))

	/* Identificacao */
	oCltB3W:setValue("cpf",oBenef:getValue("cpf"))
	oCltB3W:setValue("declaredBornAlive",oBenef:getValue("dn"))
	oCltB3W:setValue("pisPasep",oBenef:getValue("pisPasep"))
	oCltB3W:setValue("cnsNumber",oBenef:getValue("cns"))
	oCltB3W:setValue("benefitedName",oBenef:getValue("nome"))
	oCltB3W:setValue("benefitedGender",oBenef:getValue("sexo"))
	oCltB3W:setValue("birthDate",SToD(strTran(oBenef:getValue("dataNascimento"),"-","")))
	oCltB3W:setValue("motherName",oBenef:getValue("nomeMae"))

	/* Endereco */
	oCltB3W:setValue("publicArea",oBenef:getValue("logradouro"))
	oCltB3W:setValue("addressNumber",oBenef:getValue("numero"))
	oCltB3W:setValue("addressComplement",oBenef:getValue("complemento"))
	oCltB3W:setValue("district",oBenef:getValue("bairro"))
	oCltB3W:setValue("cityCode",oBenef:getValue("codigoMunicipio"))
	oCltB3W:setValue("resCityCode",oBenef:getValue("codigoMunicipioResidencia"))
	oCltB3W:setValue("zipCode",oBenef:getValue("cep"))
	oCltB3W:setValue("addressType",oBenef:getValue("tipoEndereco"))
	oCltB3W:setValue("livingAbroad",oBenef:getValue("resideExterior"))

	/* Vinculo */
	oCltB3W:setValue("benefitedRegistration",oBenef:getValue("codigoBeneficiario"))
	oCltB3W:setValue("dependenceRelation",oBenef:getValue("relacaoDependencia"))
	oCltB3W:setValue("holderCode",oBenef:getValue("ccoBeneficiarioTitular"))
	oCltB3W:setValue("additionDt",SToD(strTran(oBenef:getValue("dataContratacao"),"-","")))
	oCltB3W:setValue("reactivationDate",SToD(strTran(oBenef:getValue("dataReativacao"),"-","")))
	oCltB3W:setValue("blockDt",SToD(strTran(oBenef:getValue("dataCancelamento"),"-","")))
	oCltB3W:setValue("blockReason",oBenef:getValue("motivoCancelamento"))
	oCltB3W:setValue("codeSusep",oBenef:getValue("numeroPlanoANS"))
	oCltB3W:setValue("originPlan",oBenef:getValue("numeroPlanoPortabilidade"))
	oCltB3W:setValue("codeScpa",oBenef:getValue("numeroPlanoOperadora"))
	oCltB3W:setValue("tempPartialCoverage",oBenef:getValue("coberturaParcialTemporaria"))
	oCltB3W:setValue("itemsExcludedFromCover",oBenef:getValue("itensExcluidosCobertura"))
	oCltB3W:setValue("cnpjContractor",oBenef:getValue("cnpjEmpresaContratante"))
	oCltB3W:setValue("ceiContractor",oBenef:getValue("ceiEmpresaContratante"))
	If self:lCaepf
		oCltB3W:setValue("B3W_CAEPF",oBenef:getValue("caepfEmpresaContratante"))
	EndIf
	lSuccess := oCltB3W:commit(lInclui)
	self:tryExec(lSuccess, "Não foi possível incluir a operadora " + oBenef:getValue("registroANS") + CRLF + oCltB3W:getError())
	oCltB3W:destroy()
	FreeObj(oCltB3W)
	oCltB3W := nil
Return lSuccess
