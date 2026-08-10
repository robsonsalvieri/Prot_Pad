#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "PLSMGER.CH"
#INCLUDE "hatActions.ch"

#define __aCdCri187 {"573","Demanda por requerimento"}

/*/{Protheus.doc} SyncTreatmentExtensions
    Integracao TreatmentExtensions
    @type  Class
    @author pls
    @since 10/03/2021
/*/
Class SyncTreatmentExtensions

    Data cTrack
    Data cFile

    Data cCodTiss
    Data aTabDup As Array

    Method New()

    Method persist(oItem)
    Method persistCancel(oItem)

    Method grvCabB4Q(oItem)
    Method grvIteBQV(oItem,nProced)
    Method grvCriBQZ(oItem,nProced,nLenCri)
    Method grvPacB43(oItem,cSequen,cCodTab,cCodPro,dDatPro)
    Method grvAuditoria(cNumGuia)

EndClass

Method New(cTrack, cFile) Class SyncTreatmentExtensions

    self:cCodTiss    := getNewPar("MV_MOTTISS","")
    self:aTabDup     := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))
    self:cTrack      := cTrack
    self:cFile       := cFile

    //Monta HashMap do Cabecalho B4Q
    DbSelectArea("B4Q")

    //Monta HashMap dos Eventos BQV
    DbSelectArea("BQV")

    //Monta HashMap das Criticas BQZ
    DbSelectArea("BQZ")

    //Monta HashMap do Cabecalho B2Z
    DbSelectArea("B2Z")

    //Monta HashMap do Pacote B43
    DbSelectArea("B43")

    //Posiciona indices
    BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
    B4Q->(dbSetOrder(1)) //B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT
    BAU->(dbSetOrder(1)) //BAU_FILIAL+BAU_CODIGO
    BE4->(dbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
    BTQ->(dbSetOrder(1)) //BTQ_FILIAL+BTQ_CODTAB+BTQ_CDTERM
    BB0->(dbSetOrder(4)) //BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE...
    BQV->(dbSetOrder(1)) //BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
    BQZ->(dbSetOrder(1)) //BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN
    B53->(dbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV
    B2Z->(dbSetOrder(4)) //B2Z_FILIAL+B2Z_OPEMOV+B2Z_CODRDA+B2Z_NUMAUT+B2Z_SEQUEN

    if BTQ->( msSeek(xFilial("BTQ") + "38" + self:cCodTiss) )
        self:cCodTiss := BTQ->BTQ_CDTERM
    else
        logInf("[" + self:cTrack + "] tabela 38 invalida - " + self:cCodTiss, self:cFile)
    endIf

Return self

Method persist(oItem) Class  SyncTreatmentExtensions
    local cNumAut   := oItem["treatmentExtensionNumber"]
    local lAudGuia  := oItem["authorizationStatus"] == '6'
    local nProced   := 0
    local lRet      := .f.

    lRet := BA1->(msSeek(xFilial("BA1") + oItem["subscriberId"]))

    if lRet

        //Grava cabecalho
        lRet := self:grvCabB4Q(oItem)

        if lRet

            //Grava eventos/criticas/B2Z
            For nProced := 1 to Len(oItem["procedures"])
                self:grvIteBQV(oItem,nProced)
            Next nProced

            //Gera guia de auditoria
            if lAudGuia
                self:grvAuditoria(cNumAut)
            endIf

        else
            logInf("[" + self:cTrack + "] B4Q - prorrogacao ja existe", self:cFile)
        endIf

    else
        logInf("[" + self:cTrack + "] BA1 - usuario nao existe - " + oItem["subscriberId"], self:cFile)
    endIf

    if lRet
        lRet := isWorkSync()
    endIf

    B4Q->(dbCloseArea())
    BQV->(dbCloseArea())
    BQZ->(dbCloseArea())
    B2Z->(dbCloseArea())
    B43->(dbCloseArea())
    BA1->(dbCloseArea())
    BAU->(dbCloseArea())
    BE4->(dbCloseArea())
    BTQ->(dbCloseArea())
    BB0->(dbCloseArea())
    B53->(dbCloseArea())

Return lRet

Method persistCancel(oItem) Class SyncTreatmentExtensions
    Local cCodOpe       := PlsIntPad()
    Local cAuthNumber   := oItem["treatmentExtensionNumber"]
    Local cAnoAut       := substr(cAuthNumber, 5,4)
    Local cMesAut       := substr(cAuthNumber, 9,2)
    Local cNumAut       := substr(cAuthNumber, 11)
    local lRet          := .f.

    lRet := B4Q->( MsSeek( xFilial("B4Q")+cCodOpe+cAnoAut+cMesAut+cNumAut) )

    if lRet

        B4Q->(RecLock("B4Q",.F.))
        B4Q->B4Q_CANCEL := "1"
        B4Q->B4Q_STATUS := "3"
        B4Q->B4Q_CANTIS := self:cCodTiss
        B4Q->B4Q_STTISS := PLSANLSTIG(nil,.F.,.T.)
        B4Q->(MsUnlock())

        if BQV->( MsSeek( xFilial("BQV") + cCodOpe + cAnoAut + cMesAut + cNumAut))

            while !BQV->(Eof()) .And. B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT) == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)

                BQV->(RecLock("BQV",.F.))
                BQV->BQV_STATUS := "0"
                BQV->(MsUnlock())

                BQV->(DbSkip())
            endDo

        else
            logInf("[" + self:cTrack + "] BQV - nao existe item para esta prorrogacao", self:cFile)
        endIf

        if B53->(msSeek(xFilial('B53') + cCodOpe + cAnoAut + cMesAut + cNumAut))
            B53->(RecLock("B53",.F.))
            B53->B53_STATUS := "6"
            B53->B53_SITUAC := "0"
            B53->(MsUnlock())
        endIf

    else
        logInf("[" + self:cTrack + "] B4Q - prorrogacao nao existe", self:cFile)
    endIf

    if lRet
        lRet := isWorkSync()
    endIf

    B4Q->(dbCloseArea())
    BQV->(dbCloseArea())
    BQZ->(dbCloseArea())
    B2Z->(dbCloseArea())
    B43->(dbCloseArea())
    BA1->(dbCloseArea())
    BAU->(dbCloseArea())
    BE4->(dbCloseArea())
    BTQ->(dbCloseArea())
    BB0->(dbCloseArea())
    B53->(dbCloseArea())

