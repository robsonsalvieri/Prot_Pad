#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "PLSMGER.CH"
#INCLUDE "hatActions.ch"

#define __aCdCri187 {"573","Demanda por requerimento"}

/*/{Protheus.doc} SyncClinicalAttach
    Integracao ClinicalAttachments
    @type  Class
    @author pls
    @since 10/03/2021
/*/
Class SyncClinicalAttach

	Data cTrack
	Data cFile

	Data cCodTiss
	Data cDesTiss
	Data aTabDup As Array

	Method New()

	Method persist(oItem)
	Method persistCancel(oItem)

	Method grvAuditoria(cNumGuia)

EndClass

Method New(cTrack, cFile) Class SyncClinicalAttach
	self:cCodTiss    := getNewPar("MV_MOTTISS","")
	self:aTabDup     := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
	self:cTrack      := cTrack
	self:cFile       := cFile

	dbSelectArea("B4A")
	dbSelectArea("B4C")
	dbSelectArea("BEG")
	dbSelectArea("B2Z")


	BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	B4A->(dbSetOrder(1)) //B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT
	B4C->(dbSetOrder(3)) //B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_CODPAD+B4C_CODPRO
	BCT->(dbSetOrder(1)) //BCT_FILIAL+BCT_CODOPE+BCT_PROPRI+BCT_CODGLO
	BTQ->(dbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
	B53->(dbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV
	BEG->(dbSetOrder(2)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN+BEG_CODGLO+BEG_DESGLO
	B2Z->(dbSetOrder(4)) //B2Z_FILIAL+B2Z_OPEMOV+B2Z_CODRDA+B2Z_NUMAUT+B2Z_SEQUEN

	if BTQ->( msSeek(xFilial("BTQ") + "38" + self:cCodTiss) )
		self:cCodTiss := BTQ->BTQ_CDTERM
		self:cDesTiss := BTQ->BTQ_DESTER
	else
		logInf("[" + self:cTrack + "] tabela 38 invalida - " + self:cCodTiss, self:cFile)
	endIf

Return self

Method persist(oItem) Class  SyncClinicalAttach
	local cNumAut       := oItem["attachNumber"]
	local cOpmeve       := Substr(oItem["attachNumber"],1,4)
	local cAnoAut       := Substr(oItem["attachNumber"],5,4)
	local cMesAut       := Substr(oItem["attachNumber"],9,2)
	local lAudGuia      := oItem["authorizationStatus"] == '6'
	local cNumProto     := oItem["attendanceProtocol"]
	local cStatus       := oItem["authorizationStatus"]
	local aRetAux       := PLSXVLDCAL(Stod(StrTran(oItem["requestedDate"],"-","")),PLSINTPAD(),.T.,"","")
	local oProced       := nil
	local cCodOpe       := PlsIntPad()
	local cCodTab       := ''
	local cCodProc      := ''
	local cCodTabDePara := ''
	local cCodProcDePara:= ''
	local cSequen       := ''
	local nQtdPro       := 0
	local nQtdAut       := 0
	local nCritica      := 1
	local nLenCritica   := 0
	local nProced       := 0
	local lRet          := .f.

	lRet := BA1->(msSeek(xFilial("BA1") + oItem["subscriberId"]))

	if !lRet
		logInf("[" + self:cTrack + "] usuario nao existe - " + oItem["subscriberId"], self:cFile)
	endIf

	lRet := !B4A->(msSeek(xFilial('B4A') + cNumAut))
	if lRet

		B4A->(RecLock("B4A",.T.))
		B4A->B4A_FILIAL  :=  xFilial("B4A")
		B4A->B4A_OPEMOV  := cOpmeve
		B4A->B4A_TIPANE  := iIf(oItem["attachType"]=="14","1",iIf(oItem["attachType"]=="13","2","3"))
		B4A->B4A_TIPGUI  := iIf(oItem["journey"]=="13","07",iIf(oItem["journey"]=="14","08","09"))
		B4A->B4A_PROATE  := oItem["attendanceProtocol"]
		B4A->B4A_NUMAUT  := Substr(oItem["attachNumber"],11,8)
		B4A->B4A_GUIREF  := oItem["mainAuthorizationCode"]
		B4A->B4A_SENHA   := oItem["password"]
		B4A->B4A_DATSOL  := sTod(StrTran(oItem["requestedDate"],"-",""))
		B4A->B4A_DATPRO  := sTod(StrTran(oItem["requestedDate"],"-","")) //Mudança de authorizedDate para requestedDate - recomendacao da equipe HAT
		B4A->B4A_GUIOPE  := oItem["idOnHealthProvider"]
		B4A->B4A_STATUS  := oItem["authorizationStatus"]
		B4A->B4A_MATANT  := BA1->BA1_MATANT
		B4A->B4A_OPEUSR  := BA1->BA1_CODINT

		B4A->B4A_CODEMP  := BA1->BA1_CODEMP
		B4A->B4A_CONEMP  := BA1->BA1_CONEMP
		B4A->B4A_SUBCON  := BA1->BA1_SUBCON
		B4A->B4A_VERCON  := BA1->BA1_VERCON
		B4A->B4A_VERSUB  := BA1->BA1_VERSUB

		B4A->B4A_MATRIC := BA1->BA1_MATRIC
		B4A->B4A_TIPREG := BA1->BA1_TIPREG
		B4A->B4A_DIGITO := BA1->BA1_DIGITO
		B4A->B4A_NOMUSR := BA1->BA1_NOMUSR
		B4A->B4A_CANCEL := If(oItem["isCancelled"],"1","0")
		B4A->B4A_ANOAUT := cAnoAut
		B4A->B4A_MESAUT := cMesAut
		B4A->B4A_AUDITO := iif(lAudGuia,"1","0")
		B4A->B4A_IDADE  := DateDiffYear( Date() , BA1->BA1_DATNAS )
		B4A->B4A_SEXO   := BA1->BA1_SEXO

		B4A->B4A_TPGRV  := "2"
		B4A->B4A_COMUNI := "1"
		B4A->B4A_DESOPE := cOpmeve
		B4A->B4A_GUIPRE := oItem["idOnHealthProvider"]
		B4A->B4A_STTISS := PLSANLSTIG(oItem["authorizationStatus"])

		if len(aRetAux) > 4
			B4A->B4A_ANOPAG := aRetAux[4]
			B4A->B4A_MESPAG := aRetAux[5]
		endIf

		B4A->B4A_NOMSOL := Iif(ValType(oItem["professional"]["name"]) == "U", "" ,oItem["professional"]["name"])
		B4A->B4A_EMASOL := oItem["email"]
		B4A->B4A_TELSOL := oItem["phoneNumber"]

		If oItem["attachType"] == "12" // OPME

			B4A->B4A_JUSTTE := oItem["technicalJustification"]
			B4A->B4A_ESPMAT := oItem["materialSpec"]

		ElseIf oItem["attachType"] == "13" // Quimio

			B4A->B4A_PESO   := oItem["beneficiaryWeight"]
			B4A->B4A_ALTURA := oItem["beneficiaryHeight"]
			B4A->B4A_DATDIA := sTod(StrTran(oItem["diagnosisDate"],"-",""))
			B4A->B4A_CIDPRI := oItem["primaryICD"]
			B4A->B4A_CIDSEC := oItem["secondaryICD"]
			B4A->B4A_CIDTER := oItem["terciaryICD"]
			B4A->B4A_CIDQUA := oItem["quaternaryICD"]
			B4A->B4A_ESTADI := oItem["staging"]
			B4A->B4A_TIPQUI := oItem["chemotherapyType"]
			B4A->B4A_FINALI := oItem["purpose"]
			B4A->B4A_ECOG   := oItem["ecog"]
			B4A->B4A_TUMOR  := oItem["tumor"]
			B4A->B4A_NODULO := oItem["nodule"]
			B4A->B4A_METAST := oItem["metastasis"]
			B4A->B4A_PLATER := oItem["therapeuticPlan"]
			B4A->B4A_DIAGCH := oItem["histopathologicalDiagnosis"]
			B4A->B4A_INFREL := oItem["relevantInformations"]
			B4A->B4A_CIRURG := oItem["surgery"]
			B4A->B4A_DATCIR := sTod(StrTran(oItem["surgeryDate"],"-",""))
			B4A->B4A_AREA   := oItem["irradiatedArea"]
			B4A->B4A_DATIRR := sTod(StrTran(oItem["radioApplicationDate"],"-",""))
			B4A->B4A_INTCIC := oItem["intervalBetweenCycles"]
			B4A->B4A_NROCIC := oItem["expectedCyclesNumber"]
			B4A->B4A_CICATU := oItem["currentCycle"]
			B4A->B4A_SUPCOR := Sqrt((oItem["beneficiaryWeight"]*oItem["beneficiaryHeight"])/3600)

		ElseIf oItem["attachType"] == "14" // Radio

			B4A->B4A_DATDIA := sTod(StrTran(oItem["diagnosisDate"],"-",""))
			B4A->B4A_CIDSEC := oItem["secondaryICD"]
			B4A->B4A_CIDTER := oItem["terciaryICD"]
			B4A->B4A_CIDQUA := oItem["quaternaryICD"]
			B4A->B4A_DIAIMG := oItem["imageDiagnosis"]
			B4A->B4A_ESTADI := oItem["staging"]
			B4A->B4A_ECOG   := oItem["ecog"]
			B4A->B4A_FINALI := oItem["purpose"]
			B4A->B4A_DIAGCH := oItem["histopathologicalDiagnosis"]
			B4A->B4A_INFREL := oItem["relevantInformations"]
			B4A->B4A_CIRURG := oItem["surgery"]
			B4A->B4A_DATCIR := sTod(StrTran(oItem["surgeryDate"],"-",""))
			B4A->B4A_QUIMIO := oItem["chemotherapy"]
			B4A->B4A_DATQUI := sTod(StrTran(oItem["chemoApplicationDate"],"-",""))
			B4A->B4A_NROCAM := oItem["radiationFieldsNumber"]
			B4A->B4A_DOSDIA := oItem["dailyDose"]
			B4A->B4A_DOSTOT := oItem["totalDosage"]
			B4A->B4A_NRODIA := oItem["numberOfDays"]
			B4A->B4A_DATPRE := sTod(StrTran(oItem["drugAdministrationStartDate"],"-",""))

		Endif

		B4A->(MsUnlock())
		// Gravando Itens
		For nProced := 1 to Len(oItem["procedures"])

			oProced         := oItem["procedures"][nProced]
			cCodTab         := oProced["tableCode"]
			cCodProc        := oProced["procedureCode"]
			cCodTabDePara   := AllTrim(PLSVARVINC('87','BR4',cCodTab))
			cCodProcDePara  := AllTrim(PLSVARVINC(cCodTab,'BR8', cCodProc, cCodTabDePara+cCodProc,,self:aTabDup,@cCodTabDePara))
			cSequen         := strzero(nProced, Len(B4C->B4C_SEQUEN))

			//Quimio
			if oItem["attachType"] == "13"
				nQtdPro := iif(empty(oProced["totalCycleDosage"]),0,oProced["totalCycleDosage"])
				nQtdAut := iif(empty(oProced["totalCycleDosage"]),0,oProced["totalCycleDosage"])
			else
				nQtdPro := iif(empty(oProced["requestedQuantity"]) ,0,oProced["requestedQuantity"])
				nQtdAut := iif(empty(oProced["authorizedQuantity"]),0,oProced["authorizedQuantity"])
			endIf

			grvB2Z(self:cTrack, self:cFile, cCodOpe, oItem["healthProvider"]["healthProviderId"], cNumAut, oItem["subscriberId"], stod(StrTran(oItem["requestedDate"],"-","")), oItem["password"], cSequen,;
				cCodTabDePara, cCodProcDePara, cValToChar(oItem["id"]), iIf(oItem["journey"]=="13", "07", iIf(oItem["journey"]=="14","08","09")), nQtdPro, nQtdAut )

			if !B4C->(msSeek(xFilial("B4C") + cNumAut + cCodTabDePara + cCodProcDePara))

				B4C->(RecLock("B4C",.T.))
				B4C->B4C_FILIAL := xFilial("B4C")
				B4C->B4C_OPEMOV := cOpmeve
				B4C->B4C_ANOAUT := cAnoAut
				B4C->B4C_MESAUT := cMesAut
				B4C->B4C_NUMAUT := Substr(oItem["attachNumber"],11,8)
				B4C->B4C_IMGSTA := Iif(oItem["authorizationStatus"]=="1","ENABLE","DISABLE")
				B4C->B4C_TPGRV  := "2"
				B4C->B4C_SEQUEN := cSequen
				B4C->B4C_DATPRO := sTod(StrTran(oItem["authorizedDate"],"-",""))
				B4C->B4C_CODPAD := cCodTabDePara
				B4C->B4C_CODPRO := cCodProcDePara
				B4C->B4C_DESPRO := POSICIONE('BR8',1,xFilial('BR8') + cCodTabDePara + cCodProcDePara,'BR8_DESCRI')
				B4C->B4C_QTDPRO :=  nQtdPro
				B4C->B4C_QTDSOL :=  nQtdPro
				B4C->B4C_AUDITO := iif(oProced["status"] == 2, "1", "0")
				B4C->B4C_VLRUNT := iif(empty(oProced["unitaryWorth"]), 0, oProced["unitaryWorth"])
				B4C->B4C_VLRUNA := iif(empty(oProced["unitaryWorth"]), 0, oProced["unitaryWorth"])
				B4C->B4C_SALDO  := nQtdAut
				B4C->B4C_NIVCRI := iif(oProced["status"] <> 1,"HAT","")

				B4C->B4C_NIVAUT := ""
				B4C->B4C_CHVNIV := ""
				B4C->B4C_STATUS :=  iif(oProced["status"] == 1, "1", "0")
				B4C->B4C_NIVEL := ""

				B4C->B4C_OPCAO := ""
				B4C->B4C_REGANV := ""
				B4C->B4C_REFMAF := ""
				B4C->B4C_AUTFUN := ""
				B4C->B4C_COMUNI := ""
				B4C->B4C_NRTROL := ""
				B4C->B4C_NRAOPE := ""

				if oItem["attachType"] == "13" // Quimio
					B4C->B4C_UNMED  := iif(empty(oProced["unitOfMeasurement"]), "", oProced["unitOfMeasurement"])
					B4C->B4C_VIAADM := iif(empty(oProced["accessWay"]), "", oProced["accessWay"])
					B4C->B4C_FREQUE := iif(empty(oProced["frequency"]), 0, oProced["frequency"])
				else
					B4C->B4C_UNMED  := ""
					B4C->B4C_VIAADM := ""
					B4C->B4C_FREQUE := 0
				endIf

				B4C->(MsUnlock())

			else
				logInf("[" + self:cTrack + "] B4C - item do anexo ja existe - " + cCodTabDePara + cCodProcDePara, self:cFile)
			endIf

			// inclusao de critricas
			nLenCritica := iIf(!empty(oItem["procedures"][nProced]["rejectionCauses"]), Len(oItem["procedures"][nProced]["rejectionCauses"]), 0)
			nCritica    := 1

			while lRet .and. nCritica <= nLenCritica

				oCritica := oItem["procedures"][nProced]["rejectionCauses"][nCritica]

				lRet := chkJsonTag(self:cTrack, oCritica, {"code"},,self:cFile)

				if lRet

					if BCT->(msSeek(xFilial('BCT') + cCodOpe + oCritica["code"]))

						if ! BEG->( msSeek( xFilial('BEG') + cCodOpe + cAnoAut + cMesAut + subStr(oItem["attachNumber"],11,8) + strzero(nProced, 3) + oCritica["code"] + BCT->BCT_DESCRI ) )

							BEG->(RecLock("BEG",.T.))
							BEG->BEG_FILIAL := xFilial("BEG")
							BEG->BEG_OPEMOV := cCodOpe
							BEG->BEG_ANOAUT := cAnoAut
							BEG->BEG_MESAUT := cMesAut
							BEG->BEG_NUMAUT := Substr(oItem["attachNumber"],11,8)
							BEG->BEG_SEQUEN := strzero(nProced, 3)
							BEG->BEG_CODGLO := oCritica["code"]
							BEG->BEG_DESGLO := BCT->BCT_DESCRI
							BEG->BEG_SEQCRI := strzero(nCritica, 3)
							BEG->BEG_TIPO   := BCT->BCT_TIPO
							BEG->(MsUnlock())

						else
							logInf("[" + self:cTrack + "] BEG - critica do item ja existe - " + cCodOpe + cAnoAut + cMesAut + Substr(oItem["attachNumber"],11,8) + strzero(nProced, 3) + oCritica["code"] + BCT->BCT_DESCRI, self:cFile)
						endIf

					else
						logInf("[" + self:cTrack + "] BCT - nao existe - " + oCritica["code"], self:cFile)
					endIf

				endIf

				nCritica++

			endDo

			if nLenCritica > 1
				FreeObj(oCritica)
			endIf

		Next nProced

		if ! Empty(cNumProto) .and. cStatus $  "2|6|3"
			gerRegB00(oItem["attendanceProtocol"],,"B4A",.T.,.f.,BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO,.f.,,,,,cCodOpe,,,,,,,,.T.,.f.,cNumAut)
			P773AutCon("B4A",cNumProto,cNumAut)
		endIf

		if lAudGuia .And. oItem["attachType"] <> "14" //Nao gera B53 para guias de radio
			self:grvAuditoria(cNumAut)
		endIf

		if lRet
			lRet := isWorkSync()
		endIf

	else
		logInf("[" + self:cTrack + "] B4A - anexo ja existe", self:cFile)
	endIf

	B4A->(dbCloseArea())
	B4C->(dbCloseArea())
	BEG->(dbCloseArea())
	B2Z->(dbCloseArea())
	BA1->(dbCloseArea())
	BCT->(dbCloseArea())
	BTQ->(dbCloseArea())
	B53->(dbCloseArea())

Return lRet

Method persistCancel(oItem) Class SyncClinicalAttach
	Local cCodOpe      := PlsIntPad()
	Local cAuthNumber  := oItem["attachNumber"]
	Local cAnoAut      := substr(cAuthNumber, 5,4)
	Local cMesAut      := substr(cAuthNumber, 9,2)
	Local cNumAut      := substr(cAuthNumber, 11)
	local lRet         := .f.

	lRet := B4A->( MsSeek( xFilial("B4A") + cCodOpe + cAnoAut + cMesAut + cNumAut) )

	if lRet

		B4A->(recLock("B4A", .f.))
		B4A->B4A_CANCEL := "1"
		B4A->B4A_STATUS := "3"
		B4A->B4A_CANTIS := self:cCodTiss
		B4A->B4A_STTISS := PLSANLSTIG(nil, .f., .t.)
		B4A->(msUnlock())

		if B4C->( MsSeek( xFilial("B4C") + cCodOpe + cAnoAut + cMesAut + cNumAut) )

			while !B4C->(Eof()) .And. B4A->(B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT) == B4C->(B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT)

				B4C->(RecLock("B4C",.F.))
				B4C->B4C_STATUS := "0"
				B4C->(MsUnlock())

				B4C->(DbSkip())
			endDo

		else
			logInf("[" + self:cTrack + "] B4C - nao existe item para este anexo", self:cFile)
		endIf

		if B53->(msSeek(xFilial('B53') + cCodOpe + cAnoAut + cMesAut + cNumAut))
			B53->(RecLock("B53",.F.))
			B53->B53_STATUS := "6"
			B53->B53_SITUAC := "0"
			B53->(MsUnlock())
		endIf

	else
		logInf("[" + self:cTrack + "] B4A - anexo nao existe", self:cFile)
	endIf

	if lRet
		lRet := isWorkSync()
	endIf

	B4A->(dbCloseArea())
	B4C->(dbCloseArea())
	BEG->(dbCloseArea())
	B2Z->(dbCloseArea())
	BA1->(dbCloseArea())
	BCT->(dbCloseArea())
	BTQ->(dbCloseArea())
	B53->(dbCloseArea())

Return lRet

Method grvAuditoria(cNumGuia) Class SyncClinicalAttach
	Local o790C			:= nil
	Local aCabCri       := {}
	Local aDadCri		:= {}
	Local aVetCri       := {}
	Local aHeaderITE    := {}
	Local aColsITE      := {}
	Local aVetITE       := {}

	Inclui := .T.

	Store Header "B4C" TO aHeaderITE For .T.
	Store COLS "B4C" TO aColsITE FROM aHeaderITE VETTRAB aVetITE While;
		B4C->(B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT) == xFilial("B4C")+cNumGuia

	Store Header "BEG" TO aCabCri For .T.
	Store COLS "BEG" TO aDadCri FROM aCabCri VETTRAB aVetCri While;
		BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT) == xFilial("BEG")+cNumGuia

	o790C := PLSA790C():New(.T.)
	o790C:SetAuditoria(.T.,.F.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BEG",aColsITE,aHeaderITE,"B4C",.T., .F.,"6")
	o790C:Destroy()

Return
