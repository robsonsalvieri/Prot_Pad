#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"

#DEFINE __aCdCri187 {"573","Demanda por requerimento"}

/*/{Protheus.doc} SyncAuthorizations
    Integracao Authorizations
    @type  Class
    @author pls
    @since 10/03/2021
/*/
Class SyncAuthorizations
 
	Data cCodTiss
	Data cDesTiss
	Data aTabDup As Array
	Data cTrack
	Data cFile

	Method New()

	Method persist(oItem)
	Method persistCancel(oItem)

	Method statusByProc(oItem)
	Method cabConsulta(oItem)
	Method cabExame(oItem)
	Method cabOdonto(oItem)
	Method cabExecucao(oItem,cAuthType)
	Method cabInternacao(oItem)
	Method grvAuditoria(cNumGuia, cAuthType)
	Method cancelAuditoria(cNumGuia)

EndClass

Method New(cTrack, cFile) Class SyncAuthorizations

	self:aTabDup     := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
	self:cCodTiss    := getNewPar("MV_MOTTISS","")
	self:cTrack      := cTrack
	self:cFile       := cFile

	dbSelectArea("BE4")
	dbSelectArea("BEJ")
	dbSelectArea("BEL")
	dbSelectArea("BEA")
	dbSelectArea("BE2")
	dbSelectArea("BEG")
	dbSelectArea("B4B")
	dbSelectArea("B2Z")
	dbSelectArea("B43")


	BE4->(dbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
	BEA->(dbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+DTOS(BEA_DATPRO)+BEA_HORPRO
	BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
	BB8->(dbSetOrder(1)) //BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
	BCT->(dbSetOrder(1)) //BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO
	BEJ->(dbSetOrder(1)) //BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
	BEL->(dbSetOrder(1)) //BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN
	BTQ->(DBSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
	BB0->(dbSetOrder(4)) //BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE...
	BE2->(dbSetOrder(1)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
	BEG->(dbSetOrder(2)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN+BEG_CODGLO+BEG_DESGLO
	B4B->(dbSetOrder(1)) //B4B_FILIAL+B4B_OPEMOV+B4B_ANOAUT+B4B_MESAUT+B4B_NUMAUT+B4B_SEQUEN
	B43->(dbSetOrder(2)) //B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT+B43_SEQUEN
	B2Z->(dbSetOrder(4)) //B2Z_FILIAL+B2Z_OPEMOV+B2Z_CODRDA+B2Z_NUMAUT+B2Z_SEQUEN

	if BTQ->(msSeek(xFilial("BTQ") + "38" + self:cCodTiss))
		self:cCodTiss := BTQ->BTQ_CDTERM
		self:cDesTiss := BTQ->BTQ_DESTER
	else
		logInf("[" + self:cTrack + "] tabela 38 invalida - " + self:cCodTiss, self:cFile)
	endIf

Return self


Method persist(oItem) Class  SyncAuthorizations
	Local cCodOpe               := PlsIntPad()
	Local cAuthType             := tpGuiDP(oItem["authorizationType"],oItem["authorizationDescription"])
	Local cCodRDA               := oItem["healthProvider"]["healthProviderId"]
	Local cAuthNumber           := oItem["idOnHealthProvider"]
	Local nAuthId               := oItem["authorizationId"]
	Local cStatus               := oItem["authorizationStatus"]
	Local cStatusByProc         := self:statusByProc(oItem)
	Local lAudito               := cStatus == "6"
	Local cSubscriberId         := oItem["beneficiary"]["subscriberId"]
	Local dDataSolic            := Stod(StrTran(oItem["requestDate"], "-", ""))
	Local dDataAtend            := Stod(StrTran(oItem["authorizationDate"], "-", ""))
	Local nLenProced            := Len(oItem["procedures"])
	Local cCbos					:= Iif(Type('oItem["professional"]["cbos"]["code"]') == "C", oItem["professional"]["cbos"]["code"], "")
	Local cCodEsp				:= Iif(Type('oItem["professional"]["cbos"]["code"]') == "C", Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP'), "")
	Local cAnoAut               := substr(cAuthNumber, 5,4)
	Local cMesAut               := substr(cAuthNumber, 9,2)
	Local cNumAut               := substr(cAuthNumber, 11)
	Local cOpeUsr               := substr(cSubscriberId, 1,4)
	Local cCodEmp               := substr(cSubscriberId, 5,4)
	Local cMatric               := substr(cSubscriberId, 9,6)
	Local cTipReg               := substr(cSubscriberId, 15,2)
	Local cDigito               := substr(cSubscriberId, 17)
	Local oProced               := nil
	Local oCritica              := nil
	Local oPartic               := nil
	Local dDataPro              := ctod('')
	Local nProced               := 1
	Local nCritica              := 1
	Local nPartic               := 1
	Local nLenCritica           := 0
	Local nLenPartic            := 0
	Local cTipGuia              := ""
	Local cNumeroGui            := ""
	Local cCbosPrf              := ""
	Local cCodEspPrf            := ""
	Local cAliasCab             := "BEA"
	Local cAliasIte             := "BE2"
	Local cAliasCri             := "BEG"
	local nH                    := nil
	local cHorPro               := ""
	Local cCodTab               := ""
	Local cCodProc              := ""
	Local cCodTabDePara         := ""
	Local cCodProcDePara        := ""

	Local cCodLdp   := ""
	Local cCodPeg   := ""
	Local aItensPac := {}
	Local nI        := 0
	Local cDesloc   := ""
	Local cEndLoc   := ""
	Local cTipPre   := ""
	Local cNumProto := oItem["attendanceProtocol"]
	Local cTokenAte := iif(ValType(oItem["attendanceToken"])=="U","",oItem["attendanceToken"])
	Local cCdAusVld := iif(ValType(oItem["missingValidationCode"])=="U","",oItem["missingValidationCode"])
	Local cCobEsp   := iif(ValType(oItem["specialCoverage"])=="U","",oItem["specialCoverage"])
	Local lGerGui   := .t.
	Local cHorInt   := ''
	Local cHorAlt   := ''
	Local dDatInt   := ctod('')
	Local dDatAlt   := ctod('')
	local lRet      := .t.
	local aRet      := {}

	if cAuthType == HAT_CONSULTA
		cTipGuia := "01"
		dDataPro := dDataAtend
	elseif cAuthType == HAT_EXAME
		cTipGuia := "02"
		dDataPro := dDataSolic
	elseif cAuthType == HAT_ODONTO
		cTipGuia := "13"
		dDataPro := dDataSolic
	elseif cAuthType == HAT_EXAME_EXECUCAO
		cTipGuia := "02"
		dDataPro := dDataAtend
	elseif cAuthType == HAT_INTERNACAO
		cTipGuia  := "03"
		dDataPro  := dDataSolic
		cAliasCab := "BE4"
		cAliasIte := "BEJ"
		cAliasCri := "BEL"
	endif

	//Se Consulta em Auditoria devo gravar como SADT (regra TISS)
	if cTipGuia == "01" .And. cStatus == "6"
		cTipGuia := "02"
	endIf

	lRet := BA1->( MsSeek( xFilial("BA1") + cOpeUsr + cCodEmp + cMatric + cTipReg + cDigito ) )

	if !lRet
		logInf("[" + self:cTrack + "] usuario nao existe - " + cOpeUsr + cCodEmp + cMatric + cTipReg + cDigito, self:cFile)
	endif

	if lRet

		lRet := BAU->(msSeek(xFilial('BAU') + cCodRda))

		if !lRet
			logInf("[" + self:cTrack + "] rede de atendimento nao existe - " + cCodRda, self:cFile)
		endIf

		if lRet

			//Verifica se a internacao ja existe
			if cAuthType == HAT_INTERNACAO

				if BE4->(msSeek(xFilial("BE4") + cAuthNumber))

					dDatInt := Stod(StrTran(oItem["hospitalizationDate"], "-", ""))
					cHorInt := oItem["hospitalizationHour"]

					dDatAlt := Stod(StrTran(oItem["dischargedDate"], "-", ""))
					cHorAlt := oItem["dischargedHour"]

					if !Empty(dDatInt) .And. Empty(BE4->BE4_DATPRO)
						aRet := PLSA92DtIn(.T.,dDatInt,cHorInt,.F.)
						lGerGui := .f.
						if len(aRet) > 3 .and. aRet[4] <> ""
							logInf("[" + self:cTrack + "] internacao problema ao internar paciente - " + cAuthNumber + " - " + aRet[1], self:cFile)
						endif
					else
						logInf("[" + self:cTrack + "] internacao problema ao internar paciente - " + cAuthNumber, self:cFile)
					endIf

					if !Empty(BE4->BE4_DATPRO)
						if !Empty(dDatAlt) .and. empty(BE4->BE4_DTALTA)
							PLSADtAlt(.F.,dDatAlt,cHorAlt, oItem["dischargedType"] )
							lGerGui := .f.
						else
							logInf("[" + self:cTrack + "] internacao problema na alta - " + cAuthNumber, self:cFile)
						endIf
					endif

				else
					logInf("[" + self:cTrack + "] BE4 - internacao nao existe - " + cAuthNumber, self:cFile)
				endIf

			endIf

			// Verifica se a guia ja foi gravada alguma vez e pula o item
			lGerGui := BEA->(msSeek(xFilial("BEA") + cAuthNumber))

			if !lGerGui

				if cAuthType == HAT_CONSULTA

					lRet := chkJsonTag(self:cTrack, oItem, {"attendanceNote"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceModel"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"accidentIndication"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"consultationType"},,self:cFile)

				elseif cAuthType == HAT_EXAME

					lRet := chkJsonTag(self:cTrack, oItem, {"clinicalCondition"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceModel"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"requestDate"},,self:cFile)

				elseif cAuthType == HAT_ODONTO

					lRet := chkJsonTag(self:cTrack, oItem, {"clinicalCondition"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceNote"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceModel"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"requestDate"},,self:cFile)

				elseif cAuthType == HAT_EXAME_EXECUCAO

					lRet := chkJsonTag(self:cTrack, oItem, {"sourceAuthorization", "clinicalCondition, attendanceModel,requestDate"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceNote"},,self:cFile)

				elseif cAuthType == HAT_INTERNACAO

					lRet := chkJsonTag(self:cTrack, oItem, {"clinicalCondition"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceNote"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"attendanceModel"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"expectedHospitalizationDate"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"hospType"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"beneficiary","subscriberId"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"primaryICD"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"hospRegime"},,self:cFile) .and.;
						chkJsonTag(self:cTrack, oItem, {"dailyRequestedQuantity"},,self:cFile)

				endif

				if lRet

					//verificar guias na auditoria
					cCodLdp     := PlsRetLdp(5)
					cCodPeg     := PLSVRPEGOF(cCodOpe, cCodOpe, cCodRDA,  cAnoAut, cMesAut, cTipGuia, "1", "1", "1", cCodLdp, "1","2", , dDataPro, dDataBase,1 ,1 ,0, .F.)[1]
					cNumeroGui  := PLSA500NUM(iIf(cAliasCab == "BE4", "BE4", "BD5"), cCodOpe, cCodLdp, cCodPeg)
					cSenha      := oItem["password"]
					if cAuthType == HAT_INTERNACAO .And. !Empty(oItem["hospitalizationHour"])
						cHorPro := StrTran(oItem["hospitalizationHour"], "-", "")
					else
						cHorPro := Replicate("0",4)
					endIf

					BEA->(RecLock("BEA",.T.))
					BEA->BEA_FILIAL := xFilial("BEA")
					BEA->BEA_STATUS := cStatusByProc

					If cAuthType <> HAT_EXAME_EXECUCAO
						BEA->BEA_STALIB := iif(cStatus == "6", "6", "1")
					endIf

					BEA->BEA_GUIACO := '0'
					BEA->BEA_GUIIMP := '0'
					BEA->BEA_CANCEL := iif(cStatus == "9", "1", "0")
					BEA->BEA_AUDITO := iif(cStatus == "6", "1", "0")
					BEA->BEA_TIPGUI := cTipGuia
					BEA->BEA_TIPO := iif(cAuthType == HAT_ODONTO, "4", substr(cTipGuia, 2))
					BEA->BEA_TPGRV := "2"
					BEA->BEA_ORIMOV := "6"
					BEA->BEA_TIPPAC := alltrim(PLSVARVINC('50', nil, oItem["attendanceType"]))
					BEA->BEA_GUIPRE := cAuthNumber
					BEA->BEA_DATPRO := dDataPro

					BEA->BEA_DTDIGI := dDataBase
					BEA->BEA_HHDIGI := StrTran(Time(),":","")

					BEA->BEA_OPEPEG := cCodOpe
					BEA->BEA_CODLDP := cCodLdp
					BEA->BEA_CODPEG := cCodPeg
					BEA->BEA_NUMGUI := cNumeroGui

					BEA->BEA_OPEMOV := cCodOpe
					BEA->BEA_ANOAUT := cAnoAut
					BEA->BEA_MESAUT := cMesAut
					BEA->BEA_NUMAUT := cNumAut

					BEA->BEA_SENHA :=  cSenha
					BEA->BEA_VALSEN := Stod(StrTran(oItem["passwordExpireDate"], "-", ""))

					BEA->BEA_OPEUSR := cOpeUsr
					BEA->BEA_CODEMP := cCodEmp
					BEA->BEA_MATRIC := cMatric
					BEA->BEA_TIPREG := cTipReg
					BEA->BEA_DIGITO := cDigito
					BEA->BEA_ATERNA := iif(oItem["newbornAttendance"], "1", "0")

					BEA->BEA_OPERDA := cCodOpe
					BEA->BEA_CODRDA := cCodRDA
					BEA->BEA_NOMRDA := oItem["healthProvider"]["name"]
					BEA->BEA_PROATE := cNumProto
					BEA->BEA_STTISS := PLSANLSTIG(oItem["authorizationStatus"])

					if BEA->(FieldPos("BEA_TOKEDI")) > 0
						BEA->BEA_TOKEDI := cTokenAte
					endIf

					if BEA->(FieldPos("BEA_AUSVLD")) > 0
						BEA->BEA_AUSVLD := cCdAusVld
					endIf

					if BEA->(FieldPos("BEA_COBESP")) > 0
						BEA->BEA_COBESP := cCobEsp
					endIf

					BEA->BEA_TIPPRE := BAU->BAU_TIPPRE
					cTipPre := BAU->BAU_TIPPRE

					// TODO: Quando o HAT mandar o CNES na API, posicionar o Local pelo CNES
					BEA->BEA_CODLOC := oItem["locationCode"]
					BEA->BEA_LOCAL := oItem["attendanceLocation"]

					if BB8->( MsSeek( xFilial("BB8") + cCodRDA + cCodOpe+oItem["locationCode"]+oItem["attendanceLocation"] ) )
						cDesloc := ALLTRIM(BB8->BB8_DESLOC)
						cEndLoc := AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO)
						BEA->BEA_DESLOC := cDesloc
						BEA->BEA_ENDLOC := cEndLoc
					else
						logInf("[" + self:cTrack + "] BB8 - local nao existe - " + cCodRDA + cCodOpe+oItem["locationCode"]+oItem["attendanceLocation"], self:cFile)
					EndIf

					BEA->BEA_OPESOL := PLSINTPAD()
					BEA->BEA_HORPRO := cHorPro

					BEA->BEA_NOMUSR := BA1->BA1_NOMUSR
					BEA->BEA_CONEMP := BA1->BA1_CONEMP
					BEA->BEA_VERCON := BA1->BA1_VERCON
					BEA->BEA_SUBCON := BA1->BA1_SUBCON
					BEA->BEA_VERSUB := BA1->BA1_VERSUB
					BEA->BEA_MATVID := BA1->BA1_MATVID
					BEA->BEA_CPFUSR := BA1->BA1_CPFUSR

					iF !Empty(cNumProto) .and. cStatus $  "2|6|3"
						gerRegB00(cNumProto,,cAliasCab,.T.,.f.,cOpeUsr+cCodEmp+cMatric+cTipReg+cDigito,.f.,,,,,cCodOpe,,,,,,,,.T.,.f.,cAuthNumber)
						P773AutCon(cAliasCab,cNumProto,cCodOpe+cAnoAut+cMesAut+cNumAut)
					endif

					if cAuthType == HAT_CONSULTA

						self:cabConsulta(oItem)

					elseif cAuthType == HAT_EXAME

						self:cabExame(oItem)

					elseif cAuthType == HAT_ODONTO

						self:cabOdonto(oItem)

					elseif cAuthType == HAT_EXAME_EXECUCAO

						self:cabExecucao(oItem,cAuthType)

					elseif cAuthType == HAT_INTERNACAO

						BEA->BEA_OPEINT := cCodOpe
						BEA->BEA_ANOINT := cAnoAut
						BEA->BEA_MESINT := cMesAut
						BEA->BEA_NUMINT := cNumAut
						BEA->BEA_LIBERA := "0"

						self:cabInternacao(oItem, "BEA")


					endif

					BEA->(MsUnlock())

					if cAuthType == HAT_INTERNACAO

						if ! BE4->(msSeek(xFilial("BE4") + cAuthNumber))

							BE4->(RecLock("BE4",.T.))

							BE4->BE4_FILIAL := xFilial("BE4")
							BE4->BE4_STATUS := cStatusByProc
							BE4->BE4_CANCEL := iif(cStatus == "9", "1", "0")
							BE4->BE4_AUDITO := iif(cStatus == "6", "1", "0")
							BE4->BE4_TIPGUI := cTipGuia
							BE4->BE4_TPGRV := "2"
							BE4->BE4_ORIMOV := "6"
							BE4->BE4_GUIPRE := cAuthNumber
							BE4->BE4_DATPRO := Stod( StrTran(oItem["hospitalizationDate"], "-", "") )
							BE4->BE4_HORPRO := cHorPro
							BE4->BE4_DTALTA := Stod( StrTran(oItem["dischargedDate"], "-", "") )
							BE4->BE4_HRALTA := StrTran(oItem["dischargedHour"], "-", "")
							BE4->BE4_TIPALT := cvaltochar(oItem["dischargedType"])

							BE4->BE4_CODOPE := cCodOpe
							BE4->BE4_CODLDP := cCodLdp
							BE4->BE4_CODPEG := cCodPeg
							BE4->BE4_NUMERO := cNumeroGui

							BE4->BE4_DTDIGI := dDataSolic
							BE4->BE4_HHDIGI := StrTran(Time(),":","")
							BE4->BE4_GUIIMP := '0'

							BE4->BE4_ANOINT := cAnoAut
							BE4->BE4_MESINT := cMesAut
							BE4->BE4_NUMINT := cNumAut

							BE4->BE4_SENHA := cSenha
							BE4->BE4_DATVAL := Stod(StrTran(oItem["passwordExpireDate"], "-", ""))

							BE4->BE4_OPEUSR := cOpeUsr
							BE4->BE4_CODEMP := cCodEmp
							BE4->BE4_MATRIC := cMatric
							BE4->BE4_TIPREG := cTipReg
							BE4->BE4_DIGITO := cDigito
							BE4->BE4_ATERNA := iif(oItem["newbornAttendance"], "1", "0")

							BE4->BE4_OPERDA := cCodOpe
							BE4->BE4_CODRDA := cCodRDA
							BE4->BE4_NOMRDA := oItem["healthProvider"]["name"]
							BE4->BE4_TIPPRE := cTipPre

							if BE4->(FieldPos("BE4_TOKEDI")) > 0
								BE4->BE4_TOKEDI := cTokenAte
							endIf

							if BE4->(FieldPos("BE4_AUSVLD")) > 0
								BE4->BE4_AUSVLD := cCdAusVld
							endIf

							// TODO: Quando o HAT mandar o CNES na API, posicionar o Local pelo CNES
							BE4->BE4_CODLOC :=  oItem["locationCode"]
							BE4->BE4_LOCAL :=  oItem["attendanceLocation"]
							BE4->BE4_PROATE :=  cNumProto
							BE4->BE4_STTISS := PLSANLSTIG(oItem["authorizationStatus"])

							self:cabInternacao(oItem, "BE4")

							BE4->(MsUnlock())

						else
							logInf("[" + self:cTrack + "] BE4 - internacao ja existe - " + cAuthNumber, self:cFile)
						endIf

					endIf

					while nProced <= nLenProced

						oProced         := oItem["procedures"][nProced]
						cCodTab         := oProced["tableCode"]
						cCodProc        := oProced["procedureCode"]
						cCodTabDePara   := AllTrim(PLSVARVINC('87','BR4',cCodTab))
						cCodProcDePara  := AllTrim(PLSVARVINC(cCodTab,'BR8', cCodProc, cCodTabDePara+cCodProc,,self:aTabDup,@cCodTabDePara))

						if ! BE2->(msSeek(xFilial("BE2") + cAuthNumber + strzero(nProced, 3)))

							BE2->(RecLock("BE2",.T.))

							BE2->BE2_FILIAL := xFilial("BE2")
							BE2->BE2_STATUS := iif(oProced["status"] <> 2, cvaltochar(oProced["status"]), "0")
							BE2->BE2_SEQUEN := strzero(nProced, 3)
							BE2->BE2_CODPAD := cCodTabDePara
							BE2->BE2_CODPRO := cCodProcDePara
							BE2->BE2_DESPRO := DECODEUTF8(oProced["procedureDescription"])
							BE2->BE2_QTDSOL := oProced["requestedQuantity"]
							BE2->BE2_TIPPRE := cTipPre
							BE2->BE2_NIVCRI := iif(oProced["status"] <> 1,"HAT","")

							If oProced["authorizedQuantity"] == 0 .And. oProced["status"] == 2
								BE2->BE2_QTDPRO := oProced["requestedQuantity"]
							Else
								BE2->BE2_QTDPRO := oProced["authorizedQuantity"]
							EndIf

							iF oProced["status"] == 1
								BE2->BE2_SALDO := IIF(cAuthType <> HAT_EXAME_EXECUCAO, oProced["authorizedQuantity"],0)
							endif

							BE2->BE2_DATPRO := dDataPro
							BE2->BE2_AUDITO := iif(oProced["status"] == 2, "1", "0")

							BE2->BE2_OPEMOV := cCodOpe
							BE2->BE2_ANOAUT := cAnoAut
							BE2->BE2_MESAUT := cMesAut
							BE2->BE2_NUMAUT := cNumAut

							if cAuthType == HAT_INTERNACAO
								BE2->BE2_ANOINT := cAnoAut
								BE2->BE2_MESINT := cMesAut
								BE2->BE2_NUMINT := cNumAut
							endIf

							BE2->BE2_TIPGUI := cTipGuia
							BE2->BE2_TIPO := substr(cTipGuia, 2)
							BE2->BE2_TPGRV := "2"
							BE2->BE2_OPERDA := cCodOpe
							BE2->BE2_CODRDA := cCodRDA

							BE2->BE2_CODLOC := oItem["locationCode"]
							BE2->BE2_LOCAL := oItem["attendanceLocation"]
							BE2->BE2_ENDLOC := cEndLoc
							BE2->BE2_DESLOC := cDesloc
							BE2->BE2_CODESP := cCodEsp
							BE2->BE2_OPEUSR := cOpeUsr
							BE2->BE2_CODEMP := cCodEmp
							BE2->BE2_MATRIC := cMatric
							BE2->BE2_TIPREG := cTipReg
							BE2->BE2_DIGITO := cDigito

							BE2->BE2_CODLDP := cCodLdp
							BE2->BE2_CODPEG := cCodPeg
							BE2->BE2_NUMERO := cNumeroGui

							BE2->BE2_CONEMP := BA1->BA1_CONEMP
							BE2->BE2_VERCON := BA1->BA1_VERCON
							BE2->BE2_SUBCON := BA1->BA1_SUBCON
							BE2->BE2_VERSUB := BA1->BA1_VERSUB
							BE2->BE2_MATVID := BA1->BA1_MATVID
							BE2->BE2_NOMUSR := BA1->BA1_NOMUSR
							BE2->BE2_HORPRO := cHorPro

							if !empty(oProced["toothRegion"])
								// TODO: Depara de dentes - 28 / regiões - 42 / faces - 32
								BE2->BE2_DENREG := oProced["toothRegion"]
								BE2->BE2_FADENT := oProced["surfaces"]
							endif

							if  cAuthType == HAT_EXAME_EXECUCAO
								BE2->BE2_HORPRO := cHorPro
								BE2->BE2_HORFIM := cHorPro
								BE2->BE2_VIA    :=  alltrim(PLSVARVINC('61', nil, oProced["accessWay"]))
								BE2->BE2_TECUTI := alltrim(PLSVARVINC('48', nil, oItem["usedTechnique"]))
								BE2->BE2_PRPRRL := iif(empty(oProced["increaseDecrease"]), 1, oProced["increaseDecrease"])
							endIf

							if cAuthType == HAT_EXAME_EXECUCAO .OR. cAuthType == HAT_CONSULTA
								BE2->BE2_VLRAPR := iif(empty(oProced["unitaryWorth"]), 0, oProced["unitaryWorth"])
								BE2->BE2_LIBERA := "0"
							else
								BE2->BE2_LIBERA := "1"
							endIf

							BE2->(MsUnlock())

							grvB2Z(self:cTrack, self:cFile, cCodOpe, cCodRDA, oItem["idOnHealthProvider"], cSubscriberId, dDataPro, cSenha, strzero(nProced, 3),;
								cCodTabDePara, cCodProcDePara, cValToChar(nAuthId), cTipGuia, oProced["authorizedQuantity"], IIF(cAuthType <> HAT_EXAME_EXECUCAO, oProced["authorizedQuantity"],0),;
								oProced["toothRegion"], oProced["surfaces"] )

							if cAuthType == HAT_EXAME_EXECUCAO .And. oProced["status"] == 1 //autorizado controla saldo

								nH := plsAbreSem("SYNC_" + oItem['mainAuthorizationCode'] + ".SMF")

								PLSAtuLib(oItem['mainAuthorizationCode'],strzero(nProced, 3),cCodTabDePara,cCodProcDePara,oProced["authorizedQuantity"],{},.F.,.F.,.F., 0, "", "")

								PLSFechaSem(nH, "SYNC_" + oItem['mainAuthorizationCode'] + ".SMF")

							endif

							if cAuthType == HAT_INTERNACAO

								if ! BEJ->( msSeek( xFilial('BEJ') + cCodOpe + cAnoAut + cMesAut + cNumAut + strzero(nProced, 3) ) )

									BEJ->(RecLock("BEJ",.T.))

									BEJ->BEJ_FILIAL := xFilial("BEJ")
									BEJ->BEJ_STATUS := iif(oProced["status"] <> 2, cvaltochar(oProced["status"]), "0")
									BEJ->BEJ_SEQUEN := strzero(nProced, 3)
									BEJ->BEJ_CODPAD := cCodTabDePara
									BEJ->BEJ_CODPRO := cCodProcDePara
									BEJ->BEJ_DESPRO := DECODEUTF8(oProced["procedureDescription"])
									BEJ->BEJ_QTDSOL := oProced["requestedQuantity"]
									BEJ->BEJ_NIVCRI := iif(oProced["status"] <> 1,"HAT","")

									If oProced["authorizedQuantity"] == 0 .And. oProced["status"] == 2
										BEJ->BEJ_QTDPRO := oProced["requestedQuantity"]
									Else
										BEJ->BEJ_QTDPRO := oProced["authorizedQuantity"]
									EndIf

									BEJ->BEJ_DATPRO := dDataPro
									BEJ->BEJ_AUDITO := iIf(oProced["status"] == 2, "1", "0")

									BEJ->BEJ_CODOPE := cCodOpe
									BEJ->BEJ_ANOINT := cAnoAut
									BEJ->BEJ_MESINT := cMesAut
									BEJ->BEJ_NUMINT := cNumAut
									BEJ->BEJ_ESPSOL := cCodEsp
									BEJ->(MsUnlock())

								else
									logInf("[" + self:cTrack + "] BEJ - ja existe - " + cCodOpe + cAnoAut + cMesAut + cNumAut  + strzero(nProced, 3), self:cFile)
								endIf

							EndIf

							nLenCritica := iIf(!empty(oItem["procedures"][nProced]["rejectionCauses"]), Len(oItem["procedures"][nProced]["rejectionCauses"]), 0)
							nCritica    := 1

							while lRet .and. nCritica <= nLenCritica

								oCritica := oItem["procedures"][nProced]["rejectionCauses"][nCritica]

								lRet := chkJsonTag(self:cTrack, oCritica, {"code"},,self:cFile)

								if lRet

									if BCT->(msSeek(xFilial('BCT') + cCodOpe + oCritica["code"]))

										if ! (cAliasCri)->( msSeek( xFilial(cAliasCri) + cCodOpe + cAnoAut + cMesAut + cNumAut + strzero(nProced, 3) + oCritica["code"] + BCT->BCT_DESCRI ) )

											(cAliasCri)->(RecLock(cAliasCri,.T.))
											(cAliasCri)->&(cAliasCri + "_FILIAL") := xFilial(cAliasCri)

											if cAuthType <> HAT_INTERNACAO
												(cAliasCri)->&(cAliasCri + "_OPEMOV") := cCodOpe
												(cAliasCri)->&(cAliasCri + "_ANOAUT") := cAnoAut
												(cAliasCri)->&(cAliasCri + "_MESAUT") := cMesAut
												(cAliasCri)->&(cAliasCri + "_NUMAUT") := cNumAut
											else
												(cAliasCri)->&(cAliasCri + "_CODOPE") := cCodOpe
												(cAliasCri)->&(cAliasCri + "_ANOINT") := cAnoAut
												(cAliasCri)->&(cAliasCri + "_MESINT") := cMesAut
												(cAliasCri)->&(cAliasCri + "_NUMINT") := cNumAut
											endIf

											(cAliasCri)->&(cAliasCri + "_SEQUEN") := strzero(nProced, 3)
											(cAliasCri)->&(cAliasCri + "_CODGLO") := oCritica["code"]
											(cAliasCri)->&(cAliasCri + "_DESGLO") := BCT->BCT_DESCRI
											(cAliasCri)->&(cAliasCri + "_SEQCRI") := strzero(nCritica, 3)
											(cAliasCri)->&(cAliasCri + "_TIPO") := BCT->BCT_TIPO
											(cAliasCri)->(MsUnlock())

										else
											logInf("[" + self:cTrack + "] " + cAliasCri + " - critica do item ja existe - " + cCodOpe + cAnoAut + cMesAut + cNumAut + strzero(nProced, 3) + oCritica["code"] + BCT->BCT_DESCRI, self:cFile)
										endIf

									else
										logInf("[" + self:cTrack + "] BCT - nao existe - " + oCritica["code"], self:cFile)
									endIf

								endIf
								nCritica++

							endDo

							if nLenCritica >= 1
								FreeObj(oCritica)
							endIf

							if lRet .and. cAuthType == HAT_EXAME_EXECUCAO

								//lRet := chkJsonTag(self:cTrack, oItem["procedures"][nProced], {"medicalTeam"},, self:cFile)

								if lRet

									nLenPartic := Iif(Type('len(oItem["procedures"][nProced]["medicalTeam"])') == ("UI"),len(oItem["procedures"][nProced]["medicalTeam"]), 0 )
									nPartic    :=  1

									while lRet .and. nPartic <= nLenPartic

										oPartic := oItem["procedures"][nProced]["medicalTeam"][nPartic]
										if lRet
											cCbosPrf    := Iif(Type('oPartic["professional"]["cbos"]["code"]') == "C",oPartic["professional"]["cbos"]["code"],"")
											cCodEspPrf  := Posicione('BAQ', 6, xFilial('BAQ') + cCbosPrf,'BAQ_CODESP')
										endIf


										if lRet

											if posProf(oPartic["professional"]["stateAbbreviation"], oPartic["professional"]["professionalCouncilNumber"], oPartic["professional"]["professionalCouncil"],oPartic["professional"]["name"],oPartic["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)

												if ! B4B->(msSeek(xFilial("B4B") + cCodOpe + cAnoAut + cMesAut + cNumAut + strzero(nProced, 3)))

													B4B->(RecLock("B4B",.T.))
													B4B->B4B_FILIAL := xFilial("B4B")
													B4B->B4B_OPEMOV := cCodOpe
													B4B->B4B_ANOAUT := cAnoAut
													B4B->B4B_MESAUT := cMesAut
													B4B->B4B_NUMAUT := cNumAut
													B4B->B4B_SEQUEN := strzero(nProced, 3)
													B4B->B4B_GRAUPA := oPartic["participationDegree"]
													B4B->B4B_CDPFPR := BB0->BB0_CODIGO
													B4B->B4B_CGC    := BB0->BB0_CGC
													B4B->B4B_SICONS := oPartic["professional"]["professionalCouncil"]
													B4B->B4B_NUCONS := oPartic["professional"]["professionalCouncilNumber"]
													B4B->B4B_UFCONS := oPartic["professional"]["stateAbbreviation"]
													B4B->B4B_CODESP := Iif(Type('cCodEspPrf') == "C",cCodEspPrf,"")
													B4B->(MsUnlock())

												else
													logInf("[" + self:cTrack + "] B4B - ja existe - " + cCodOpe + cAnoAut + cMesAut + cNumAut  + strzero(nProced, 3), self:cFile)
												endIf

											endIf

										endIf

										nPartic++

									endDo

								endIf

							endIf

							if lRet .and. Alltrim(cCodTab) $ "90/98"  // tratamento pacote

								aItensPac := PlRetPac(cCodOpe, cCodRDA,cCodTabDePara,cCodProcDePara ,,dDataPro, .f.)

								If Len(aItensPac) > 0

									For nI := 1 To Len(aItensPac)

										//aqui tem que revisar
										if ! B43->(msSeek(xFilial("B43") + cCodOpe + cAnoAut + cMesAut + cNumAut + strzero(nProced, 3)))

											B43->(RecLock("B43",.T.))

											B43->B43_FILIAL := xFilial("B43")
											B43->B43_OPEMOV := cCodOpe
											B43->B43_ANOAUT := cAnoAut
											B43->B43_MESAUT := cMesAut
											B43->B43_NUMAUT := cNumAut
											B43->B43_SEQUEN := strzero(nProced, 3)

											B43->B43_CODOPE := iif(cStatus == "3", "", cCodOpe)
											B43->B43_CODLDP := iif(cStatus == "3", "", cCodLdp)
											B43->B43_CODPEG := iif(cStatus == "3", "", cCodPeg)
											B43->B43_NUMERO := iif(cStatus == "3", "", cNumeroGui)

											B43->B43_CODPAD := aItensPac[nI,1]
											B43->B43_CODPRO := aItensPac[nI,2]
											B43->B43_DESPRO := POSICIONE('BR8',1,xFilial('BR8') + ALLTRIM(aItensPac[nI,1]) + ALLTRIM(aItensPac[nI,2]),'BR8_DESCRI')
											B43->B43_VALCH := aItensPac[nI,4]
											B43->B43_VALFIX := aItensPac[nI,5]
											B43->B43_PRINCI := aItensPac[nI,6]
											B43->B43_TIPO := aItensPac[nI,3]
											B43->B43_ORIMOV := '6'
											B43->B43_NIVPAC := aItensPac[nI,10]
											B43->(MsUnlock())

										else
											logInf("[" + self:cTrack + "] B43 - ja existe - " + cCodOpe + cAnoAut + cMesAut + cNumAut  + strzero(nProced, 3), self:cFile)
										endIf

									Next nI

								EndIf

							endIf

						else
							logInf("[" + self:cTrack + "] item ja existe - " + cAuthNumber + strzero(nProced, 3), self:cFile)
						endIf

						nProced++

					endDo

					if lAudito
						self:grvAuditoria(cAuthNumber, cAuthType)
					endIf

				endIf

			else
				logInf("[" + self:cTrack + "] BEA - registro ja processado", self:cFile)
			endIf

			if lRet
				lRet := isWorkSync()
			endIf

		endIf

	endIf

	BEL->(dbCloseArea())
	BE4->(dbCloseArea())
	BEJ->(dbCloseArea())
	BEA->(dbCloseArea())
	BE2->(dbCloseArea())
	BEG->(dbCloseArea())
	B4B->(dbCloseArea())
	B2Z->(dbCloseArea())
	B43->(dbCloseArea())
	BB0->(dbCloseArea())
	BAU->(dbCloseArea())
	BA1->(dbCloseArea())
	BB8->(dbCloseArea())
	BCT->(dbCloseArea())
	BTQ->(dbCloseArea())

Return lRet

Method persistCancel(oItem) Class  SyncAuthorizations
	Local cCodOpe       := PlsIntPad()
	Local cAuthType     := IIF('Exame - Exec' $ oItem["authorizationDescription"],'3',oItem["authorizationType"])
	Local cAuthNumber   := oItem["idOnHealthProvider"]
	Local cAnoAut       := substr(cAuthNumber, 5,4)
	Local cMesAut       := substr(cAuthNumber, 9,2)
	Local cNumAut       := substr(cAuthNumber, 11)
	local lRet          := .f.

	if cAuthType = HAT_INTERNACAO

		lRet := BE4->( MsSeek( xFilial("BE4") + cCodOpe + cAnoAut + cMesAut + cNumAut) )

		if lRet

			BE4->(RecLock("BE4",.F.))
			BE4->BE4_CANCEL := "1"
			BE4->BE4_STATUS := "3"
			BE4->BE4_CANTIS := self:cCodTiss
			BE4->BE4_CANEDI := self:cDesTiss
			BE4->BE4_SITUAC := "2"
			BE4->(MsUnlock())

			BEA->(dbSetOrder(6))//BEA_FILIAL+BEA_OPEINT+BEA_ANOINT+BEA_MESINT+BEA_NUMINT+DTOS(BEA_DATPRO)+BEA_HORPRO
			lRet := BEA->( MsSeek( xFilial("BEA") + cCodOpe + cAnoAut + cMesAut + cNumAut) )

			if lRet

				BEA->(RecLock("BEA",.F.))
				BEA->BEA_CANCEL := "1"
				BEA->BEA_STATUS := "3"
				BEA->BEA_CANTIS := self:cCodTiss
				BEA->BEA_CANEDI := self:cDesTiss
				BEA->(MsUnlock())

				if BEJ->( MsSeek( xFilial("BEJ") + cCodOpe + cAnoAut + cMesAut + cNumAut ) )

					while !BEJ->(Eof()) .And. BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)
						BEJ->(RecLock("BEJ",.F.))
						BEJ->BEJ_STATUS := "0"
						BEJ->(MsUnlock())
						BEJ->(DbSkip())
					endDo

				else
					logInf("[" + self:cTrack + "] BEJ - item da internacao nao existe", self:cFile)
				endIf

				if BE2->( MsSeek( xFilial("BE2") + cCodOpe + cAnoAut + cMesAut + cNumAut ) )

					while !BE2->(Eof()) .And. BE4->(BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
						BE2->(RecLock("BE2",.F.))
						BE2->BE2_STATUS := "0"
						BE2->(MsUnlock())
						BE2->(DbSkip())
					endDo

					self:cancelAuditoria(cAuthNumber)

				else
					logInf("[" + self:cTrack + "] BE2 - item da internacao BE2 nao existe", self:cFile)
				endIf

			else
				logInf("[" + self:cTrack + "] BEA - internacao nao existe", self:cFile)
			endIf

		else
			logInf("[" + self:cTrack + "] BE4 - internacao nao existe", self:cFile)
		endIf

	else

		lRet := BEA->( MsSeek( xFilial("BEA") + cCodOpe + cAnoAut + cMesAut + cNumAut) )

		if lRet

			BEA->(RecLock("BEA",.F.))
			BEA->BEA_CANCEL := "1"
			BEA->BEA_STATUS := "3"
			BEA->BEA_CANTIS := self:cCodTiss
			BEA->BEA_CANEDI := self:cDesTiss
			BEA->(MsUnlock())

			if BE2->( MsSeek( xFilial("BE2") + cCodOpe + cAnoAut + cMesAut + cNumAut ) )

				While !BE2->(Eof()) .And. BEA->(BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT)
					BE2->(RecLock("BE2",.F.))
					BE2->BE2_STATUS := "0"
					BE2->(MsUnlock())
					BE2->(DbSkip())
				EndDo

				self:cancelAuditoria(cAuthNumber)

			else
				logInf("[" + self:cTrack + "] BE2 - nao existe item para o atendimento", self:cFile)
			endIf

		else
			logInf("[" + self:cTrack + "] BEA - atendimento nao existe", self:cFile)
		endIf

	EndIf

	if lRet
		lRet := isWorkSync()
	endIf

	BEL->(dbCloseArea())
	BE4->(dbCloseArea())
	BEJ->(dbCloseArea())
	BEA->(dbCloseArea())
	BE2->(dbCloseArea())
	BEG->(dbCloseArea())
	B4B->(dbCloseArea())
	B2Z->(dbCloseArea())
	B43->(dbCloseArea())
	BB0->(dbCloseArea())
	BAU->(dbCloseArea())
	BA1->(dbCloseArea())
	BB8->(dbCloseArea())
	BCT->(dbCloseArea())
	BTQ->(dbCloseArea())

Return lRet

Method statusByProc(oItem) Class SyncAuthorizations

	Local aProcedimentos := oItem["procedures"]
	Local nLenProced := len(aProcedimentos)
	Local lAudito := oItem["authorizationStatus"] == "6"
	Local cStatus := ""
	Local nI := 1
	Local nAut := 0
	Local nNeg := 0

	if lAudito
		cStatus := "6"
	else

		For nI := 1 to nLenProced
			if aProcedimentos[nI]["status"] == 0 .or. aProcedimentos[nI]["status"] == 2
				nNeg++
			else
				nAut++
			endIf
		Next nI

		if nNeg == nLenProced
			cStatus := "3"
		elseif nAut == nLenProced
			cStatus := "1"
		else
			cStatus := "2"
		endif

	endIf

Return cStatus

Method cabConsulta(oItem) Class SyncAuthorizations
	Local cCbos     := Iif(ValType('oItem["professional"]["cbos"]["code"]') == "C", oItem["professional"]["cbos"]["code"], "")
	Local cCodEsp   := Iif(ValType('oItem["professional"]["cbos"]["code"]') == "C", Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP'), "")
	Local aObs	    := PLBreakTxt(oItem["attendanceNote"], {"BEA_MSG01", "BEA_MSG02"})

	if posProf(oItem["professional"]["stateAbbreviation"], oItem["professional"]["professionalCouncilNumber"], oItem["professional"]["professionalCouncil"],oItem["professional"]["name"],oItem["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
		BEA->BEA_NOMEXE := BB0->BB0_NOME
		BEA->BEA_CDPFRE := BB0->BB0_CODIGO
		BEA->BEA_SIGEXE := oItem["professional"]["professionalCouncil"]
		BEA->BEA_REGEXE := oItem["professional"]["professionalCouncilNumber"]
		BEA->BEA_ESTEXE := oItem["professional"]["stateAbbreviation"]
		BEA->BEA_ESPEXE := cCodEsp
	endIf

	BEA->BEA_ORIGEM := "1"

	BEA->BEA_CODESP := cCodEsp
	BEA->BEA_TIPADM := alltrim(PLSVARVINC('23', nil, oItem["attendanceModel"]))

	BEA->BEA_INDACI := alltrim(PLSVARVINC('36', nil, oItem["accidentIndication"]))
	BEA->BEA_TIPCON := alltrim(PLSVARVINC('52', nil, oItem["consultationType"]))
	BEA->BEA_MSG01 := aObs[1]
	BEA->BEA_MSG02 := aObs[2]
	BEA->BEA_LIBERA := "0"

Return

Method cabExame(oItem) Class SyncAuthorizations
	Local cCbos   := Iif(ValType('oItem["professional"]["cbos"]["code"]') == "C", oItem["professional"]["cbos"]["code"], "")
	Local cCodEsp := Iif(ValType('oItem["professional"]["cbos"]["code"]') == "C", Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP'), "")
	Local aIndCli := PLBreakTxt(oItem["clinicalCondition"], {"BEA_INDCLI", "BEA_INDCL2"})
	Local aObs	  := PLBreakTxt(oItem["attendanceNote"], {"BEA_MSG01", "BEA_MSG02"})

	if posProf(oItem["professional"]["stateAbbreviation"], oItem["professional"]["professionalCouncilNumber"], oItem["professional"]["professionalCouncil"],oItem["professional"]["name"],oItem["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
		BEA->BEA_NOMSOL := BB0->BB0_NOME
		BEA->BEA_CDPFSO := BB0->BB0_CODIGO
		BEA->BEA_SIGLA := oItem["professional"]["professionalCouncil"]
		BEA->BEA_REGSOL := oItem["professional"]["professionalCouncilNumber"]
		BEA->BEA_ESTSOL := oItem["professional"]["stateAbbreviation"]
		BEA->BEA_ESPSOL := cCodEsp
	endIf

	BEA->BEA_ORIGEM := "2"
	BEA->BEA_CODESP := cCodEsp

	BEA->BEA_TIPADM := alltrim(PLSVARVINC('23', nil, oItem["attendanceModel"]))
	BEA->BEA_DATSOL := Stod(StrTran(oItem["requestDate"], "-", ""))
	BEA->BEA_INDCLI := aIndCli[1]
	BEA->BEA_INDCL2 := aIndCli[2]
	BEA->BEA_MSG01 := aObs[1]
	BEA->BEA_MSG02 := aObs[2]
	BEA->BEA_LIBERA := "1"
	BEA->BEA_GUIPRI := oItem['mainAuthorizationCode']

Return

Method cabOdonto(oItem) Class SyncAuthorizations
	Local cCbos     := Iif(Type('oItem["professional"]["cbos"]["code"]') == "C", oItem["professional"]["cbos"]["code"], "")
	Local cCodEsp   := Iif(Type('oItem["professional"]["cbos"]["code"]') == "C", Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP'), "")
	Local aIndCli   := PLBreakTxt(oItem["clinicalCondition"], {"BEA_INDCLI", "BEA_INDCL2"})
	Local aObs	    := PLBreakTxt(oItem["attendanceNote"], {"BEA_MSG01", "BEA_MSG02"})

	// Preenche os dados do profissional solicitante
	if posProf(oItem["professionalRequestor"]["stateAbbreviation"], oItem["professionalRequestor"]["professionalCouncilNumber"], oItem["professionalRequestor"]["professionalCouncil"],oItem["professionalRequestor"]["name"],oItem["professionalRequestor"]["idOnHealthInsurer"], self:cTrack, self:cFile)
		BEA->BEA_NOMSOL := BB0->BB0_NOME
		BEA->BEA_CDPFSO := BB0->BB0_CODIGO
		BEA->BEA_SIGLA := oItem["professionalRequestor"]["professionalCouncil"]
		BEA->BEA_REGSOL := oItem["professionalRequestor"]["professionalCouncilNumber"]
		BEA->BEA_ESTSOL := oItem["professionalRequestor"]["stateAbbreviation"]
		BEA->BEA_ESPSOL := cCodEsp
	endIf

	// Preenche os dados do profissional executante
	if posProf(oItem["professional"]["stateAbbreviation"], oItem["professional"]["professionalCouncilNumber"], oItem["professional"]["professionalCouncil"],oItem["professional"]["name"],oItem["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
		BEA->BEA_CDPFRE := BB0->BB0_CODIGO
		BEA->BEA_NOMEXE := BB0->BB0_NOME
		BEA->BEA_SIGEXE := oItem["professional"]["professionalCouncil"]
		BEA->BEA_REGEXE := oItem["professional"]["professionalCouncilNumber"]
		BEA->BEA_ESTEXE := oItem["professional"]["stateAbbreviation"]
		BEA->BEA_ESPEXE := cCodEsp
	endif

	BEA->BEA_ORIGEM := "1"
	BEA->BEA_CODESP := cCodEsp

	BEA->BEA_TIPADM := alltrim(PLSVARVINC('23', nil, oItem["attendanceModel"]))
	BEA->BEA_DATSOL := Stod(StrTran(oItem["requestDate"], "-", ""))
	BEA->BEA_INDCLI := aIndCli[1]
	BEA->BEA_INDCL2 := aIndCli[2]
	BEA->BEA_MSG01 := aObs[1]
	BEA->BEA_MSG02 := aObs[2]
	BEA->BEA_LIBERA := "0"

Return

Method cabExecucao(oItem,cAuthType) Class SyncAuthorizations
	Local cCbos		 := Iif(Type('oItem["professional"]["cbos"]["code"]') == "C", oItem["professional"]["cbos"]["code"], "")
	Local cCodEsp	 := Iif(Type('oItem["professional"]["cbos"]["code"]') == "C", Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP'), "")
	Local cCbosSol   := Iif(Type('oItem["sourceAuthorization"]["professional"]["cbos"]["code"]') == "C", oItem["sourceAuthorization"]["professional"]["cbos"]["code"], "")
	Local cCodEspSol := Iif(Type('oItem["sourceAuthorization"]["professional"]["cbos"]["code"]') == "C", Posicione('BAQ', 6, xFilial('BAQ')+cCbosSol,'BAQ_CODESP'), "")
	Local aIndCli	 := PLBreakTxt(oItem["sourceAuthorization"]["clinicalCondition"], {"BEA_INDCLI", "BEA_INDCL2"})
	Local aObs	     := PLBreakTxt(oItem["attendanceNote"], {"BEA_MSG01", "BEA_MSG02"})

	// Campos da guia de solicitação - No HAT, se for execução direta, esses campos vem com os dados da mesma guia de execução
	BEA->BEA_ORIGEM := "1"
	BEA->BEA_GUIPRI := oItem['mainAuthorizationCode']

	if posProf(oItem["sourceAuthorization"]["professional"]["stateAbbreviation"], oItem["sourceAuthorization"]["professional"]["professionalCouncilNumber"], oItem["sourceAuthorization"]["professional"]["professionalCouncil"],oItem["sourceAuthorization"]["professional"]["name"],oItem["sourceAuthorization"]["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
		BEA->BEA_NOMSOL := BB0->BB0_NOME
		BEA->BEA_CDPFSO := BB0->BB0_CODIGO
		BEA->BEA_SIGLA := oItem["sourceAuthorization"]["professional"]["professionalCouncil"]
		BEA->BEA_REGSOL := oItem["sourceAuthorization"]["professional"]["professionalCouncilNumber"]
		BEA->BEA_ESTSOL := oItem["sourceAuthorization"]["professional"]["stateAbbreviation"]
		BEA->BEA_ESPSOL := cCodEspSol
	endif

	BEA->BEA_TIPADM := alltrim(PLSVARVINC('23', nil, oItem["sourceAuthorization"]["attendanceModel"]))
	BEA->BEA_DATSOL := Stod(StrTran(oItem["sourceAuthorization"]["requestDate"], "-", ""))
	BEA->BEA_INDCLI := aIndCli[1]
	BEA->BEA_INDCL2 := aIndCli[2]

	if posProf(oItem["professional"]["stateAbbreviation"], oItem["professional"]["professionalCouncilNumber"], oItem["professional"]["professionalCouncil"],oItem["professional"]["name"],oItem["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
		BEA->BEA_CDPFRE := BB0->BB0_CODIGO
		BEA->BEA_NOMEXE := BB0->BB0_NOME
		BEA->BEA_SIGEXE := oItem["professional"]["professionalCouncil"]
		BEA->BEA_REGEXE := oItem["professional"]["professionalCouncilNumber"]
		BEA->BEA_ESTEXE := oItem["professional"]["stateAbbreviation"]
		BEA->BEA_ESPEXE := cCodEsp
	endif

	BEA->BEA_CODESP := cCodEsp
	BEA->BEA_MSG01 := aObs[1]
	BEA->BEA_MSG02 := aObs[2]
	BEA->BEA_TIPATE := oItem["attendanceType"]
	BEA->BEA_INDACI :=  alltrim(PLSVARVINC('36', nil, oItem["accidentIndication"]))
	BEA->BEA_TIPCON := alltrim(PLSVARVINC('52', nil, oItem["consultationType"]))
	BEA->BEA_TIPSAI := alltrim(PLSVARVINC('39', nil, oItem["closingReason"]))
	BEA->BEA_LIBERA := IIF(cAuthType == HAT_EXAME_EXECUCAO,"0","1")

Return

Method cabInternacao(oItem, cAlias) Class SyncAuthorizations
	Local cCbos			:= Iif(ValType(oItem["professional"]["cbos"]["code"]) == ("N" .OR. "C"), oItem["professional"]["cbos"]["code"], "")
	Local cCodEsp		:= Iif(ValType(oItem["professional"]["cbos"]["code"]) == ("N" .OR. "C"), Posicione('BAQ', 6, xFilial('BAQ')+cCbos,'BAQ_CODESP'), "")
	Local aIndCli	    := PLBreakTxt(oItem["clinicalCondition"], {"BEA_INDCLI", "BEA_INDCL2"})
	Local aObs	        := PLBreakTxt(oItem["attendanceNote"], {"BEA_MSG01", "BEA_MSG02"})
	Local aRetD         := {}
	Local cSubscriberId := oItem["beneficiary"]["subscriberId"]
	Local cOpeUsr       := substr(cSubscriberId, 1,4)
	Local cCodEmp       := substr(cSubscriberId, 5,4)
	Local cMatric       := substr(cSubscriberId, 9,6)
	Local cTipReg       := substr(cSubscriberId, 15,2)
	Local cDigito       := substr(cSubscriberId, 17)

	if cAlias == "BE4"

		if posProf(oItem["professional"]["stateAbbreviation"], oItem["professional"]["professionalCouncilNumber"], oItem["professional"]["professionalCouncil"],oItem["professional"]["name"],oItem["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
			BE4->BE4_NOMSOL := BB0->BB0_NOME
			BE4->BE4_CDPFSO := BB0->BB0_CODIGO
			BE4->BE4_SIGLA := oItem["professional"]["professionalCouncil"]
			BE4->BE4_REGSOL := oItem["professional"]["professionalCouncilNumber"]
			BE4->BE4_ESTSOL := oItem["professional"]["stateAbbreviation"]
			BE4->BE4_ESPSOL := cCodEsp
		endIf

		BE4->BE4_CODESP := cCodEsp
		BE4->BE4_TIPADM := alltrim(PLSVARVINC('23', nil, oItem["attendanceModel"]))
		BE4->BE4_INDCLI := aIndCli[1]
		BE4->BE4_INDCL2 := aIndCli[2]
		BE4->BE4_MSG01 := aObs[1]
		BE4->BE4_MSG02 := aObs[2]
		BE4->BE4_PRVINT :=  Stod(StrTran(oItem["expectedHospitalizationDate"], "-", ""))
		BE4->BE4_TIPINT := cValToChar(STRZERO(val(alltrim(PLSVARVINC('57', nil, oItem["hospType"]))),2))
		BE4->BE4_GRPINT := alltrim(PLSVARVINC('57', nil, oItem["hospType"]))
		BE4->BE4_CID := oItem["primaryICD"]
		BE4->BE4_DESCID := POSICIONE("BA9",1,xFilial("BA9")+AllTrim((oItem["primaryICD"])),"BA9_DOENCA")
		BE4->BE4_REGINT := alltrim(PLSVARVINC('41', nil, oItem["hospRegime"]))
		BE4->BE4_DIASSO := oItem["dailyRequestedQuantity"]
		BE4->BE4_OPESOL := PLSINTPAD()

		aRetD := PLSDADUSR(cOpeUsr+cCodEmp+cMatric+cTipReg+cDigito,"1",.F.,dDataBase)

		if Len(aRetD) > 0 .And. aRetD[1]
			BE4->BE4_PADINT := POSICIONE("BI3",1,xFilial("BI3")+cOpeUsr+aRetD[11]+aRetD[12],"BI3_CODACO")
			BE4->BE4_NOMUSR :=aRetD[6]
			BE4->BE4_CONEMP := BA1->BA1_CONEMP
			BE4->BE4_VERCON := BA1->BA1_VERCON
			BE4->BE4_SUBCON := BA1->BA1_SUBCON
			BE4->BE4_VERSUB := BA1->BA1_VERSUB
			BE4->BE4_MATVID := BA1->BA1_MATVID
			BE4->BE4_CPFUSR := BA1->BA1_CPFUSR
		else
			logInf("[" + self:cTrack + "] BE4 - verifica a PLSDADUSR", self:cFile)
		endIf

	else

		if posProf(oItem["professional"]["stateAbbreviation"], oItem["professional"]["professionalCouncilNumber"],oItem["professional"]["professionalCouncil"],oItem["professional"]["name"],oItem["professional"]["idOnHealthInsurer"], self:cTrack, self:cFile)
			BEA->BEA_NOMSOL := BB0->BB0_NOME
			BEA->BEA_CDPFSO := BB0->BB0_CODIGO
			BEA->BEA_SIGLA := oItem["professional"]["professionalCouncil"]
			BEA->BEA_REGSOL := oItem["professional"]["professionalCouncilNumber"]
			BEA->BEA_ESTSOL := oItem["professional"]["stateAbbreviation"]
			BEA->BEA_ESPSOL := cCodEsp
		endif

		BEA->BEA_ORIGEM := "2"
		BEA->BEA_CODESP := cCodEsp
		BEA->BEA_TIPADM := alltrim(PLSVARVINC('23', nil, oItem["attendanceModel"]))
		BEA->BEA_INDCLI := aIndCli[1]
		BEA->BEA_INDCL2 := aIndCli[2]
		BEA->BEA_MSG01 := aObs[1]
		BEA->BEA_MSG02 := aObs[2]
		BEA->BEA_OPESOL := PLSINTPAD()

	endIf

Return

Method grvAuditoria(cNumGuia, cAuthType) Class SyncAuthorizations
	Local o790C			:= nil
	Local aCabCri       := {}
	Local aDadCri		:= {}
	Local aVetCri       := {}
	Local aHeaderITE    := {}
	Local aColsITE      := {}
	Local aVetITE       := {}

	if cAuthType == HAT_INTERNACAO

		Store Header "BEJ" TO aHeaderITE For .T.
		Store COLS "BEJ" TO aColsITE FROM aHeaderITE VETTRAB aVetITE While;
			BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT) == xFilial("BEJ")+cNumGuia

		Store Header "BEL" TO aCabCri For .T.
		Store COLS "BEL" TO aDadCri FROM aCabCri VETTRAB aVetCri While;
			BEL->(BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT) == xFilial("BEL")+cNumGuia

		o790C := PLSA790C():New(.T.)
		o790C:SetAuditoria(.T.,.T.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BEL",aColsITE,aHeaderITE,"BEJ",.F., .F.)
		o790C:Destroy()

	else

		Store Header "BE2" TO aHeaderITE For .T.
		Store COLS "BE2" TO aColsITE FROM aHeaderITE VETTRAB aVetITE While;
			BE2->(BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT) == xFilial("BE2")+cNumGuia

		Store Header "BEG" TO aCabCri For .T.
		Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aVetCri While;
			BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT) == xFilial("BEG")+cNumGuia

		o790C := PLSA790C():New(.T.)
		o790C:SetAuditoria(.T.,.F.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BEG",aColsITE,aHeaderITE,"BE2",.F., .F.)
		o790C:Destroy()

	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} cancelAuditoria
Incluir status de cancelado na auditoria.

@param cNumGuia		Numero da Guia .
@return Nil

@author  Robson Nayland
/*/
//-------------------------------------------------------------------

Method cancelAuditoria(cNumGuia) Class SyncAuthorizations

	aAreaAudit := GetArea()
	DbSelectArea('B53')
	B53->(DbSetORder(1))
	If GetNewPar("MV_PL790NE","0") == "1" .and. (B53->(DbSeek(xFilial("B53")+cNumGuia)))
		B53->(RecLock("B53",.F.))
		B53->B53_STATUS:='6'
		B53->(MsUnlock())
	Endif
	RestArea(aAreaAudit)


Return