Return lRet

Method grvCabB4Q(oItem) Class SyncTreatmentExtensions

    Local lAudGuia  := oItem["authorizationStatus"] == '6'
    Local cGuia     := oItem["treatmentExtensionNumber"]
    Local oProf     := oItem["professional"]
    Local cOpeMov   := Substr(cGuia,1,4)
    Local cAnoAut   := Substr(cGuia,5,4)
    Local cMesAut   := Substr(cGuia,9,2)
    Local cNumAut   := Substr(cGuia,11,8)
    Local nAltura   := iif(empty(oItem["beneficiary"]["height"]), 0, oItem["beneficiary"]["height"])
    Local nPeso     := iif(empty(oItem["beneficiary"]["weight"]), 0, oItem["beneficiary"]["weight"])
    Local dDatPro   := iif(!Empty(oItem["authorizedDate"]),Stod(StrTran(oItem["authorizedDate"],"-","")),Stod(StrTran(oItem["requestedDate"],"-","")))
    Local cNumProt  := oItem["attendanceProtocol"]
    Local cStatus   := oItem["authorizationStatus"]
    Local cCodRda   := ''
    Local cRdaName  := ''
    local lRet      := .f.

    lRet := BAU->(msSeek(xFilial('BAU') + oItem["healthProviderId"]))

    if !lRet
        logInf("[" + self:cTrack + "] rede de atendimento nao existe - " + oItem["healthProviderId"], self:cFile)
    endIf

    if lRet

        cCodRda  := BAU->BAU_CODIGO
        cRdaName := Alltrim(BAU->BAU_NOME)

        lRet := !B4Q->(msSeek(xFilial('B4Q')+cGuia))

        if lRet

            B4Q->(RecLock("B4Q",.T.))
            B4Q->B4Q_FILIAL := xFilial("B4Q")
            B4Q->B4Q_OPEMOV := cOpeMov
            B4Q->B4Q_NOMUSR := Alltrim(BA1->BA1_NOMUSR)
            B4Q->B4Q_STATUS := cStatus
            B4Q->B4Q_AUDITO := iif(lAudGuia,"1","0")
            B4Q->B4Q_CANCEL := If(oItem["isCancelled"],"1","0")
            B4Q->B4Q_ANOAUT := cAnoAut
            B4Q->B4Q_MESAUT := cMesAut
            B4Q->B4Q_NUMAUT := cNumAut
            B4Q->B4Q_GUIREF := oItem["mainAuthorizationCode"]
            B4Q->B4Q_DATPRO := dDatPro
            B4Q->B4Q_DATSOL := Stod(StrTran(oItem["requestedDate"],"-",""))
            B4Q->B4Q_SENHA  := oItem["password"]
            B4Q->B4Q_GUIOPE := oItem["idOnHealthProvider"]
            B4Q->B4Q_MATANT := BA1->BA1_MATANT
            B4Q->B4Q_OPEUSR := BA1->BA1_CODINT
            B4Q->B4Q_CODEMP := BA1->BA1_CODEMP
            B4Q->B4Q_CONEMP := BA1->BA1_CONEMP
            B4Q->B4Q_SUBCON := BA1->BA1_SUBCON
            B4Q->B4Q_VERCON := BA1->BA1_VERCON
            B4Q->B4Q_VERSUB := BA1->BA1_VERSUB
            B4Q->B4Q_MATRIC := BA1->BA1_MATRIC
            B4Q->B4Q_TIPREG := BA1->BA1_TIPREG
            B4Q->B4Q_DIGITO := BA1->BA1_DIGITO
            B4Q->B4Q_PROATE := oItem["attendanceProtocol"]
            B4Q->B4Q_CODRDA := cCodRda
            B4Q->B4Q_NOMRDA := cRdaName
            B4Q->B4Q_ALTURA := nAltura
            B4Q->B4Q_PESO   := nPeso
            B4Q->B4Q_SUPCOR := iif(nPeso > 0 .And. nAltura > 0,Sqrt((nPeso*nAltura)/3600),0)
            B4Q->B4Q_IDADE  := DateDiffYear( Date() , BA1->BA1_DATNAS )
            B4Q->B4Q_SEXO   := BA1->BA1_SEXO
            B4Q->B4Q_TELSOL := Iif(ValType(oItem["professional"]["phoneNumber"]) == "U","", oItem["professional"]["phoneNumber"])
            B4Q->B4Q_EMASOL := Iif(ValType(oItem["professional"]["email"]) == "U","", oItem["professional"]["email"])
            B4Q->B4Q_STTISS := PLSANLSTIG(oItem["authorizationStatus"])
            B4Q->B4Q_QTDADD := iif(empty(oItem["dailyRequestedQuantity"]), 0, oItem["dailyRequestedQuantity"])
            B4Q->B4Q_QTDADA := iif(empty(oItem["dailyAuthorizedQuantity"]), 0, oItem["dailyAuthorizedQuantity"])
            B4Q->B4Q_OPESOL := cOpeMov
            B4Q->B4Q_COMUNI :=  "0"
            B4Q->B4Q_NRAOPE :=  ""
            B4Q->B4Q_TIPACO := oItem["requestedRoomType"]
            B4Q->B4Q_TIPACA := oItem["authorizedRoomType"]
            B4Q->B4Q_INDCLI := oItem["clinicalCondition"]
            B4Q->B4Q_JUSOPE := oItem["healthInsurerNote"]
            B4Q->B4Q_JUSOBS := oItem["attendanceNote"]
            B4Q->B4Q_GUIPRE := oItem["idOnHealthProvider"]

            //Dados do Solicitante
            If ValType(oProf) == "J" .And. posProf(oProf["stateAbbreviation"], oProf["professionalCouncilNumber"], oProf["professionalCouncil"], oProf["name"], oProf["professionalIdentifier"], self:cTrack, self:cFile)

                B4Q->B4Q_CDPFSO := BB0->BB0_CODIGO
                B4Q->B4Q_NOMSOL := BB0->BB0_NOME
                B4Q->B4Q_SIGLA  := oProf["professionalCouncil"]
                B4Q->B4Q_REGSOL := oProf["professionalCouncilNumber"]
                B4Q->B4Q_ESTSOL := oProf["stateAbbreviation"]

            endIf

            B4Q->(MsUnlock())

            if ! Empty(cNumProt) .and. cStatus $  "2|6|3"
                gerRegB00(cNumProt,,"B4Q",.T.,.F.,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),.F.,,,,,cOpeMov,,,,,,,,.T.,.F.,oItem["mainAuthorizationCode"])
                P773AutCon("B4Q",cNumProt,cOpeMov+cAnoAut+cMesAut+cNumAut)
            endif

        endIf

    endIf

