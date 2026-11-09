#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CAR_APR 'pending_approved_operadora'
#DEFINE CAR_REJ 'pending_rejected_operadora'
#DEFINE CAR_AUD 'pending_audit_operadora'
#DEFINE NODEPAI 'mdmGoldenFieldAndValues'
#DEFINE HITS 'hits'
#DEFINE PAGESIZE '50'
#DEFINE TOTGUIAS 100
#DEFINE CRYPTKEY 'A6F985FT34' 

//-----------------------------------------------------------------
/*/{Protheus.doc} PLAudCarol
 Classe para comunicacao da Auditoria com a Carol
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PLAudCarol From PlsRest

    //Atributos de conexao
    Data cUser As String
    Data cPass As String
    Data cSubDomain As String
    Data cOrgSubDom As String
    Data cToken     As String
    Data cConnectID As String

    //Atributos para evento
    Data cCodPad    As String
	Data cCodPro    As String
    Data cCodGlo    As String
    Data cDesGlo    As String
    Data cObserva   As String
    Data cSeqPro    As String
    Data cParecer   As String
    Data cObsAna    As String
    Data cMotivo    As String
    Data cMotCriPad As String
    Data nQtdAut    As Integer
    Data nQtdSol    As Integer
    Data nDiaAut    As Integer
    Data nDiaSol    As Integer
    Data cDepartRet As String
    Data cDepartCar As String
    Data cUserSist  As String
    Data aJsonResp  As String
    Data lPCARAUD1  As Boolean
    Data lPCARAUD2  As Boolean
    Data oGuiAudit
    Data cGuiaSolo as String

    Method New(cCodOpe)
    Method loadAccess()
    Method startInteg(lAuto)
    Method getToken()
    Method getXAutKey()
    Method bscGuiPost()
    Method gerHeadPar(oGuias)
    Method audEvento()
    Method procRetCar()
    Method posRegist(oResponse,nX,cRequestID,cAlias)
    Method retParecer(cParecer)
    Method transfSet()
    Method qryGuiB53(cSetor)
    Method comTokNext(cTokenNext,nCont)
    Method cryptKey(cKey)
    Method decryptKey(cKey)
    Method setGuiaSolo(cGuiaSolo)

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method New(cCodOpe) Class PLAudCarol
    
    Default cCodOpe := ''

    _Super:new()
    self:cCodOpe := cCodOpe
    self:loadAccess()

    self:cCodPad   := ''
	self:cCodPro   := ''
    self:cCodGlo   := ''
    self:cDesGlo   := ''
    self:cObserva  := ''
    self:cSeqPro   := ''
    self:cParecer  := ''
    self:cObsAna   := ''
    self:cMotivo   := ''
    self:cMotCriPad:= GetNewPar('MV_PLCRCAR','')
    self:nQtdAut   := 0
    self:nQtdSol   := 0
    self:nDiaAut   := 0
    self:nDiaSol   := 0
    self:oGuiAudit := HMNew()
    self:aJsonResp := {}
    self:lPCARAUD1 := ExistBlock("PCARAUD1")
    self:lPCARAUD2 := ExistBlock("PCARAUD2")
    self:cGuiaSolo := ''

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} startInteg
 Inicia processo de atualizacao de guias
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method startInteg(lAuto) Class PLAudCarol

    Default lAuto := .F.

    self:impLog('',.F.)
    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando Integração Auditoria PLS x Carol',.F.)

    if lAuto .Or. !empty(BA0->BA0_CARTOK)
        self:bscGuiPost()
    else
        self:impLog('O campo de token BA0_CARTOK esta vazio, solicite ele atraves da rotina Operadora de Saude (PLSA010)')
    endIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} getToken
 Busca o token de acesso
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method getToken() Class PLAudCarol

    Local oResponse := nil
    Local cToken    := ''

    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando processo para solicitar Token')
    
    //Monta header
    self:setHeadPar('accept','application/json')
    self:setHeadPar('content-type','application/x-www-form-urlencoded')

    //Monta QryParam
    self:setQryPar('grant_type'  ,'password')
    self:setQryPar('connectorId' ,self:cConnectID)
    self:setQryPar('username'    ,self:cUser)
    self:setQryPar('password'    ,self:cPass)
    self:setQryPar('subdomain'   ,self:cSubDomain)
    self:setQryPar('orgSubdomain',self:cOrgSubDom)

    self:setPath('/oauth2/token')
    //Comunica com a Carol
    self:comunPost()

    if self:lSucess
        oResponse := JsonObject():New()
        oResponse:fromJSON(self:cRespJson)
        cToken := oResponse['access_token']
    endIf

Return {self:lSucess,cToken}


//-----------------------------------------------------------------
/*/{Protheus.doc} getXAutKey
 Busca o token mestre X-Auth-Key
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method getXAutKey(cToken) Class PLAudCarol

    Local cXAuthKey := ''

    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando processo para solicitar X-Auth-Key')

    //Monta header
    self:setHeadPar('accept','application/json')
    self:setHeadPar('Authorization',cToken)
    self:setHeadPar('content-type','application/x-www-form-urlencoded')

    //Monta QryParam
    self:setQryPar('connectorId' ,self:cConnectID)

    self:setPath('/apiKey/issue') 

    self:comunPost()

    if self:lSucess
        oResponse := JsonObject():New()
        oResponse:fromJSON(self:cRespJson)
        cXAuthKey := self:cryptKey(oResponse['X-Auth-Key'])
    endIf

