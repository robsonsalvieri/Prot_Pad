#include "TOTVS.CH"
#include "PLSMGER.CH"

Class CalcCopart from AutAbstrata

	Data nValCopart
	Data cMsg

	Method New(hMap) Constructor

	Method calculate()
    Method getValCopart()
	Method getCodPad()
	Method getCodPro()
	Method getCodRDA()
	Method getEspec()
	Method getCodLoc()
	Method getQtd()
	Method getDatPro()
	Method getVerPgAto()
	Method getVlrNoAto()
	Method getTipoGuia()
	Method getNivAut()
	Method getChvAut()
	Method getRegAte()
	Method getMatric()
	Method getMes()
	Method getAno()
	Method hasProcedure(nSeq)

	Method sumValCopart(nValCopart)
EndClass

Method New(HMap) Class CalcCopart
	self:hMap := HMap
	self:nValCopart := 0
	self:cMsg := ''
Return self

//Atributos de retorno
Method getValCopart() Class CalcCopart
Return alltrim(str(self:nValCopart))

Method sumValCopart(nValCopart) Class CalcCopart
	self:nValCopart += nValCopart
Return

Method getCodPad() Class CalcCopart
Return self:get("procedureTableCode")

Method getCodPro() Class CalcCopart
Return self:get("procedureCode")

Method getCodRDA() Class CalcCopart
Return self:get("healthProviderId")

Method getEspec() Class CalcCopart
Return self:get("specialtyCode")

Method getCodLoc() Class CalcCopart
Return self:get("attendancePlaceId")

Method getQtd() Class CalcCopart
Return self:get("requestedQuantity")

Method getDatPro() Class CalcCopart
	Local cDatPro := self:get("authorizationDate")
	Local dDatPro := STOD(StrTran( cDatPro, "-", "" ))
Return dDatPro

Method getVerPgAto() Class CalcCopart
Return self:get("onlyActPay")

Method getVlrNoAto() Class CalcCopart
Return self:get("actValue")

Method getTipoGuia() Class CalcCopart
Return self:get("authType")

Method getNivAut() Class CalcCopart
Return self:get("authLevel")

Method getChvAut() Class CalcCopart
Return self:get("authLevelKey")

Method getRegAte() Class CalcCopart
Return self:get("regimenTreatment")

Method getMatric() Class CalcCopart
Return self:get("subscriberId")

Method getMes() Class CalcCopart
Return substr(self:get("authorizationDate"),6,2)

Method getAno() Class CalcCopart
Return substr(self:get("authorizationDate"),1,4)

Method hasProcedure(nSeq) Class CalcCopart
Return !empty(self:get("procedures[" + alltrim(str(nSeq)) + "].procedureCode"))

Method calculate() Class CalcCopart
	
	Local aRet := {}
	Local aDadUsr := {}
	Local lRet := .F.
	Local cCodPad := ''
	Local cCodPro := ''
	Local nQtdSol := 0
	Local cNivAut := ''
	Local cChvNiv := ''
	Local nI := 0

	aDadUsr := PLSDADUSR(self:getMatric(), "1", .F., self:getDatPro())

	if aDadUsr[1] //Checa se os dados do beneficiario sao validos
		/*
			- Cada procedimento possui a seguinte estrutura:
			"tableCode": "99",
			"procedureCode": "99999999",
			"requestedQuantity": 1,
			"authLevel": "BTQ",
			"authLevelKey": "2210101020"			
		*/
		while self:hasProcedure(nI)
			
			cCodPad := self:get('procedures[' + alltrim(str(nI)) + '].tableCode')
			cCodPro := self:get('procedures[' + alltrim(str(nI)) + '].procedureCode')
			nQtdSol := self:get('procedures[' + alltrim(str(nI)) + '].requestedQuantity')
			cNivAut := self:get('procedures[' + alltrim(str(nI)) + '].authLevel')
			cChvNiv := self:get('procedures[' + alltrim(str(nI)) + '].authLevelKey')

			if !empty(cCodPad) //De/para codigo tabela do procedimento
				cCodPad := allTrim(PLSVARVINC('87','BR4',cCodPad))
			endif
			aRet := PLSCALCCOP(cCodPad, cCodPro, self:getMes(), self:getAno(), ;
						self:getCodRDA(), self:getEspec(),/*cSubEsp*/, self:getCodLoc(), nQtdSol, ;
						self:getDatPro(), self:getVerPgAto(),/*cObsoleto*/,/*nVlrEve*/,/*cGrpInt*/,aDadUsr, ;
						/*cPadInt*/, /*cPadCon*/, /*aQtdPer*/, self:getRegAte(),/*nVlrApr*/, self:getVlrNoAto(), ;
						/*lCompra*/, /*cHorPro*/,/*aRdas*/, /*cOpeRda*/, /*cTipPrefor*/, /*cProRel*/,/*nPrPrRl*/,;
						/*aValAcu*/, cNivAut, cChvNiv, /*dDatCir*/, /*cHorCir*/,/*cCid*/,;
						/*aUnidsBlo*/,self:getTipoGuia(), /*aCobAcu*/, /*nVlrAprPag*/,/*aVlBloq*/, /*cModCob*/,;
						/*nVlrPagBru*/, /*nRegBD6*/, /*lCirurgico*/, /*nPerVia*/, /*cRegPag*/,/*cRegCob*/,;
						/*nNOTUSED1*/, /*nNOTUSED2*/, /*aPacote*/,/*cChaveGui*/,/*cSequen*/, /*aRetCom*/,;
						/*cRegInt*/,/*cFinAte*/, /*aVetPag*/, /*cChaveLib*/,/*lAuditoria*/,/*cDente*/,/*cFaces*/,;
						.F.,/*cHorPro6C*/,/*lAneste*/, /*nVlrPagLiq*/,/*cTipAdm*/)

			if len(aRet) >= 2
				if aRet[1]
					self:sumValCopart(aRet[12]) //Soma valor de copart
					lRet := .T.
				else
					self:cMsg += cCodPad+"-"+cCodPro + " - " + aRet[2] +". "
				endif
			else
				self:cMsg += cCodPad+"-"+cCodPro + " - " + 'Houve um erro no calculo do procedimento ' + cCodPad + cCodPro + '. '
			endif

			nI++
		enddo
	
		if nI == 0
			self:cMsg := 'Nenhum procedimento foi informado.'
			lRet := .F.
		endif
	else
		self:cMsg := 'Beneficiario nao localizado'
		lRet := .F.
	endif
Return lRet
//