Return lRet

Method grvIteBQV(oItem,nProced) Class SyncTreatmentExtensions
    Local oProced := oItem["procedures"][nProced]
    Local cGuia   := oItem["treatmentExtensionNumber"]
    Local cOpeMov := Substr(cGuia,1,4)
    Local cAnoAut := Substr(cGuia,5,4)
    Local cMesAut := Substr(cGuia,9,2)
    Local cNumAut := Substr(cGuia,11,8)
    Local cCodTab := AllTrim(PLSVARVINC('87','BR4',oProced["tableCode"]))
    Local cCodPro := AllTrim(PLSVARVINC(oProced["tableCode"],'BR8', oProced["procedureCode"], cCodTab+oProced["procedureCode"],,self:aTabDup,@cCodTab))
    Local cSequen := oProced["sequence"]  //strzero(nProced, Len(BQV->BQV_SEQUEN))
    Local dDatPro := iif(!Empty(oItem["authorizedDate"]),Stod(StrTran(oItem["authorizedDate"],"-","")),Stod(StrTran(oItem["requestedDate"],"-","")))
    Local nLenCri := 0
    local lRet    := .f.

    lRet := !BQV->(msSeek(xFilial("BQV") + cGuia + cSequen))

    if lRet

        BQV->(RecLock("BQV",.T.))
        BQV->BQV_FILIAL := xFilial("BQV")
        BQV->BQV_CODOPE := cOpeMov
        BQV->BQV_ANOINT := cAnoAut
        BQV->BQV_MESINT := cMesAut
        BQV->BQV_NUMINT := cNumAut
        BQV->BQV_CODPAD := cCodTab
        BQV->BQV_CODPRO := cCodPro
        BQV->BQV_QTDSOL := iif(empty(oProced["requestedQuantity"]), 0, oProced["requestedQuantity"])
        BQV->BQV_QTDPRO := iif(empty(oProced["requestedQuantity"]), 0, oProced["requestedQuantity"])
        BQV->BQV_OPEUSR := BA1->BA1_CODINT
        BQV->BQV_CODEMP := BA1->BA1_CODEMP
        BQV->BQV_MATRIC := BA1->BA1_MATRIC
        BQV->BQV_TIPREG := BA1->BA1_TIPREG
        BQV->BQV_DIGITO := BA1->BA1_DIGITO
        BQV->BQV_SEQUEN := cSequen
        BQV->BQV_DESPRO := Posicione('BR8',1,xFilial('BR8') + cCodTab + cCodPro,'BR8_DESCRI')
        BQV->BQV_DATPRO := dDatPro
        BQV->BQV_HORPRO := StrTran(Time(),":","")
        BQV->BQV_NIVCRI := iif(oProced["status"] <> 1,"HAT","")
        BQV->BQV_TRACON := "0"
        BQV->BQV_COMUNI := "0"
        BQV->BQV_NRTROL := ""
        BQV->BQV_SEQPTU := ""
        BQV->BQV_NRAOPE := ""
        BQV->BQV_REGSOL := BB0->BB0_NUMCR
        BQV->BQV_NOMSOL := BB0->BB0_NOME
        BQV->BQV_ATERNA := iif(oItem["beneficiary"]["newbornAttendance"]=="S","1","0")
        BQV->BQV_TIPDIA := "1"
        BQV->BQV_CANCEL := iif(oItem["authorizationStatus"] == "9", "1", "0")
        BQV->BQV_CHVNIV := oProced["authLevelKey"]
        BQV->BQV_NIVAUT := oProced["authLevel"]
        BQV->BQV_AUDITO := iif(oProced["status"] == 2, "1", "0")
        BQV->BQV_STATUS := iif(oProced["status"] == 1, "1", "0")
        BQV->(MsUnlock())

        //Processa as criticas
        nLenCri := iif(!empty(oItem["procedures"][nProced]["rejectionCauses"]), Len(oItem["procedures"][nProced]["rejectionCauses"]), 0)
        if nLenCri > 0
            self:grvCriBQZ(oItem,nProced,nLenCri)
        endIf

        //Gera historico importacao HAT - B2Z
        grvB2Z(self:cTrack, self:cFile, cOpeMov, oItem["healthProvider"]["healthProviderId"], oItem["treatmentExtensionNumber"], oItem["subscriberId"], dDatPro, oItem["password"], cSequen,;
            cCodTab, cCodPro, cValToChar(oItem["id"]),  "11", oProced["requestedQuantity"], oProced["requestedQuantity"] )

        if oProced["tableCode"] $ "90/98"
            self:grvPacB43(oItem,cSequen,cCodTab,cCodPro,dDatPro)
        endIf

    else
        logInf("[" + self:cTrack + "] BQV - evolucao de diaria ja existente - " + cGuia + cSequen, self:cFile)
    endIf

