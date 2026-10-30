#Include 'protheus.ch'

Class CNXOutBI3 From PrjOutCNX

	Method new()
	Method buscar(oBenef,oClt)
	Method getChv(oBenef)
	Method save(oBenef)

EndClass

Method new() Class CNXOutBI3
	_Super:new()
Return self

Method buscar(oBenef,oClt) Class CNXOutBI3
	Local lSuccess := .F.
	oClt:setValue("ansRegistrationNumber",oBenef:getValue("numeroPlanoANS"))
	lSuccess := oClt:buscar()
Return lSuccess

//devolve a chave da tabela pegando ela do cache ou da tabela
Method getChv(oBenef) Class CNXOutBI3
	Local cProd := ""
	If !self:oCache:get(oBenef:getValue("numeroPlanoANS"),@cProd)
		oCltBI3 := PlsCltBI3():new() //BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
		oCltBI3:setValue("ansRegistrationNumber",oBenef:getValue("numeroPlanoANS"))
		If oCltBI3:buscar()
			self:oCache:set(oBenef:getValue("numeroPlanoANS"),oCltBI3:getValue("productCode")+oCltBI3:getValue("version"))
		EndIf
		oCltBI3:destroy()
		FreeObj(oCltBI3)
		oCltBI3 := nil
	EndIf
Return cProd

Method save(oBenef) Class CNXOutBI3
	Local lSuccess := .T.
	Local oCltBI3 := PlsCltBI3():new() //BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
	Local oCltBIL := nil
	Local oCltBJ3 := nil
	lInclui := !self:buscar(oBenef, oCltBI3)
	If lInclui .OR. !self:lSoInclui
		If lInclui
			oCltBI3:setValue("productDescription","PRODUTO " + oBenef:getValue("numeroPlanoANS"))
			oCltBI3:setValue("BI3_NsummarDescriptREDUZ",oBenef:getValue("numeroPlanoANS"))
			oCltBI3:setValue("operator",self:cCodOpe)
			oCltBI3:setValue("productCode",oCltBI3:getNextCodigo())
			oCltBI3:setValue("BI3_CODFOR","001")
			oCltBI3:setValue("class","001")
			oCltBI3:setValue("version","001")
			oCltBI3:setValue("productGroup","001")
			oCltBI3:setValue("scope","01")
			oCltBI3:setValue("segment","001")
			oCltBI3:setValue("contractType","1")
			oCltBI3:setValue("allRda","1")
			oCltBI3:setValue("allAccredited","1")
			oCltBI3:setValue("allUsers","1")
			oCltBI3:setValue("considerProcStandard","1")
			oCltBI3:setValue("planOwner","1")
			oCltBI3:setValue("planType","3")
			oCltBI3:setValue("considerAns","1")
			oCltBI3:setValue("inclusionDate",CtoD("01/01/01"))
			oCltBI3:setValue("planStatus","1")
			oCltBI3:setValue("blockDate",CtoD("  /  /  "))
			oCltBI3:setValue("dailyInterest",0)
			oCltBI3:setValue("chargeInterestSameMont","0")
			oCltBI3:setValue("dailyInterestValue",0)
			oCltBI3:setValue("calcProRataCollection","0")
			oCltBI3:setValue("pRataExitFMajority","0")
			oCltBI3:setValue("chargeProRataOnOutflo","0")
			oCltBI3:setValue("scpaCode","")
			oCltBI3:setValue("paymentMode","1")
			oCltBI3:setValue("ruled","1")
			oCltBI3:setValue("accommodationCode","01")
			oCltBI3:setValue("coParticipation","1")
			oCltBI3:setValue("productRegistrDate",CtoD("01/01/01"))
			oCltBI3:setValue("productApprovDate",CtoD("01/01/01"))
			oCltBI3:setValue("changeRange","1")
			oCltBI3:setValue("informCoverage","0")
			oCltBI3:setValue("informCoverageGroup","0")
			oCltBI3:setValue("enterSpCovUser","0")
			oCltBI3:setValue("adTxLimValue",999)
			oCltBI3:setValue("comfortStandard","000001")
			oCltBI3:setValue("contractModel","1")
			oCltBI3:setValue("valueOfDupliOfDocket",0)
			oCltBI3:setValue("contractLegalClass","4")
			oCltBI3:setValue("accommodationMultFactor",0)
			oCltBI3:setValue("highRiskProduct","0")
			oCltBI3:setValue("monthlyFeeDiscount",0)
			oCltBI3:setValue("individualCollectMode","0")
			oCltBI3:setValue("billingMethod","2")
			oCltBI3:setValue("allowRefund","0")
			lSuccess := oCltBI3:commit(lInclui)
			self:tryExec(lSuccess, "Não foi possível incluir o produto " + oBenef:getValue("numeroPlanoANS") + CRLF + oCltBI3:getError())
			oCltBIL := PlsCltBIL():new()
			oCltBIL:setValue("companyType",self:cCodOpe+oCltBI3:getValue("BI3_CODIGO"))
			oCltBIL:setValue("version","001")
			oCltBIL:setValue("versionInitialDate",CtoD("01/01/01"))
			lSuccess := oCltBIL:commit(!oCltBIL:buscar())
			self:tryExec(lSuccess, "Não foi possível incluir a versão do produto " + oBenef:getValue("numeroPlanoANS") + CRLF + oCltBIL:getError())
			oCltBJ3 := PlsCltBJ3():new()
			oCltBJ3:setValue("companyType",self:cCodOpe+oCltBI3:getValue("BI3_CODIGO"))
			oCltBJ3:setValue("version","001")
			oCltBJ3:setValue("collectionMode","101")
			lSuccess := oCltBJ3:commit(!oCltBJ3:buscar())
			self:tryExec(lSuccess, "Não foi possível incluir a forma de pagamento do produto " + oBenef:getValue("numeroPlanoANS") + CRLF + oCltBJ3:getError())
			oCltBIL:destroy()
			FreeObj(oCltBIL)
			oCltBIL := nil
			oCltBJ3:destroy()
			FreeObj(oCltBJ3)
			oCltBJ3 := nil
		EndIf
	EndIf
	self:oCache:set(oBenef:getValue("numeroPlanoANS"),oCltBI3:getValue("BI3_CODIGO")+oCltBI3:getValue("BI3_VERSAO"))
	oCltBI3:destroy()
	FreeObj(oCltBI3)
	oCltBI3 := nil
Return lSuccess