Return {self:lSucess,cXAuthKey}


//-----------------------------------------------------------------
/*/{Protheus.doc} bscGuiPost
 Monta o json de solicitacao de guias
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method bscGuiPost() Class PLAudCarol

    Local nX     := 0
    Local oGuias := nil
    Local cSetor := GetNewPar('MV_SETORAT','')

    if Empty(cSetor)
        self:impLog("O parametro MV_SETORAT esta vazio, verifique o preenchimento do mesmo.")
    
    elseIf !Empty(self:cGuiaSolo) //Comunica somente uma guia especifica
        oGuias := JsonObject():new()
        oGuias['medicalformids'] := {}
        aAdd(oGuias['medicalformids'],JsonObject():new())
        oGuias['medicalformids'][1] := self:cGuiaSolo
        self:gerHeadPar(oGuias)
        oGuias := nil
        
    else

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,self:qryGuiB53(cSetor)),"TRBB53",.F.,.T.) 
        
        while !TRBB53->(Eof())
            
            nX++
            if nX == 1 //Primeiro registro, inicio o objeto Json
                oGuias := JsonObject():new()
                oGuias['medicalformids'] := {}
            endIf

            aAdd(oGuias['medicalformids'],JsonObject():new())
            oGuias['medicalformids'][nX] := TRBB53->B53_NUMGUI
            
            if nX >= TOTGUIAS //Alcancou o total de guias, comunico
                nX := 0
                self:gerHeadPar(oGuias)
                oGuias := nil
            endIf
            TRBB53->(DbSkip())

        endDo
        TRBB53->(DBCloseArea())
        
        if nX > 0 //Ha guias pendentes para comunicar
            self:gerHeadPar(oGuias)
        endIf

    endIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} gerHeadPar
 Monta os Query Params e Header para realizar a comunicacao Post de Guias
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method gerHeadPar(oGuias) Class PLAudCarol

    Local nX := 0
    Local oResponse  := JsonObject():New()
    Local aGuiAudit  := {}

    self:impLog(Replicate('-',50),.F.)
    self:impLog('*** Iniciando processo para comunicacao com a Carol ***')

    self:resetAtrib()
    self:loadAccess()
    self:setJson(FWJsonSerialize(oGuias, .F.,.F.))
    self:setHeadPar('accept'            ,'application/json')
    self:setHeadPar('X-Auth-Key'        ,self:cToken)
    self:setHeadPar('X-Auth-ConnectorId',self:cConnectID)
    self:setHeadPar('Content-Type'      ,'application/json')

    self:setQryPar('indexType' ,'MASTER')
    self:setQryPar('pageSize'  ,PAGESIZE)
    self:setQryPar('sortOrder' ,'ASC')
    self:setQryPar('scrollable','true')
    self:setQryPar('fields'    ,NODEPAI)

    self:setPath('/queries/named/getFormById')
    self:comunPost() //Realiza a comunicacao
    
    if self:lSucess

        //Trata comunicacao com a Carol e possives HasNext
        oResponse:fromJSON(self:cRespJson)
        if oResponse['count'] > 0
            aadd(self:aJsonResp,oResponse)
            if oResponse['totalHits'] > oResponse['count'] //Verifica se tem resposta pendente, devo comunicar novamente
                cTokenNext := oResponse['scrollId']
                self:comTokNext(cTokenNext,oResponse['count'])
            endIf
        else
            self:impLog('Não foram encontradas guias no Json de resposta.')
        endIf
        self:impLog('*** Finalizando processo para comunicacao com a Carol ***')        

        //Processa o resultado e atualiza as guias
        self:impLog(Replicate('-',50),.F.)
        self:impLog('*** Iniciando processo de atualizacao de guias ***')
        for nX := 1 to len(self:aJsonResp)
            self:procRetCar(self:aJsonResp[nX])
        next
        self:impLog('*** Finalizando processo de atualizacao de guias ***')

        //Realiza as transferencias
        aGuiAudit := {}
        HMList(self:oGuiAudit,aGuiAudit)
        if len(aGuiAudit) > 0
            self:impLog(Replicate('-',50),.F.)
            self:impLog('*** Iniciando transferencias entre departamentos ***')
            self:transfSet(aGuiAudit)
            self:impLog('*** Finalizando transferencias entre departamentos ***')
        endIf

    endIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} comTokNext
 Faz a comunicacao para solicitar o eventos subsequentes do HasNext
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method comTokNext(cTokenNext,nCont) Class PLAudCarol

    Local oResponse  := JsonObject():New()

    self:impLog(Replicate('-',50),.F.)
    self:impLog('Iniciando a solicitacao do HasNext. Token - '+cTokenNext,.F.)

    //Reinicia os objetos de trabalho
    self:resetAtrib()
    self:loadAccess()
      
    self:setHeadPar('accept'            ,'application/json')
    self:setHeadPar('X-Auth-Key'        ,self:cToken)
    self:setHeadPar('X-Auth-ConnectorId',self:cConnectID)
    self:setHeadPar('Content-Type'      ,'application/json')

    self:setQryPar('fields',NODEPAI)

    self:setPath('/queries/filter/'+cTokenNext)
    self:comunPost()

    if self:lSucess .And. oResponse['count'] > 0 
 	    oResponse:fromJSON(self:cRespJson)
        aadd(self:aJsonResp,oResponse)

        nCont += oResponse['count']
        if nCont < oResponse['totalHits']  //Verifica se tem resposta pendente, devo comunicar novamente
            cTokenNext := oResponse['scrollId']
            self:comTokNext(cTokenNext,nCont)
        endIf
    endIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} procRetCar
 Processa retorno da Carol
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method procRetCar(oResponse) Class PLAudCarol
    
	Local nX := 0
    Local cRequestID := ''
    Local cCodGui    := ''
    Local cCodPro    := ''
    
    //Posiciona nos indices que serao utilizados
    B53->(DbSetOrder(1)) //B53_FILIAL+B53_NUMGUI+B53_ORIMOV

    BEA->(DbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
    BE2->(DbSetOrder(1)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
    BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN

    BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
    BEJ->(DbSetOrder(1)) //BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
    BEL->(DbSetOrder(1)) //BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN

    B4Q->(DbSetOrder(1)) //B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT
    BQV->(DbSetOrder(1)) //BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
    BQZ->(DbSetOrder(1)) //BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN
    
    B4A->(DbSetOrder(1)) //B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT
    B4C->(DbSetOrder(1)) //B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN
    
    B71->(DbSetOrder(1)) //B71_FILIAL+B71_ALIMOV+B71_RECMOV+B71_SEQUEN
       
    for nX := 1 to len(oResponse[HITS])
        cRequestID := oResponse[HITS][nX][NODEPAI]['requestid']
        if B53->(DbSeek(xFilial('B53')+Substr(cRequestID,1,18)))
                            
            if B53->B53_SITUAC == '1' //Analisada? 0=Não;1=Sim;2=Em Analise;3=Em Espera;4=Inconsistência
                cCodGui := oResponse[HITS][nX][NODEPAI]['medicalformid']
                cCodPro := oResponse[HITS][nX][NODEPAI]['procedurecode']
                self:impLog(cRequestID+" - Nao foi possivel atualizar a guia, a mesma ja foi analisada anteriormente.")
                
            elseIf B53->B53_CODDEP <> self:cDepartCar
                self:impLog(cRequestID+" - Guia esta com a auditoria pendente, porem ja foi transferida para o departamento de retorno." )

            else
                self:posRegist(oResponse,nX,cRequestID,B53->B53_ALIMOV)
            endIf
            
        else
            self:impLog(cRequestID+" - Nao foi possivel encontrar a guia no Alias B53." )
        endIf
    next
  
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} posRegist
//  Posiciona nos registros que serao atualizados
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method posRegist(oResponse,nX,cRequestID,cAlias) Class PLAudCarol

    Local lFind      := .F.
    Local lJaAudit   := .F.
    Local lTransfere := .T.
    Local cGuia      := Substr(cRequestID,1,18)
    Local cAliasIte  := ''
    Local cCodPad    := ''
    Local cCodPro    := ''
    Local cSeqPro    := ''
    Local cCodGlo    := ''
    Local cAddMap    := ''
    Local aRetPE     := {}
    Local oVal       := nil

    Do Case

        Case cAlias == "BEA" //IMPORTANTE: futuramento criar condicao para Evolucao de SADT
            
            BEA->(DbSetOrder(1)) //BEA_FILIAL+BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT+BEA_DATPRO+BEA_HORPRO
            BE2->(DbSetOrder(1)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_SEQUEN
            BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
            if BEA->(DbSeek(xFilial('BEA')+cGuia)) .And. BE2->(DbSeek(xFilial('BE2')+cRequestID))
                lFind     := .T.
                cAliasIte := 'BE2'
                cCodPad   := BE2->BE2_CODPAD
                cCodPro   := BE2->BE2_CODPRO
                cSeqPro   := BE2->BE2_SEQUEN

                if BE2->BE2_AUDITO == "1"
                    if BEG->(DbSeek(xFilial('BEG')+cRequestID))
                        while BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == xFilial("BEG")+cRequestID .And. !BEG->(Eof())
                            if !empty(BEG->BEG_CODGLO)
                                cCodGlo := BEG->BEG_CODGLO
                                exit
                            endIf
                            BEG->(DbSkip())
                        endDo
                    endIf
                else
                    lJaAudit := .T.
                endIf
            endIf

        Case cAlias == "B4A"

            B4A->(DbSetOrder(1)) //B4A_FILIAL+B4A_OPEMOV+B4A_ANOAUT+B4A_MESAUT+B4A_NUMAUT
            B4C->(DbSetOrder(1)) //B4C_FILIAL+B4C_OPEMOV+B4C_ANOAUT+B4C_MESAUT+B4C_NUMAUT+B4C_SEQUEN
            BEG->(DbSetOrder(1)) //BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN
            if B4A->(DbSeek(xFilial('B4A')+cGuia)) .And. B4C->(DbSeek(xFilial("B4C")+cRequestID))
                lFind     := .T.
                cAliasIte := 'B4C'
                cCodPad   := B4C->B4C_CODPAD
                cCodPro   := B4C->B4C_CODPRO
                cSeqPro   := B4C->B4C_SEQUEN

                if B4C->B4C_AUDITO == "1"
                    if BEG->(DbSeek(xFilial('BEG')+cRequestID))
                        while BEG->(BEG_FILIAL+BEG_OPEMOV+BEG_ANOAUT+BEG_MESAUT+BEG_NUMAUT+BEG_SEQUEN) == xFilial("BEG")+cRequestID .And. !BEG->(Eof())
                            if !empty(BEG->BEG_CODGLO)
                                cCodGlo := BEG->BEG_CODGLO
                                exit
                            endIf
                            BEG->(DbSkip())
                        endDo
                    endIf
                else
                    lJaAudit := .T.
                endIf    
            endIf

        Case cAlias == "BE4"

            BE4->(DbSetOrder(2)) //BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
            BEJ->(DbSetOrder(1)) //BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT+BEJ_SEQUEN
            BEL->(DbSetOrder(1)) //BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN
            if BE4->(DbSeek(xFilial('BE4')+cGuia)) .And. BEJ->(DbSeek(xFilial("BEJ")+cRequestID))
                lFind     := .T.
                cAliasIte := 'BEJ'
                cCodPad   := BEJ->BEJ_CODPAD
                cCodPro   := BEJ->BEJ_CODPRO
                cSeqPro   := BEJ->BEJ_SEQUEN

                if BEJ->BEJ_AUDITO == "1"
                    if BEL->(DbSeek(xFilial('BEL')+cRequestID))
                        while BEL->(BEL_FILIAL+BEL_CODOPE+BEL_ANOINT+BEL_MESINT+BEL_NUMINT+BEL_SEQUEN) == xFilial("BEL")+cRequestID .And. !BEL->(Eof())
                            if !empty(BEL->BEL_CODGLO)
                                cCodGlo := BEL->BEL_CODGLO
                                exit
                            endIf
                            BEL->(DbSkip())
                        endDo
                    endIf
                else
                    lJaAudit := .T.
                endIf    
            endIf

        Case cAlias == "B4Q"

            B4Q->(DbSetOrder(1)) //B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT
            BQV->(DbSetOrder(1)) //BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT+BQV_SEQUEN
            BQZ->(DbSetOrder(1)) //BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN
            if B4Q->(DbSeek(xFilial('B4Q')+cGuia)) .And. BQV->(DbSeek(xFilial("BQV")+cRequestID))
                lFind     := .T.
                cAliasIte := 'BQV'
                cCodPad   := BQV->BQV_CODPAD
                cCodPro   := BQV->BQV_CODPRO
                cSeqPro   := BQV->BQV_SEQUEN

                if BQV->BQV_AUDITO == "1"
                    if BQZ->(DbSeek(xFilial('BQZ')+cRequestID))
                        while BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT+BQZ_SEQUEN) == xFilial("BQZ")+cRequestID .And. !BQZ->(Eof())
                            if !empty(BQZ->BQZ_CODGLO)
                                cCodGlo := BQZ->BQZ_CODGLO
                                exit
                            endIf
                            BQZ->(DbSkip())
                        endDo
                    endIf
                else
                    lJaAudit := .T.
                endIf    
            endIf

    EndCase
    
    cParecer := self:retParecer(oResponse[HITS][nX][NODEPAI]['statusprocedurerequest'])
    nQtdSol  := oResponse[HITS][nX][NODEPAI]['quantityrequested']
    nQtdAut  := oResponse[HITS][nX][NODEPAI]['quantityapproved']
    if cParecer == '0'
        cMotivo := ''
    else
        cMotivo := iif(ValType(oResponse[HITS][nX][NODEPAI]['tissDenyReason'])=='U',self:cMotCriPad,oResponse[HITS][nX][NODEPAI]['tissDenyReason'])
    endIf
    cObsAna  := iif(ValType(oResponse[HITS][nX][NODEPAI]['message'])=='U','',oResponse[HITS][nX][NODEPAI]['message'])

    //Manipula resultado recebido da Carol
    if self:lPCARAUD1 .Or. self:lAuto
        
        lTransfere := .T.
        aRetPE     := iif(self:lAuto ,;
                      {.T.,lFind,cCodPad,cCodPro,cSeqPro,cCodGlo,cParecer,nQtdSol,nQtdAut,cMotivo,cObsAna} ,;
                      ExecBlock('PCARAUD1',.F.,.F.,{cRequestID,lFind,cAlias,cAliasIte,cCodPad,cCodPro,cSeqPro,cCodGlo,cParecer,nQtdSol,nQtdAut,cMotivo,cObsAna}))

        if len(aRetPE) > 0 
            lTransfere := aRetPE[01]
            if lTransfere
                lFind    := aRetPE[02]
                cCodPad  := aRetPE[03]
                cCodPro  := aRetPE[04]
                cSeqPro  := aRetPE[05]
                cCodGlo  := aRetPE[06]
                cParecer := aRetPE[07]
                nQtdSol  := aRetPE[08]
                nQtdAut  := aRetPE[09]
                cMotivo  := aRetPE[10]
                cObsAna  := aRetPE[11]
            else 
                self:impLog(cRequestID+" - Evento gravado/tratado no PE PCARAUD1.")
            endIf
        endIf
    endIf

    if lTransfere
   
        //Evento ja analisado
        if lFind .And. lJaAudit
            self:impLog(cRequestID+" - Nao foi possivel atualizar o evento, o mesmo ja foi analisado anteriormente.")

        //Evento autorizado/negado
        elseIf lFind .And. cParecer $ '0/1'
            self:cCodPad  := cCodPad
            self:cCodPro  := cCodPro
            self:cSeqPro  := cSeqPro
            self:cCodGlo  := cCodGlo
            self:cParecer := cParecer
            self:nQtdSol  := nQtdSol
            self:nQtdAut  := nQtdAut
            self:cMotivo  := cMotivo
            self:cObsAna  := cObsAna

            self:audEvento()
            self:impLog(cRequestID+" - Evento "+iif(self:cParecer=="0","autorizado","negado")+" com sucesso.")

        //Encaminhando evento para Auditoria do PLS
        elseIf lFind .And. cParecer == '2'

            cAddMap := cAlias+cGuia
            if HMGet(self:oGuiAudit,cAddMap)
                oVal := nil
                if HMGet(self:oGuiAudit,cAddMap,oVal)
                    nQtdEventos := oVal+1
                    HMSet(self:oGuiAudit,cAddMap,nQtdEventos)
                endIf
            else
                HMSet(self:oGuiAudit,cAddMap, 1)
            endif
            self:impLog(cRequestID+" - Evento encaminhado para analise do auditor.")

        //Evento nao encontrado
        elseIf !lFind
            self:impLog(cRequestID+" - Nao foi possivel encontrar a guia/evento no Alias "+cAlias+".")
        endIf
    endIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} audEvento
 Audita um evento
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method audEvento() Class PLAudCarol

    Local oPADC := nil

	o790C := PLSA790C():New()
	oPADC := PLSPADRC():New("B72") 

	oModel  := FWLoadModel( 'PLCARAUB72' )
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	//Adiciona dados da B72
    oModel:SetValue("B72DETAIL","B72_FILIAL",xFilial("B72"))
	oModel:SetValue("B72DETAIL","B72_CODPAD",self:cCodPad)
	oModel:SetValue("B72DETAIL","B72_CODPRO",self:cCodPro)
    oModel:SetValue("B72DETAIL","B72_TPPARE","0")   //Verificar
    oModel:SetValue("B72DETAIL","B72_ALIMOV",B53->B53_ALIMOV)
    oModel:SetValue("B72DETAIL","B72_RECMOV",B53->B53_RECMOV)
    oModel:SetValue("B72DETAIL","B72_OPERAD",self:cUserSist)
    oModel:SetValue("B72DETAIL","B72_CODGLO",self:cCodGlo)
    oModel:SetValue("B72DETAIL","B72_OBSISA",self:cObserva) 
    oModel:SetValue("B72DETAIL","B72_SEQPRO",self:cSeqPro)
    oModel:SetValue("B72DETAIL","B72_PARECE",self:cParecer)
    oModel:SetValue("B72DETAIL","B72_DESGLO",self:cDesGlo)
    oModel:SetValue("B72DETAIL","B72_OBSANA",self:cObsAna)
    oModel:SetValue("B72DETAIL","B72_MOTIVO",self:cMotivo)
    oModel:SetValue("B72DETAIL","B72_VLRAUT","")
    //oModel:SetValue("B72DETAIL","B72_COPERE",cCopEre)
    //oModel:SetValue("B72DETAIL","B72_TPINCO",cTpInco)
    //oModel:SetValue("B72DETAIL","B72_RESAUT",cRespAudit)
    oModel:SetValue("B72DETAIL","B72_QTDAUT",self:nQtdAut)
    oModel:SetValue("B72DETAIL","B72_DIAAUT",self:nDiaAut)
    oModel:SetValue("B72DETAIL","B72_DIASOL",self:nDiaSol)
    oModel:SetValue("B72DETAIL","B72_QTDSOL",self:nQtdSol)
  
    //Commita o evento
    oPADC:MDPosVLD(oModel,"B72", "B72DETAIL")
	oPADC:MDCommit(oModel,"B72", "B72DETAIL",,.T.)

    o790C:destroy()
	oPADC:destroy()

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} transfSet
 Retorna o Parecer
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method transfSet(aGuiAudit) Class PLAudCarol

    Local nX         := 0
    Local nQtdAudit  := 0
    Local cAliCab    := ''
    Local cAliEve    := ''
    Local cSql       := ''
    Local cSequen    := ''
    Local cRecno     := ''
    Local cGuia      := ''
    Local cDepartRet := ''
    Local lTransfere := .F.
    Local aFieldsEve := {}
    
    for nX := 1 to len(aGuiAudit)
        cAliCab := Substr(aGuiAudit[nX,1],1,3)
        Do Case 
            Case cAliCab == 'BEA'
                cAliEve    := 'BE2'
                aFieldsEve := {'BE2_OPEMOV','BE2_ANOAUT','BE2_MESAUT','BE2_NUMAUT'}

            Case cAliCab == 'B4A'
                cAliEve    := 'B4C'
                aFieldsEve := {'B4C_OPEMOV','B4C_ANOAUT','B4C_MESAUT','B4C_NUMAUT'}

            Case cAliCab == 'BE4'
                cAliEve    := 'BEJ'
                aFieldsEve := {'BEJ_CODOPE','BEJ_ANOINT','BEJ_MESINT','BEJ_NUMINT'}

            Case cAliCab == 'B4Q'
                cAliEve    := 'BQV'
                aFieldsEve := {'BQV_CODOPE','BQV_ANOINT','BQV_MESINT','BQV_NUMINT'}
        
        EndCase
        
        cGuia := Substr(aGuiAudit[nX,1],4,18)

        if B53->(DbSeek(xFilial('B53')+cGuia)) .And. B53->B53_CODDEP == self:cDepartCar

            cSql := " SELECT COUNT("+cAliEve+"_AUDITO) QTDGUI FROM " + RetSqlName(cAliEve)
            cSql += " WHERE "+cAliEve+"_FILIAL = '"+xFilial(cAliEve)+"' "
            cSql += " AND "+aFieldsEve[1]+" = '"+Substr(aGuiAudit[nX,1],4,4)+"' "
            cSql += " AND "+aFieldsEve[2]+" = '"+Substr(aGuiAudit[nX,1],8,4)+"' "
            cSql += " AND "+aFieldsEve[3]+" = '"+Substr(aGuiAudit[nX,1],12,2)+"' "
            cSql += " AND "+aFieldsEve[4]+" = '"+Substr(aGuiAudit[nX,1],14,8)+"' "
            cSql += " AND "+cAliEve+"_AUDITO = '1' "
            cSql += " AND D_E_L_E_T_ = ' ' "

            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCab",.F.,.T.)
            nQtdAudit := iif(!TRBCab->(Eof()),TRBCab->QTDGUI,0)
            TRBCab->(DBCloseArea())
            
            cDepartRet := self:cDepartRet
            lTransfere := aGuiAudit[nX,2] >= nQtdAudit

            //PE permite manipular 
            if self:lPCARAUD2 .Or. self:lAuto
                aRetPE := iif(self:lAuto ,;
                            {lTransfere,cDepartRet} ,;
                            ExecBlock('PCARAUD2',.F.,.F.,{aGuiAudit[nX,1],cAliCab,cAliEve,lTransfere,cDepartRet,aGuiAudit[nX,2],nQtdAudit}) )

                if len(aRetPE) > 0 
                    lTransfere := aRetPE[1]
                    cDepartRet := aRetPE[2]
                endIf
            endIf

            if lTransfere

                if (cAliCab)->(DbSeek(xFilial(cAliCab)+cGuia))
             
                    /* Utilizei o processo de instanciar o PLSA790C para realizar a transferencia
                    pelo processo padrao da Auditoria, porem a mesma pode impactar em performance
                    Caso a mesma esteja prejudicada, e possivel realizar a transfencia com a 
                    funcao abaixo PLSICB71, porem o ajuste dos campos na B53 deve ser realizada 
                    posteriormente via Reclock

                    PLSICB71(cAliCab, cValToChar((cAliCab)->(Recno())), cSetor ) */

                    cRecno := cValtoChar((cAliCab)->(Recno()))

                    cSql := " SELECT MAX(B71_SEQUEN) AS MAIOR FROM "+RetSQLName("B71")
                    cSql += " WHERE B71_FILIAL = '"+xFilial("B71")+"' "
                    cSql += " AND B71_ALIMOV = '"+cAliCab+"' "
                    cSql += " AND B71_RECMOV = '"+cRecno+"' "
                    cSql += " AND D_E_L_E_T_ = ' ' "
                    
                    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbB71",.F.,.T.) 

                    cSequen := iif( !TrbB71->(Eof()) .AND. !Empty(TrbB71->MAIOR),Soma1(TrbB71->MAIOR),'001')                    
                    TrbB71->(DbCloseArea())

                    o790C := PLSA790C():New()
                    oPADC := PLSPADRC():New("B71") 
                    oPADC:lMDEncaminhamento := .T.
                    
                    oModel  := FWLoadModel( 'PLCARAUB71' )
                    oModel:SetOperation(MODEL_OPERATION_INSERT)
                    oModel:Activate()

                    oModel:SetValue("PLSENCAMMD","B71_FILIAL", xFilial( "B71") )
                    oModel:SetValue("PLSENCAMMD","B71_ALIMOV", cAliCab )
                    oModel:SetValue("PLSENCAMMD","B71_RECMOV", cRecno )
                    oModel:SetValue("PLSENCAMMD","B71_DATMOV", dDataBase )
                    oModel:SetValue("PLSENCAMMD","B71_OPERAD", self:cUserSist )
                    oModel:SetValue("PLSENCAMMD","B71_CODDEP", cDepartRet )
                    oModel:SetValue("PLSENCAMMD","B71_SEQUEN", cSequen )
                    oModel:SetValue("PLSENCAMMD","B71_OBS",'Transferencia realizada pela Auditoria da Carol')

                    oPADC:MDPosVLD(oModel,"B71",'PLSENCAMMD')
                    oPADC:MDCommit(oModel,"B71",'PLSENCAMMD')

                    o790C:destroy()
                    oPADC:destroy()
                    oModel:destroy()

                    self:impLog(cGuia+" - Guia transferida para o setor "+cDepartRet+" com sucesso." )

                else
                    self:impLog(cGuia+" - Nao foi possivel encontrar a guia no Alias " +cAliCab+"." )
                endIf
            else
                self:impLog(cGuia+" - Nao foi possivel realizar a transferencia pois ha eventos pendentes de analise da Carol.")
            endif
      
        elseIf B53->B53_CODDEP <> self:cDepartCar
            self:impLog(cGuia+" - Guia ja foi transferida para o departamento de retorno." )
        endIf

    next

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} retParecer
 Retorna o Parecer
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method retParecer(cParecer) Class PLAudCarol

    Local cRet := ''

    if cParecer == CAR_APR
        cRet := '0'
    elseIf cParecer == CAR_REJ
        cRet := '1'
    elseIf cParecer == CAR_AUD
        cRet := '2'
    endIf