Return lRet

Method grvPacB43(oItem,cSequen,cCodTab,cCodPro,dDatPro) Class SyncTreatmentExtensions
    Local cCodRda      := ''
    Local nI           := 0
    Local aItensPac    := {}
    Local cAuthNumber  := oItem["treatmentExtensionNumber"]
    Local cCodOpe      := Substr(cAuthNumber,1,4)
    Local cAnoAut      := substr(cAuthNumber,5,4)
    Local cMesAut      := substr(cAuthNumber,9,2)
    Local cNumAut      := substr(cAuthNumber,11,8)
    local lRet         := .f.

    lRet := BAU->(msSeek(xFilial('BAU') + oItem["healthProviderId"]))

    if !lRet
        logInf("[" + self:cTrack + "] rede de atendimento nao existe - " + oItem["healthProviderId"], self:cFile)
    endIf

    if lRet

        cCodRda   := BAU->BAU_CODIGO
        aItensPac := PlRetPac(cCodOpe,cCodRDA,cCodTab,cCodPro,,dDatPro,.F.)

        if Len(aItensPac) > 0

            for nI := 1 To Len(aItensPac)

                if ! B43->(msSeek(xFilial("B43") + cCodOpe + cAnoAut + cMesAut + cNumAut + cSequen))

                    B43->(RecLock("B43",.T.))
                    B43->B43_FILIAL := xFilial("B43")
                    B43->B43_OPEMOV := cCodOpe
                    B43->B43_ANOAUT := cAnoAut
                    B43->B43_MESAUT := cMesAut
                    B43->B43_NUMAUT := cNumAut
                    B43->B43_SEQUEN := cSequen
                    B43->B43_CODPAD := aItensPac[nI,1]
                    B43->B43_CODPRO := aItensPac[nI,2]
                    B43->B43_DESPRO := Posicione('BR8',1,xFilial('BR8') + ALLTRIM(aItensPac[nI,1]) + ALLTRIM(aItensPac[nI,2]),'BR8_DESCRI')
                    B43->B43_VALCH  := aItensPac[nI,4]
                    B43->B43_VALFIX := aItensPac[nI,5]
                    B43->B43_PRINCI := aItensPac[nI,6]
                    B43->B43_TIPO   := aItensPac[nI,3]
                    B43->B43_ORIMOV := '6'
                    B43->B43_NIVPAC := aItensPac[nI,10]
                    B43->(MsUnlock())

                else
                    logInf("[" + self:cTrack + "] B43 - ja existe - " + cCodOpe + cAnoAut + cMesAut + cNumAut  + cSequen, self:cFile)
                endIf

            next nI

        endIf

    endIf

