#Include 'protheus.ch'

Class CNXOutBTS From PrjOutCNX

	Method new()
	Method buscar(oBenef,oClt)
	Method getChv(oBenef)
	Method save(oBenef)

EndClass

Method new() Class CNXOutBTS
	_Super:new()
Return self

Method buscar(oBenef,oClt) Class CNXOutBTS
	Local lSuccess := .F.

	If Empty(oBenef:getValue("cpf"))
		oClt:setValue("dateOfBirth",SToD(strTran(oBenef:getValue("dataNascimento"),"-","")))
		oClt:setValue("nameOfMother", oBenef:getValue("nomeMae"))
		oClt:setValue("name",oBenef:getValue("nome"))
	Else
		oClt:setValue("cpfCnpj",oBenef:getValue("cpf"))
	EndIf
	lSuccess := oClt:buscar()
Return lSuccess

//devolve a chave da tabela pegando ela do cache ou da tabela
Method getChv(oBenef) Class CNXOutBTS
	Local cChvVida := ""
	Local cMatVida := ""

	If Empty(oBenef:getValue("cpf"))
		cChvVida := oBenef:getValue("dataNascimento")+oBenef:getValue("nomeMae")+oBenef:getValue("nome")
	Else
		cChvVida := oBenef:getValue("cpf")
	EndIf
	If !self:oCache:get(cChvVida,@cMatVida)
		oCltBTS := PlsCltBTS():new() //BTS_FILIAL+cpfCnpj
		If self:buscar(oBenef,oCltBTS)
			self:oCache:set(cChvVida,oCltBTS:getValue("BTS_MATVID"))
		EndIf
		oCltBTS:destroy()
		FreeObj(oCltBTS)
		oCltBTS := nil
	EndIf
Return cMatVida

Method save(oBenef) Class CNXOutBTS
	Local lSuccess := .T.
	Local lInclui := .F.
	Local cChvVida := ""
	Local oCltBTS := PlsCltBTS():new() //BTS_FILIAL+cpfCnpj
	If Empty(oBenef:getValue("cpf"))
		cChvVida := oBenef:getValue("dataNascimento")+oBenef:getValue("nomeMae")+oBenef:getValue("nome")
	Else
		cChvVida := oBenef:getValue("cpf")
	EndIf
	lInclui := !self:buscar(oBenef,oCltBTS)
	If lInclui .OR. !self:lSoInclui
		If lInclui
			oCltBTS:setValue("lifeRegistration",oCltBTS:getNextMatVid())
			oCltBTS:setValue("typeOfPerson","F")
			oCltBTS:setValue("maritalStatus","O")
		EndIf
		oCltBTS:setValue("addressType",oBenef:getValue("tipoEndereco"))
		oCltBTS:setValue("livesAbroad",oBenef:getValue("resideExterior"))
		oCltBTS:setValue("userZipCode",oBenef:getValue("cep"))
		oCltBTS:setValue("userAddress",oBenef:getValue("logradouro"))
		oCltBTS:setValue("addressNumber",oBenef:getValue("numero"))
		oCltBTS:setValue("userDistrict",oBenef:getValue("bairro"))
		oCltBTS:setValue("userSCity",oBenef:getValue("codigoMunicipio"))
		oCltBTS:setValue("cityCode",oBenef:getValue("codigoMunicipioResidencia"))
		oCltBTS:setValue("addressComplement",oBenef:getValue("complemento"))
		oCltBTS:setValue("dateOfBirth",SToD(strTran(oBenef:getValue("dataNascimento"),"-","")))
		oCltBTS:setValue("statementOfLiveBirth",oBenef:getValue("dn"))
		oCltBTS:setValue("healthNationalCardNbr",oBenef:getValue("cns"))
		oCltBTS:setValue("nameOfMother", oBenef:getValue("nomeMae"))
		oCltBTS:setValue("name",oBenef:getValue("nome"))
		oCltBTS:setValue("pisPasedNumber",oBenef:getValue("pisPasep"))
		oCltBTS:setValue("sex",IIf(oBenef:getValue("sexo")=="1","1","2"))

		lSuccess := oCltBTS:commit(lInclui)
		self:tryExec(lSuccess, "Não foi possível incluir a vida " + oBenef:getValue("registroANS") + CRLF + oCltBTS:getError())
	EndIf
	self:oCache:set(cChvVida,oCltBTS:getValue("lifeRegistration"))
	oCltBTS:destroy()
	FreeObj(oCltBTS)
	oCltBTS := nil
Return lSuccess