Return cRet


//-----------------------------------------------------------------
/*/{Protheus.doc} qryGuiB53
 Retorna guias que serao consultadas na Carol
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method qryGuiB53(cSetor) Class PLAudCarol

    Local cSql := ''

    cSql += " SELECT B53_NUMGUI FROM " + RetSqlName("B53")
    cSql += " WHERE B53_FILIAL = '" + xFilial("B53") + "' "
    cSql += " AND B53_SITUAC IN ('0','2','3') " //0=Não;1=Sim;2=Em Analise;3=Em Espera;4=Inconsistência
    cSql += " AND B53_CODDEP = '"+cSetor+"' "
    cSql += " AND D_E_L_E_T_ = ' ' "

Return cSql


//-----------------------------------------------------------------
/*/{Protheus.doc} loadAccess
 Carrega dados de acesso
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method loadAccess() Class PLAudCarol

    BA0->(DbSetOrder(1)) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    if !Empty(self:cCodOpe) .And. BA0->(DbSeek(xFilial('BA0')+self:cCodOpe))   
        self:cSubDomain := Alltrim(BA0->BA0_CARDOM)
        self:cOrgSubDom := Alltrim(BA0->BA0_CARORG)
        self:cEndPoint  := Alltrim(BA0->BA0_CARURL)
        self:cConnectID := Alltrim(BA0->BA0_CARCID)
        self:cDepartRet := Alltrim(BA0->BA0_DEPRET)
        self:cUserSist  := Alltrim(BA0->BA0_CARSIS)
        self:cDepartCar := GetNewPar("MV_SETORAT","")
        self:lGeraLog   := GetNewPar("MV_PCARLOG","0") == "1"
        self:cToken     := self:decryptKey(Alltrim(BA0->BA0_CARTOK))
        self:cNameLog   := 'plaudcarol.log'
    endIf
 
Return


//-----------------------------------------------------------------
/*/{Protheus.doc} cryptKey
 Encripta uma chave usando o RC4Crypt
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method cryptKey(cKey) Class PLAudCarol
Return (rc4crypt( cKey ,CRYPTKEY, .T.))


//-----------------------------------------------------------------
/*/{Protheus.doc} decryptKey
 Decripta uma chave usando o RC4Crypt
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method decryptKey(cKey) Class PLAudCarol
    local cToken := ""

    if !empty(cKey)
        cToken := rc4crypt(cKey, CRYPTKEY, .F., .T.)
    endif

Return cToken

Method setGuiaSolo(cGuiaSolo) Class PLAudCarol
    self:cGuiaSolo := cGuiaSolo
Return