Return lRet

Method grvCriBQZ(oItem,nProced,nLenCri) Class SyncTreatmentExtensions
    Local nCritica := 1
    local oCritica := nil
    Local cGuia    := oItem["treatmentExtensionNumber"]
    Local cOpeMov  := Substr(cGuia,1,4)
    Local cAnoAut  := Substr(cGuia,5,4)
    Local cMesAut  := Substr(cGuia,9,2)
    Local cNumAut  := Substr(cGuia,11,8)
    Local cSequen  := oItem["procedures"][nProced]["sequence"]
    local lRet     := .T.

    while lRet .and. nCritica <= nLenCri

        oCritica := oItem["procedures"][nProced]["rejectionCauses"][nCritica]

        lRet := chkJsonTag(self:cTrack, oCritica, {"code"},,self:cFile)

        if lRet

            if BCT->(msSeek(xFilial('BCT') + cOpeMov + oCritica["code"]))

                if ! BQZ->(msSeek(xFilial('BQZ') + cOpeMov + cAnoAut + cMesAut + cNumAut + cSequen))

                    BQZ->(RecLock("BQZ",.T.))
                    BQZ->BQZ_FILIAL := xFilial("BQZ")
                    BQZ->BQZ_CODOPE := cOpeMov
                    BQZ->BQZ_ANOINT := cAnoAut
                    BQZ->BQZ_MESINT := cMesAut
                    BQZ->BQZ_NUMINT := cNumAut
                    BQZ->BQZ_SEQUEN := cSequen
                    BQZ->BQZ_CODGLO := oCritica["code"]
                    BQZ->BQZ_DESGLO := BCT->BCT_DESCRI
                    BQZ->BQZ_SEQCRI := strzero(nCritica, 3)
                    BQZ->BQZ_TIPO   := BCT->BCT_TIPO
                    BQZ->BQZ_CODEDI := BCT->BCT_CODED2
                    BQZ->(MsUnlock())

                else
                    logInf("[" + self:cTrack + "] BQZ - critica ja existe", self:cFile)
                endIf

            else
                logInf("[" + self:cTrack + "] BCT - critica nao existe - " + oCritica["code"], self:cFile)
            endIf

        endIf

        nCritica++

    endDo

    if nLenCri >= 1
        FreeObj(oCritica)
    endIf

return lRet

Method grvAuditoria(cNumGuia) Class SyncTreatmentExtensions
    Local o790C			:= nil
    Local aCabCri       := {}
    Local aDadCri		:= {}
    Local aVetCri       := {}
    Local aHeaderITE    := {}
    Local aColsITE      := {}
    Local aVetITE       := {}

    Inclui := .T.

    Store Header "BQV" TO aHeaderITE For .T.
    Store COLS "BQV" TO aColsITE FROM aHeaderITE VETTRAB aVetITE While;
        BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT) == xFilial("BQV")+cNumGuia

    Store Header "BQZ" TO aCabCri For .T.
    Store COLS "BQZ" TO aDadCri FROM aCabCri VETTRAB aVetCri While;
        BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT) == xFilial("BQZ")+cNumGuia

    o790C := PLSA790C():New(.T.)
    o790C:SetAuditoria(.T.,.F.,.F.,.F.,.F.,aDadCri,aCabCri,__aCdCri187[1],"0","BQZ",aColsITE,aHeaderITE,"BQV",.F., .T.,"6")
    o790C:Destroy()

Return
