#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "TBICONN.CH"

#define VIAWSDL "2"


STATIC aDadHeader := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLENVHAT
Faz o envio dos pedidos para o HAT

@author  Renan Sakai
@version P11
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLENVHAT()
    Local nX := 0
    Local aTransac := {_beneficiaryStatus_blo,;
        _preExistingDiseases_inc,;
        _persons_inc,;
        _healthProviderStatus_blo,;
        _attendanceLocations_inc,;
        _healthProviderSpecialties_inc,;
        _coverageProcedureLevel_BFG_inc,;
        _coverageProcedureLevel_BFD_inc,;
        _coverageGroupLevel_BFC_inc,;
        _coverageProcedureLevel_BT8_inc,;
        _coverageGroupLevel_BT7_inc,;
        _coverageProcedureLevel_BB2_inc,;
        _coverageGroupLevel_BRV_inc,;
        _billing_BCI_alt,;
        _clinicalStaff_BC1_inc,;
        _coverageGroupLevel_BG8_inc,;
        _cancel_BEA_atu}

    Local aRet       := {}
    Private aTabDup	 := PlsBusTerDup(SuperGetMv("MV_TISSCAB", .F. ,"87"))

    PHlogCabec('Iniciando processamento da integracao')
    aDadHeader := PLGDadHead()
    PLSLogHAT("authorization: " + aDadHeader[1,2] + CRLF + "idtenant: " + aDadHeader[2,2] + CRLF + "tenantName: " + aDadHeader[3,2])


    if PLHTACTRA(_beneficiaries_inc) .or. PLHTACTRA(_beneficiaries_alt)
        PHlogCabec('Iniciando envio das transacoes de beneficiarios')
        PLENVBenef() //Beneficiarios somente (alias BA1)
    endIf

    if PLHTACTRA(_healthProviders_inc) .or. PLHTACTRA(_healthProviders_alt)
        PHlogCabec('Iniciando envio das transacoes de prestadores')
        EnvPrest() //Prestadores somente (alias BAU)
    endIf

    PHlogCabec('Iniciando envio das transacoes genericas')

    BNN->(DbSetOrder(1)) //BNN_FILIAL+BNN_CODTRA
    for nX := 1 to len(aTransac)
        if PLHTACTRA(aTransac[nX])
            if BNN->(MsSeek(xFilial("BNN")+aTransac[nX])) .And. BNN->BNN_PRIORI <> "1"
                aRet := PLHATEndPo(aTransac[nX])
                PLHTPosGen( aRet[1]/*aCodTra*/,aRet[2]/*aFunBusDad*/,aRet[3]/*cNodePrinc*/,;
                    aRet[4]/*aNodeKey*/,aRet[5]/*lAglutina*/,aRet[6]/*cFuncCabec*/)
            endIf
        endIf
    next

    PHlogCabec('Iniciando busca do retorno dos itens pendentes')
    PLProcPend() //Busca o retorno dos tokens pendentes (status = 3)
    PHlogCabec('Integracao encerrada')

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLENVHATSC
Faz o envio dos pedidos para o HAT (chamada via Schedule)

@author  Renan Sakai
@version P12
@since    20.12.18
/*/
//-------------------------------------------------------------------
Function PLENVHATSC(aJob)

    Local cCodEmp  := aJob[1] //GetPvProfString(cJobName,"EMPRESA","",GetAdv97())//99
    Local cCodFil  := aJob[2] //GetPvProfString(cJobName,"FILIAL","",GetAdv97())//01
    Local lLog     := .F.
    Local lOk      := .F.
    Default aJob  := {}

    // Seta qual empresa e filial est? executando a JOB
    RpcSetEnv( cCodEmp, cCodFil , , ,'PLS', , )

    lLog := GetNewPar("MV_PHATLOG","0") == "1"

    // Trava para não executar o JOB se ja estiver em execucao
    lOk := LockByName('PLENVHATSC' + cCodEmp,.T.,.F.)
    If !lOk
        if lLog
            PHlogCabec('Job PLENVHATSC' + cCodEmp + ' - Já está em execução, aguarde o termino do processamento.')
        endIf
        Conout( 'Job PLENVHATSC' + cCodEmp + ' - Já está em execução, aguarde o termino do processamento.' ,, .F. )
        Return NIL
    EndIf

    PHlogCabec("Iniciando Job PLENVHATSC.")
    Conout("Iniciando Job PLENVHATSC." + CRLF + "Empresa: " + cCodEmp + CRLF + "Filial: " + cCodFil)

    //Processa rotina
    PLENVHAT()

    //Libera semaforo
    UnLockByName('PLENVHATSC' + cCodEmp)

    If len(aJob)>0
        While Len(aJob) > 0
            aDel(aJob,len(aJob))
            aSize(aJob, len(aJob)-1)
        EndDo
        aParam := nil
        PHlogCabec("Job PLENVHATSC Processado com Sucesso.")
        Conout("Job PLENVHATSC Processado com Sucesso.")
        RESET ENVIRONMENT
    Endif

Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATEndPo
Monta as chamadas para envio das transacoes genericas

Retorno:
    aCodTra - Transacoes atreladas ao mesmo endpoint
	cFuncao - Função que carrega os dados do endpoint em questão
	cNodePrin - Nome do node principal do json que será montado
	aNodeKey - Array com nodes que serão a chave primária da estrutura
	lAglutina - Indica se aglutina jsons com chaves primárias iguais

	aBuscaDad -> Indica configuracao para busca de dados do Alias correspondente
	aBuscaDad[1] - Indica se utiliza busca padrao
	aBuscaDad[2] - Alias da busca padrao
	aBuscaDad[3] - Indice da busca padrao
	aBuscaDad[4] - Funcao da busca personalizada

@author  Renan Sakai
@version P11
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATEndPo(cCodTra)
    Local aRet := {}
    Local aBuscaDad := {}

    Do Case

        Case cCodTra == _billing_BCI_alt //batchesAuthorization/integration - protocolo de faturamento
            aBuscaDad := {.T.,"BCI",1,'retDadBCI'}
            aRet := { {_billing_BCI_alt},aBuscaDad,'items',{'batchNumber','healthProviderId'},.T.,'reCabCover'}

        Case cCodTra == _persons_inc .Or. cCodTra == _persons_alt //persons
            aBuscaDad := {.T.,"BTS",1,nil}
            aRet := { {_persons_inc,_persons_alt},aBuscaDad,'items',{'subscriberId'},.T.,''}

        Case cCodTra == _preExistingDiseases_inc .Or. cCodTra == _preExistingDiseases_alt //preExistingDiseases
            aBuscaDad := {.F.,nil,nil,'retDadBF3'}
            aRet := { {_preExistingDiseases_inc,_preExistingDiseases_alt},aBuscaDad,'items',{'subscriberId','diseaseCode'},.T.,''}

        Case cCodTra == _beneficiaryStatus_blo .Or. cCodTra == _beneficiaryStatus_desblo //beneficiaryStatus
            aBuscaDad := {.F.,nil,nil,'retDadBCA'}
            aRet := { {_beneficiaryStatus_blo,_beneficiaryStatus_desblo},aBuscaDad,'items',{'subscriberId'},.F.,''}

        Case cCodTra == _healthProviderStatus_blo .Or. cCodTra == _healthProviderStatus_desblo //healthProviderStatus
            aBuscaDad := {.F.,nil,nil,'retDadBC4'}
            aRet := { {_healthProviderStatus_blo,_healthProviderStatus_desblo},aBuscaDad,'providers',{'healthProviderCode'},.F.,''}

        Case cCodTra == _attendanceLocations_inc .Or. cCodTra == _attendanceLocations_alt //attendanceLocations
            aBuscaDad := {.T.,"BB8",1,nil}
            aRet := { {_attendanceLocations_inc,_attendanceLocations_alt},aBuscaDad,'locations',{'healthProviderCode','locationCode','locationTypeCode'},.T.,''}

        Case cCodTra == _healthProviderSpecialties_inc .Or. cCodTra == _healthProviderSpecialties_alt //healthProviderSpecialties
            aBuscaDad := {.T.,"BAX",1,nil}
            aRet := { {_healthProviderSpecialties_inc,_healthProviderSpecialties_alt},aBuscaDad,'specialties',{'healthProviderCode','locationCode','specialtyCode'},.T.,''}

        Case cCodTra == _coverageProcedureLevel_BFG_inc .Or. cCodTra == _coverageProcedureLevel_BFG_alt //coverages/procedureLevel - benef
            aBuscaDad := {.T.,"BFG",1,nil}
            aRet := { {_coverageProcedureLevel_BFG_inc,_coverageProcedureLevel_BFG_alt},aBuscaDad,'items',{'companyId','subscriberId','beneficiaryRegistryType','procedureCode','procedureTableCode'},.T.,'reCabCover'}

        Case cCodTra == _coverageProcedureLevel_BFD_inc .Or. cCodTra == _coverageProcedureLevel_BFD_alt //coverages/procedureLevel - familia
            aBuscaDad := {.T.,"BFD",1,nil}
            aRet := { {_coverageProcedureLevel_BFD_inc,_coverageProcedureLevel_BFD_alt},aBuscaDad,'items',{'companyId','subscriberId','procedureCode','procedureTableCode'},.T.,'reCabCover'}

        Case cCodTra == _coverageProcedureLevel_BT8_inc .Or. cCodTra == _coverageProcedureLevel_BT8_alt //coverages/procedureLevel - empresa
            aBuscaDad := {.T.,"BT8",1,nil}
            aRet := { {_coverageProcedureLevel_BT8_inc,_coverageProcedureLevel_BT8_alt},aBuscaDad,'items',{'companyId','contractNumber','contractVersion', ;
                'subContractNumber','subContractVersion','healthProductCode','healthProductVersion','procedureTableCode','procedureCode'},.T.,'reCabCover'}

        Case cCodTra == _coverageProcedureLevel_BB2_inc .Or. cCodTra == _coverageProcedureLevel_BB2_alt //coverages/procedureLevel - produto
            aBuscaDad := {.T.,"BB2",1,nil}
            aRet := { {_coverageProcedureLevel_BB2_inc,_coverageProcedureLevel_BB2_alt},aBuscaDad,'items',{'healthProductCode','healthProductVersion','procedureTableCode','procedureCode'},.T.,'reCabCover'}

        Case cCodTra == _coverageGroupLevel_BFC_inc .Or. cCodTra == _coverageGroupLevel_BFC_alt //coverages/group - familia
            aBuscaDad := {.T.,"BFC",1,nil}
            aRet := { {_coverageGroupLevel_BFC_inc,_coverageGroupLevel_BFC_alt},aBuscaDad,'items',{'companyId','coverageGroupCode','subscriberId'},.T.,'reCabCover'}

        Case cCodTra == _coverageGroupLevel_BT7_inc .Or. cCodTra == _coverageGroupLevel_BT7_alt //coverages/group - empresa
            aBuscaDad := {.T.,"BT7",2,nil}
            aRet := { {_coverageGroupLevel_BT7_inc,_coverageGroupLevel_BT7_alt},aBuscaDad,'items',{'coverageGroupCode','companyId','contractNumber', ;
                'contractVersion','subcontractNumber','subcontractVersion','healthProductCode','healthProductVersion'},.T.,'reCabCover'}

        Case cCodTra == _coverageGroupLevel_BRV_inc .Or. cCodTra == _coverageGroupLevel_BRV_alt //coverages/group - produto
            aBuscaDad := {.T.,"BRV",1,nil}
            aRet := { {_coverageGroupLevel_BRV_inc,_coverageGroupLevel_BRV_alt},aBuscaDad,'items',{'healthProductCode','healthProductVersion'},.T.,'reCabCover'}

        Case cCodTra == _clinicalStaff_BC1_inc .Or. cCodTra == _clinicalStaff_BC1_alt //clinicalStaff - corpo clinico
            aBuscaDad := {.T.,"BC1",1,nil}
            aRet := { {_clinicalStaff_BC1_inc,_clinicalStaff_BC1_alt},aBuscaDad,'items',{'healthProviderCode'},.T.,''}

        Case cCodTra == _coverageGroupLevel_BG8_inc .Or. cCodTra == _coverageGroupLevel_BG8_alt //coverages/group - procedimentos grupo de cobertura
            aBuscaDad := {.T.,"BG8",1,nil}
            aRet := { {_coverageGroupLevel_BG8_inc,_coverageGroupLevel_BG8_alt},aBuscaDad,'items',{'procedureCode'},.T.,'reCabCover'}

        Case cCodTra == _cancel_BEA_atu
            aBuscaDad := {.T.,"BEA",1,nil}
            aRet := { {_cancel_BEA_atu},aBuscaDad,'guiasCancelamento',{'motivoCancelamento','idOnHealthInsurer'},.T.,''}
    EndCase

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTPosGen
Funcao generica para montagem do json de endpoints simples

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Function PLHTPosGen(aCodTra,aFunBusDad,cNodePrinc,aNodeKey,lAglutina,cFuncCabec,lEnvPedido)
    Local nX         := 0
    Local nTotItems  := 0
    Local nItem      := 1
    Local cSql       := ""
    Local cCodTra    := ""
    Local cAux       := ""
    Local aAux       := {}
    Local aAuxCab    := {}
    Local aRetItem   := {}
    Local aPedidos   := {}
    Local oObj       := nil
    Default lAglutina := .F.
    Default cFuncCabec := ""
    Default lEnvPedido := .T.

    lAglutina := .F.

    PLSLogHAT(Replicate("-",50),.F.)
    PLSLogHAT("Processando Transacao " + aCodTra[1],.F.)

    cSQL := " SELECT BNV_CHAVE, BNV_CAMPOS, BNV_ALIAS, BNV_CODIGO, BNV_IDINT, BNV_CODTRA, R_E_C_N_O_ as recno "
    cSQL += "  FROM " + retSQLName("BNV")
    cSQL += "  WHERE BNV_FILIAL = '" + xFilial("BNV") + "' "
    if len(aCodTra) > 1
        for nX:=1 to len(aCodTra)
            cCodTra += "'"+aCodTra[nX]+"'"
            Iif(nX<len(aCodTra),cCodTra+=",",cCodTra+="")
        next
        cSQL += "  AND BNV_CODTRA IN ("+cCodTra+") "
    else
        cSQL += "  AND BNV_CODTRA = '"+aCodTra[1]+"' "
    endIf
    cSQL += "  AND BNV_STATUS = '" + HAT_PENDENTE_ENVIO + "' "
    cSQL += "  AND BNV_PEDSUB = ' ' "
    cSQL += "  AND D_E_L_E_T_ = ' ' "
    cSQL += "  ORDER BY BNV_CHAVE, BNV_CAMPOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"BNVTRB",.T.,.F.)
    PLSLogHAT("Processando Transacao " + aCodTra[1] + ":" + cSQL,.F.)
    while !BNVTRB->(eof())

        PLSLogHAT("Item Alias " + BNVTRB->BNV_ALIAS + " pedido " + BNVTRB->BNV_CODIGO)
        //Cria novo objeto para cada pedido
        oObj := JsonObject():new()

        //Verifica se usa funcao padrao de busca de dados ou especifica
        if aFunBusDad[1]
            aAux := retDadPadr(Alltrim(BNVTRB->BNV_CHAVE),aFunBusDad[2],aFunBusDad[3])
        else
            aAux := &(aFunBusDad[4]+"('"+Alltrim(BNVTRB->BNV_CHAVE)+"')")
        endIf

        if !aAux[1] //Verifico se o registro posicionado existe no Alias correspondente
            errorCriPed(BNVTRB->BNV_ALIAS, BNVTRB->BNV_CODIGO)
            BNVTRB->(DbSkip())
            PLSLogHAT("Item Alias " + BNVTRB->BNV_ALIAS + " pedido " + BNVTRB->BNV_CODIGO + " erro ao" )
            loop
        else
            //Monta cabecalho do arquivo
            if !Empty(cFuncCabec)
                aAuxCab := &(cFuncCabec+"('"+Alltrim(BNVTRB->BNV_CHAVE)+"','"+Alltrim(BNVTRB->BNV_ALIAS)+"')")
                for nX := 1 to len(aAuxCab)
                    oObj[aAuxCab[nX][1]] := aAuxCab[nX][2]
                next
            else
                If BNVTRB->BNV_CODTRA<>'0053'
                    oObj['healthInsurerId'] := BA0->(BA0_CODIDE+BA0_CODINT)
                    oObj['ansRegistry'] := Alltrim(BA0->BA0_SUSEP)
                EndIf
            endIf

            oObj[cNodePrinc] := {}

            aAdd(oObj[cNodePrinc], JsonObject():new())

            aRetItem := aAux[2]
        endIf

        //Aqui adiciono as chaves primarias do JSON
        for nX := 1 to len(aNodeKey)
            cAux := retDadArr(aRetItem,aNodeKey[nX])
            if !Empty(cAux)
                oObj[cNodePrinc][nItem][aNodeKey[nX]] := cAux
            endIf
        next

        //Adiciona os valores dos campos
        for nX := 1 to len(aRetItem)
            if len(aRetItem[nX]) > 3
                if !Empty(aRetItem[nX][3]) .Or. aRetItem[nX][4] //Posicao 4 indica que pode gerar uma tag vazia
                    oObj[cNodePrinc][nItem][aRetItem[nX][1]]  := aRetItem[nX][3]
                endIf
            else
                if !Empty(aRetItem[nX][3])
                    oObj[cNodePrinc][nItem][aRetItem[nX][1]]  := aRetItem[nX][3]
                endIf
            endIf
        next

        Aadd(aPedidos, { BNVTRB->BNV_CODIGO, oObj, BNVTRB->BNV_CODTRA } )

        BNVTRB->(DbSkip())

        nTotItems := nTotItems + 1
    endDo

    PLSLogHAT("Total Itens Genericos encontrados, Transacao " + aCodTra[1] + " -> " +cValtoChar(nTotItems),.F.)

    BNVTRB->(DbCloseArea())

    //Realiza o envio dos pedidos localizados
    if len(aPedidos) > 0 .And. lEnvPedido
        sendIntegr(aPedidos)
    endif

Return aPedidos

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATCOMUN
Realiza a comunicacao com o HAT

Parametros cPostGet - P: Post
	 			      G: Get
@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATCOMUN(cEndPoint,cJson,cPostGet,cToken,cPedido,cActionGet,cExpand)

    Local oRestClient := NIL
    Local cResponse   := ""
    Local lSuccess    := .F.
    Local aHeader     := {}
    Local cErro       := ""
    Local nMaxTry 	  := GetNewPar("MV_PHATQTD",5)
    Local nTry        := 1
    Local lSendAgain  := .T.
    Local nX          := 0
    Local cRetCode  	:= ""
    Local oJson 		:= nil
    Default cEndPoint  := ""
    Default cJson      := ""
    Default cPostGet   := "P"
    Default cToken     := ""
    Default cActionGet := "/integration/"
    Default cActionDel := "/batchesAuthorization/"
    Default cExpand    := ""

    aAdd(aHeader,'Content-Type: application/json')

    for nX := 1 to len(aDadHeader)
        aAdd(aHeader,aDadHeader[nX,1]+": "+aDadHeader[nX,2])
    next

    while lSendAgain .and. nTry <= nMaxTry

        oRestClient := FWRest():New(cEndPoint)

        //Realiza o POST
        if cPostGet == "P"
            // o Path completo do endpoint já vai vir da operadora,
            // passo uma string em branco pois dentro do FWREST é feita a concatenação do host+path
            // se o path estiver NIL vai ocorrer error.log
            oRestClient:setPath("")
            oRestClient:SetPostParams(cJson)
            PLSLogHAT("INICIO DE COMUNICACAO COM O AUTORIZADOR POST - Codigo BNV: " + cPedido)
            PLSLogHAT("Json de envio: " + cJson)

            lSuccess := oRestClient:Post(aHeader) //Esta expressao retorna um boolean, aguardar ajuste do frame, pois hj o 202 esta sendo considerado erro
            //Realiza o GET
        elseIf cPostGet == "G"
            PLSLogHAT("INICIO DE COMUNICACAO COM O AUTORIZADOR GET - TOKEN: " + cToken)
            oRestClient:setPath(cActionGet+cToken+cExpand)
            PLSLogHAT("Buscando resposta no HAT do processamento do TOKEN[BNV_TOKEN]: " + cToken)
            lSuccess := oRestClient:Get(aHeader)
        elseif cPostGet == "D"
			oRestClient:setPath(cActionDel+cToken+cExpand)
			lSuccess := oRestClient:Delete(aHeader)    
        endIf

        //------------------------------------
        //Verifica o retorno da comunicacao
        //------------------------------------
        cRetCode := oRestClient:getHttpCode()
        lSuccess := lSuccess .OR. (cRetCode >= "200" .AND. cRetCode <= "299")
        if  lSuccess
            cResponse := oRestClient:GetResult()
            oJson := JsonObject():New()
            cParseError := oJson:fromJSON(cResponse)
            lSendAgain := .F.

            if Empty(cParseError)
                PLSLogHAT("COMUNICACAO OK - HAT devolveu a resposta: " + cResponse)
            else
                PLSLogHAT("COMUNICACAO OK - Erro ao processar resposta: " + cResponse + " - " + cParseError)
                cErro := "Erro no HAT: " + cResponse + " - " + cParseError
            endIf
        else
            if cRetCode == "404"
                lSendAgain := .F.
            else
                lSendAgain := .T.
            endIf
            cErro := "URI:" + oRestClient:cHost + ". Path:" + oRestClient:cPath + ". aHeader: " + ArrTokStr(aHeader, ",") + ". Fiz " + Alltrim(Str(nTry)) + " tentativas. Codigo de retorno: " + cRetCode + ". "
            PLSLogHAT("COMUNICACAO FALHOU - PEDIDO: " + cPedido + ". " + cErro)
            PLSLogHAT("COMUNICACAO FALHOU - PEDIDO: " + cPedido + ". " + oRestClient:getLastError())
        endIf

        nTry++
        sleep(500)
    enddo

Return {lSuccess,cResponse,iif(!lSuccess,cErro,""),iif(!lSuccess,cRetCode,"")}

//-------------------------------------------------------------------
/*/{Protheus.doc} retDadArr

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Static Function retDadArr(aDados,cTag)
    Local cRet := ""
    Local nPos := 0

    nPos := Ascan(aDados,{|x|x[1] == cTag})
    If nPos > 0
        cRet := aDados[nPos][3]
    EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSLogHAT
Monta o arquivo de log

@author  Renan Sakai
@version P12
@since    24.09.18
/*/
//-------------------------------------------------------------------
Function PLSLogHAT(cMsg, lDateTime, cLogFile)
    Local lLog := GetNewPar("MV_PHATLOG","0") == "1"

    Default cMsg := ""
    Default lDateTime := .T.
    Default cLogFile := "plshat.log"

    

    If lLog
        if lDateTime
            PlsPtuLog("[" + AllTrim(Str(ThreadID())) + "]["+Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + " - " + Time()+"] " + cMsg, cLogFile)
        else
            PlsPtuLog("[" + AllTrim(Str(ThreadID())) + "]" + cMsg, cLogFile)
        endIf
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} retHATURL
Retorna a URL do EndPoint a ser utilizado

@author  Renan Sakai
@version P12
@since    25.09.18
/*/
//-------------------------------------------------------------------
Function retHATURL(cCodTra,cGetPost)
	Local cUrl := GetNewPar("MV_PHATURL","")
	Default cCodTra  := ""
	Default cGetPost := "P"

	if Alltrim(cUrl) <> ""
		if Substr(cUrl,len(cUrl),1) <> "/"
			cUrl += "/"
		endIf

		if cGetPost == "D"
			cUrl += "v1"
		else

			BNN->(DbSetOrder(1))//BNN_FILIAL+BNN_CODTRA
			//Post verifico o EndPoint correspondente
			if cGetPost == "P" .And. BNN->(MsSeek(xFilial("BNN")+cCodTra )) .and. BNN->BNN_CODTRA == "0053"
				BEA->(DbSetOrder(1))
				BEA->(MsSeek(xFilial("BEA")+ALLTRIM(BNV->BNV_CHAVE)))
				cUrl += Alltrim(BNN->BNN_VERSAO)+"/"+Alltrim(BNN->BNN_ENDPOI)+"/"+ BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT)+"/"+"cancel"

			elseIf cGetPost == "P" .And. BNN->(MsSeek(xFilial("BNN")+cCodTra )) .and. !Empty(BNN->BNN_ENDPOI)
				cUrl += Alltrim(BNN->BNN_VERSAO)+"/"+Alltrim(BNN->BNN_ENDPOI)

				//Get verifico somente a versao (pesquiso pelo EndPoint 1)
			elseIf cGetPost == "G" .And. BNN->(MsSeek(xFilial("BNN")+cCodTra )) .and. !Empty(BNN->BNN_ENDPOI)
				cUrl += Alltrim(BNN->BNN_VERSAO)
			endIf
		endif
	endif
Return cUrl


//-------------------------------------------------------------------
/*/{Protheus.doc} gerPedSubs
Gera o pedido substituto

@author  Renan Sakai
@version P12
@since    25.09.18
/*/
//-------------------------------------------------------------------
Static Function gerPedSubs(cJson,aPedidos)
    Local cCodigoBNV := ""
    Local aCamposBNV := {}
    Local nX := 0

    if len(aPedidos) > 1
        cCodigoBNV := GetSXENum( "BNV","BNV_CODIGO" )
        //Gera o registro do Pedido Substituto
        aadd( aCamposBNV,{ "BNV_FILIAL", xFilial("BNV") })
        aadd( aCamposBNV,{ "BNV_CODIGO", cCodigoBNV })
        aadd( aCamposBNV,{ "BNV_STATUS", "0"})
        aadd( aCamposBNV,{ "BNV_JSON", cJson })
        aadd( aCamposBNV,{ "BNV_DATCRI", Date() })
        aadd( aCamposBNV,{ "BNV_HORCRI", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
        BNV->(ConfirmSX8())

        PLS274GRV( K_Incluir, aCamposBNV )

        //Indica nos pedidos alterados, o codigo do pedido subsituto
        BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
        for nX := 1 to len(aPedidos)
            if BNV->(MsSeek(xFilial("BNV")+aPedidos[nX]))
                aCamposBNV := {}
                aadd( aCamposBNV,{ "BNV_PEDSUB", cCodigoBNV })
                aadd( aCamposBNV,{ "BNV_STATUS", "9"})
                PLS274GRV( K_Alterar, aCamposBNV )
            endIf
        next
    elseIf len(aPedidos) == 1
        BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
        if BNV->(MsSeek(xFilial("BNV")+aPedidos[1]))
            cCodigoBNV := aPedidos[1]
            aadd( aCamposBNV,{ "BNV_JSON", cJson })
            PLS274GRV( K_Alterar, aCamposBNV )
        endIf
    endIf

Return cCodigoBNV

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATResp
Atualiza o pedido apos a comunicacao com o HAT

@author  Renan Sakai
@version P12
@since    25.09.18
/*/
//-------------------------------------------------------------------
Static Function PLHATResp(cPostGet,lSucesso,cPedido,cResponse,cErro)
    Local aCampos     := {}
    Local cToken      := ""
    Local oResponse   := NIL
    Local lFindBWB    := .F.
    Local cStatusCode := ""
    Local cDetails	  := ""
    Local nI 		  := 1
    Default cPostGet  := "P"
    Default cResponse := ""
    Default cErro     := ""

    if !Empty(cResponse)
        oResponse := JsonObject():New()
        oResponse:fromJSON(cResponse)
    endIf

    if cPostGet == "P"

        if lSucesso	.And. oResponse['serviceResponse']
            cToken := oResponse['tokenProcess']
            BWB->(DbSetOrder(1))//BWB_FILIAL+BWB_CODIGO
            //Se ja existia arquivo de erro, devo atualiza-lo com o sucesso
            if BWB->(MsSeek(xFilial("BWB")+cPedido))
                aadd( aCampos,{ "BWB_CODIGO", cPedido })
                aadd( aCampos,{ "BWB_RETORN", oResponse['detailedMessage'] })
                aadd( aCampos,{ "BWB_DATATU", Date() })
                aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
                PLS277GRV( K_Alterar, aCampos )
            endIf

        elseIf !lSucesso //Se deu um erro, gero registro de retorno
            BWB->(DbSetOrder(1))//BWB_FILIAL+BWB_CODIGO
            if BWB->(MsSeek(xFilial("BWB")+cPedido))
                lFindBWB := .T.
            endIf
            aadd( aCampos,{ "BWB_CODIGO", cPedido })
            aadd( aCampos,{ "BWB_RETORN", cErro   })
            aadd( aCampos,{ "BWB_DATATU", Date() })
            aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
            PLS277GRV( iif(lFindBWB,K_Alterar,K_Incluir), aCampos )
        endIf

        //Atualiza o pedido
        BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
        if BNV->(MsSeek(xFilial("BNV")+cPedido))
            aCampos := {}
            aadd( aCampos,{ "BNV_TOKEN", cToken })
            aadd( aCampos,{ "BNV_STATUS", iif(lSucesso,"3",IIF(BNV->BNV_CODTRA=="0053","5","2"))})
            PLS274GRV( K_Alterar, aCampos )
        endIf

    elseIf cPostGet == "G"
        //Consulta da transacao
        //Se for 404, ainda nao foi processado.
        if !lSucesso .Or. (lSucesso .And. oResponse['code'] == 404)
            BWB->(DbSetOrder(1))//BWB_FILIAL+BWB_CODIGO
            if BWB->(MsSeek(xFilial("BWB")+cPedido))
                lFindBWB := .T. //Se ja existe o registro de retorno, atualizarei
            endIf
            aadd( aCampos,{ "BWB_CODIGO", cPedido })

            if lSucesso //Quando a resposta e um 404, gravo o retorno do json
                aadd( aCampos,{ "BWB_CODRET", cValtoChar(oResponse['code']) })
                aadd( aCampos,{ "BWB_RETORN", oResponse['message'] })
            else //Em caso de erro, gravo o retorno do FwRest
                aadd( aCampos,{ "BWB_RETORN", cErro })
            endIf

            aadd( aCampos,{ "BWB_DATATU", Date() })
            aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
            PLS277GRV( iif(lFindBWB,K_Alterar,K_Incluir), aCampos )

            //-----------------------------------------------
            // Tratativa para token processado com sucesso
            //-----------------------------------------------
        else
            //Quando retornar algum dado no token, armazenar a mensagem
            //"0=Pend.Envio;1=Erro Cri.Pedido;2=Pend.Recomun;3=Pend.Process;4=Proc.Erro;5=Proc.Sucesso;9=Ped.Subst."
            Do Case
                case oResponse['code'] == 0 //'Aguardando finalizacao da validacao e processamento.'
                    cStatusCode := "3" //3=Pend.Process

                case oResponse['code'] == 1 //'Validacao OK. Aguardando processamento.'
                    cStatusCode := "3" //3=Pend.Process

                case oResponse['code'] == 2 //'Erros encontrados em alguns itens durante a validacao. Aguardando processamento dos demais itens.'
                    cStatusCode := "3" //3=Pend.Process

                case oResponse['code'] == 3 //'Erros encontrados na validacao de todos os itens. Verifique os dados enviados e tente novamente.'
                    cStatusCode := "4" //4=Proc.Erro

                case oResponse['code'] == 4 //'Processamento finalizado com sucesso.'
                    cStatusCode := "5" //5=Proc.Sucesso

                case oResponse['code'] == 5 //'Alguns erros foram encontrados durante o processamento.'
                    cStatusCode := "4" //4=Proc.Erro

                case oResponse['code'] == 6 //'Erros encontrados durante o processamento. Verifique os dados enviados e tente novamente.'
                    cStatusCode := "4" //4=Proc.Erro

            EndCase

            aCampos := {}
            cDetails := ""
            for nI := 1 to Len(oResponse['detailedMessage'])
                cDetails += oResponse['detailedMessage'][1]
            next nI

            //Atualiza tabela com detalhes da mensagem
            BWB->(DbSetOrder(1))//BWB_FILIAL+BWB_CODIGO
            lFindBWB := BWB->(MsSeek(xFilial("BWB")+cPedido))

            aadd( aCampos,{ "BWB_CODIGO", cPedido })
            aadd( aCampos,{ "BWB_CODRET", cValtoChar(oResponse['code']) })
            aadd( aCampos,{ "BWB_RETORN", cDetails })
            aadd( aCampos,{ "BWB_DATATU", Date() })
            aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
            PLS277GRV( iif(lFindBWB,K_Alterar,K_Incluir), aCampos )

            //Atualiza o pedido
            BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
            if BNV->(MsSeek(xFilial("BNV")+cPedido))
                aCampos := {}
                aadd( aCampos,{ "BNV_STATUS", cStatusCode })
                PLS274GRV( K_Alterar, aCampos )
            endIf

        endIf
    endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLProcPend
Verifica o status de protocolos com processamento pendente

@author  Renan Sakai
@version P12
@since    25.09.18
/*/
//-------------------------------------------------------------------
Static Function PLProcPend()
    Local cSQL      := ""
    Local cPedComun := ""
    Local nTotItems := 0
    local aActive   := PLHTRACT()
    local cActTran  := ""
    Local lSuccess 	:= ""
    Local cResponse := ""
    Local cErro 	:= ""

    PlArrToS(aActive, @cActTran, ",")

    cSQL := " SELECT BNV_CODIGO, BNV_TOKEN "
    cSQL += "  FROM " + retSQLName("BNV")
    cSQL += "  WHERE BNV_FILIAL = '" + xFilial("BNV") + "' "
    cSQL += "  AND BNV_STATUS = '" + HAT_PENDENTE_PROCESSAMENTO + "' "
    cSQL += "  AND BNV_CODTRA IN " + FormatIn(cActTran,',')
    cSQL += "  AND D_E_L_E_T_ = ' ' "
    cSQL += "  ORDER BY BNV_CODIGO "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"BNVTRB",.T.,.F.)
    PLSLogHAT("Query pendentes de processamento " + cSQL,.F.)
    while !BNVTRB->(eof())

        cPedComun := BNVTRB->BNV_CODIGO

        //Realiza a comunicacao com o HAT
        cURL := retHATURL("","G")

        //Se token vazio, provavelmente e um registro de Cancelamento de Guias que nao 
        //recebia token, assim, vamos concluir o registro para remover ele da fila
        if Empty(BNVTRB->BNV_TOKEN)
            cErro     := ''
            cResponse := '{'
            cResponse += '  "code": 4,'
            cResponse += '  "message": "Processamento finalizado com sucesso.",'
            cResponse += '  "detailedMessage": ["Alterando pedido para concluido pois estava sem token."]'
            cResponse += '}'
            PLHATResp("G",.T.,cPedComun,cResponse,cErro)
        else
            aAux := PLHATCOMUN(cUrl,"","G",Alltrim(BNVTRB->BNV_TOKEN),cPedComun)
            lSuccess := aAux[1]
            cResponse := aAux[2]
            cErro := aAux[3]
            //Atualiza o Pedido
            PLHATResp("G",lSuccess,cPedComun,cResponse,cErro)
        endIf
        BNVTRB->(DbSkip())

        nTotItems := nTotItems + 1
    endDo

    PLSLogHAT("Total protocolos pendentes encontrados -> " +cValtoChar(nTotItems),.F.)

    BNVTRB->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLReenvErr
Envio de pedidos processados com erro

@author  Renan Sakai
@version P12
@since    25.09.18
/*/
//-------------------------------------------------------------------
Static Function PLReenvErr()
    Local cSQL      := ""
    Local cPedComun := ""
    Local cCodTra   := ""

    cSQL := " SELECT BNV_CODIGO, BNV_CODTRA "
    cSQL += "  FROM " + retSQLName("BNV")
    cSQL += "  WHERE BNV_FILIAL = '" + xFilial("BNV") + "' "
    cSQL += "  AND BNV_STATUS = '" + HAT_ERRO_NO_PROCESSAMENTO + "' " //2
    cSQL += "  AND D_E_L_E_T_ = ' ' "
    cSQL += "  ORDER BY BNV_CODIGO "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"BNVTRB",.T.,.F.)
    PLSLogHAT("Query de pedidos processados com erro " + cSQL,.F.)
    BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
    while !BNVTRB->(eof())
        cCodTra   := ""
        cPedComun := BNVTRB->BNV_CODIGO
        if BNV->(MsSeek(xFilial("BNV")+BNVTRB->BNV_CODIGO))
            cJson := BNV->BNV_JSON

            if !Empty(BNVTRB->BNV_CODTRA)
                cCodTra := BNVTRB->BNV_CODTRA
            else //Pedido substituto, devo buscar um original para utilizar o CodTra
                BNV->(DbSetOrder(3))//BNV_FILIAL+BNV_PEDSUB
                if BNV->(MsSeek(xFilial("BNV")+BNVTRB->BNV_CODIGO))
                    cCodTra := BNV->BNV_CODTRA
                endIf
            endIf

            //Realiza a comunicacao com o HAT
            if !Empty(cCodTra)
                cURL := retHATURL(cCodTra,"P")
                aAux := PLHATCOMUN(cUrl,cJson,"P",nil,cPedComun)

                If cCodTra <> "0053"
                    //Atualiza o Pedido com Status e Token
                    PLHATResp("P",aAux[1],cPedComun,aAux[2],aAux[3])
                EndIf
            endIf

            BNVTRB->(DbSkip())
        endIf
    endDo

    BNVTRB->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLENVBenef
Faz o envio dos pedidos para o EndPoint de beneficiarios

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLENVBenef(lEnvPedido)
    Local nX := 0
    Local nY := 0
    Local nTotBFE := 0
    Local nTotItems := 0
    Local nBA1 := 1
    Local nBFE := 0
    Local cSql := ""
    Local cLastBenef := ""
    Local cMatCobert := ""
    Local aAux := {}
    Local aRetBA1 := {}
    Local aRetBFE := {}
    Local aPedidos := {}
    Local oObjBenef := nil
    Default lEnvPedido := .T.

    BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    BA0->(MsSeek(xFilial("BA0")+PlsIntPad()))

    //------------------------------------------------------------
    //            Envio de pedidos nao processados
    //------------------------------------------------------------
    cSQL := " SELECT BNV_CHAVE, BNV_CAMPOS, BNV_ALIAS, BNV_CODIGO, BNV_IDINT "
    cSQL += "  FROM " + retSQLName("BNV")
    cSQL += "  WHERE BNV_FILIAL = '" + xFilial("BNV") + "' "
    cSQL += "  AND BNV_CODTRA IN ('"+_beneficiaries_inc+"','"+_beneficiaries_alt+ "') "
    cSQL += "  AND BNV_STATUS = '" + HAT_PENDENTE_ENVIO + "' "
    cSQL += "  AND BNV_PEDSUB = ' ' "
    cSQL += "  AND D_E_L_E_T_ = ' ' "
    cSQL += "  ORDER BY BNV_CHAVE, BNV_CAMPOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"BNVTRB",.T.,.F.)
    PLSLogHAT("Buscando itens de Beneficiarios na BNV: " + cSQL)

    while !BNVTRB->(eof()) //sera enviado apenas 01 item em cada requisicao

        PLSLogHAT("Item Beneficiario Alias " + BNVTRB->BNV_ALIAS + " Pedido " + BNVTRB->BNV_CODIGO)
        //Inicia o objeto oObjBenef para capturar todos os dados
        oObjBenef := JsonObject():new()

        aAux := retBenef(Alltrim(BNVTRB->BNV_CHAVE),BNVTRB->BNV_ALIAS)

        if !aAux[1] //Verifico se o registro posicionado existe no Alias correspondente
            errorCriPed(BNVTRB->BNV_ALIAS, BNVTRB->BNV_CODIGO)
            BNVTRB->(DbSkip())
            loop
        else
            //Monta cabecalho do arquivo
            //if !lCabecJson
            // oObjBenef['healthInsurerId'] := BA0->(BA0_CODIDE+BA0_CODINT)
            // oObjBenef['ansRegistry'] := Alltrim(BA0->BA0_SUSEP)
            // oObjBenef['items'] := {}

            //	lCabecJson := .T.
            //endIf

            oObjBenef['healthInsurerId'] := BA0->(BA0_CODIDE+BA0_CODINT)
            oObjBenef['ansRegistry'] := Alltrim(BA0->BA0_SUSEP)
            oObjBenef['items'] := {}
            aAdd(oObjBenef['items'], JsonObject():new())

            aRetBA1 := aAux[2]
            aRetBFE := aAux[3]
        endIf

        //Reinicializa contadores de cobertura
        if cLastBenef <> retDadArr(aRetBA1,'subscriberId')
            nTotBFE := 0
        endIf

        // if (nBA1 := ascan(oObjBenef['items'],{|x|x['subscriberId'] == retDadArr(aRetBA1,'subscriberId')}) ) == 0
        // 	nTotBA1 += 1
        // 	nBA1 := nTotBA1
        // 	aAdd(oObjBenef['items'], JsonObject():new())
        // endIf

        //Aqui adiciono as chaves primarias do JSON
        oObjBenef['items'][nBA1]['subscriberId'] := retDadArr(aRetBA1,'subscriberId')

        ///------------------------------------------------------------
        // Alteracao/Inclusao de dados do beneficiario
        //------------------------------------------------------------
        if Alltrim(BNVTRB->BNV_ALIAS) == "BA1"
            //Se BNV_CAMPOS preenchido, informa somente os campos alterados
            if !Empty(BNVTRB->BNV_CAMPOS)
                aCamposAlt := StrTokArr(Alltrim(BNVTRB->BNV_CAMPOS),",")
                for nX := 1 to len(aCamposAlt)
                    if (nPos := aScan(aRetBA1,{|x|x[2] == aCamposAlt[nX]})) > 0 .And. !Empty(aRetBA1[nPos][3])
                        oObjBenef['items'][nBA1][aRetBA1[nPos][1]]  := aRetBA1[nPos][3]
                    endIf
                next nX

                //Campos BNV_CAMPOS vazio, sinaliza inclusao, envia todos os campos
            else
                //Dados do beneficiario
                for nX := 1 to len(aRetBA1)
                    if len(aRetBA1[nX]) > 3
                        if !Empty(aRetBA1[nX][3]) .Or. aRetBA1[nX][4]
                            oObjBenef['items'][nBA1][aRetBA1[nX][1]]  := aRetBA1[nX][3]
                        endIf
                    else
                        if !Empty(aRetBA1[nX][3])
                            oObjBenef['items'][nBA1][aRetBA1[nX][1]]  := aRetBA1[nX][3]
                        endIf
                    endIf
                next

                //Cobertura se houver
                if len(aRetBFE) > 0
                    oObjBenef['items'][nBA1]['coverageGroup'] := {}
                    cMatCobert := Substr(retDadArr(aRetBA1,'subscriberId'),1,16)
                    for nX := 1 to len(aRetBFE) //nX controla o Grupo de Cobertura
                        //Adiciona novo grupo
                        aAdd(oObjBenef['items'][nBA1]['coverageGroup'], JsonObject():new())

                        //Adiciona campos do grupo
                        for nY := 1 to len(aRetBFE[nX]) //nY controla os Campos do Grupo de Cobertura
                            if len(aRetBFE[nX][nY]) > 3
                                if !Empty(aRetBFE[nX][nY][3]) .or. aRetBFE[nX][nY][4]
                                    oObjBenef['items'][nBA1]['coverageGroup'][nX][aRetBFE[nX][nY][1]]  := aRetBFE[nX][nY][3]
                                endIf
                            else
                                if !Empty(aRetBFE[nX][nY][3])
                                    oObjBenef['items'][nBA1]['coverageGroup'][nX][aRetBFE[nX][nY][1]]  := aRetBFE[nX][nY][3]
                                endIf
                            endIf
                        next
                    next
                endIf
            endIf

            //------------------------------------------------------------
            // Alteracao/Inclusao de dados da Cobertura
            //------------------------------------------------------------
        elseIf Alltrim(BNVTRB->BNV_ALIAS) == "BFE" .And. len(aRetBFE) > 0

            aAux := aRetBFE[1]

            //Trativa para criar a estrutura do coverageGroup pela primeira vez        
            oObjBenef['items'][nBA1]['coverageGroup'] := {}
            cMatCobert := Substr(retDadArr(aRetBA1,'subscriberId'),1,16)
         
            if (nBFE := ascan(oObjBenef['items'][nBA1]['coverageGroup'],{|x|x['code'] == retDadArr(aAux,'code') }) ) == 0
                nBFE    := 1
                aAdd(oObjBenef['items'][nBA1]['coverageGroup'], JsonObject():new())
            endIf

            //Aqui adiciono as chaves primarias do JSON
            oObjBenef['items'][nBA1]['coverageGroup'][nBFE]['code'] := retDadArr(aAux,'code')
         
            //Dados do grupo de cobertura
            for nX := 1 to len(aAux)
                if len(aAux[nX]) > 3
                    if !Empty(aAux[nX][3]) .Or. aAux[nX][4]
                        oObjBenef['items'][nBA1]['coverageGroup'][nBFE][aAux[nX][1]] := aAux[nX][3]
                    endIf
                else
                    if !Empty(aAux[nX][3])
                        oObjBenef['items'][nBA1]['coverageGroup'][nBFE][aAux[nX][1]] := aAux[nX][3]
                    endIf
                endIf
            next
            
        endIf

        cLastBenef := retDadArr(aRetBA1,'subscriberId')

        Aadd(aPedidos, { BNVTRB->BNV_CODIGO, oObjBenef, _beneficiaries_inc})

        BNVTRB->(DbSkip())

        nTotItems := nTotItems + 1
    endDo

    BNVTRB->(DbCloseArea())

    PLSLogHAT("Total Beneficiarios encontrados -> " +cValtoChar(nTotItems),.F.)

    //Realiza o envio dos pedidos localizados
    if len(aPedidos) > 0 .And. lEnvPedido
        sendIntegr(aPedidos)
    endif

Return aPedidos



//-------------------------------------------------------------------
/*/{Protheus.doc} retBenef
Retorna array com dados do beneficiario

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Static Function retBenef(cChave,cAlias)
    Local lRet  := .F.
    Local aBA1  := {}
    Local aBFE  := {}
    Local aAux  := {}
    Local aMap  := {}
    Local nX    := 0

    BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
    BFE->(DbSetOrder(1))//BFE_FILIAL+BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG+BFE_CODGRU

    if BA1->(DbSeek(xFilial("BA1")+Substr(cChave,1,16)))

        aMap := PLHATMap("BA1")
        for nX := 1 to len(aMap)
            Aadd(aBA1,{aMap[nX][1],;
                aMap[nX][2],;
                &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")"),;
                aMap[nX][3]})
        next
        if !Empty(BA1->BA1_CODPLA)
            Aadd(aBA1,{'healthInsuranceCode',"BA1_CODPLA",BA1->BA1_CODPLA })
            Aadd(aBA1,{'healthInsuranceVersion',"BA1_VERSAO",BA1->BA1_VERSAO })
        else
            BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
            if BA3->(MsSeek(xFilial("BA3")+Substr(cChave,1,14)))
                Aadd(aBA1,{'healthInsuranceCode',"BA3_CODPLA",BA3->BA3_CODPLA })
                Aadd(aBA1,{'healthInsuranceVersion',"BA3_VERSAO",BA3->BA3_VERSAO })
            else
                Aadd(aBA1,{'healthInsuranceCode',"BA3_CODPLA","" })
                Aadd(aBA1,{'healthInsuranceVersion',"BA3_VERSAO","" })
            endIf
        endIf
        aBA1 := ajustType(aBA1)

        //Verifico se os registros existem
        if cAlias == "BA1"
            lRet := .T.
        endIf

        //Verifica os niveis de cobertura
        if cAlias == "BFE" //BFE pego somente a chave
            if BFE->(DbSeek(xFilial("BFE")+cChave))
                aAux := {}
                aMap := PLHATMap("BFE")
                for nX := 1 to len(aMap)
                    Aadd(aAux,{aMap[nX][1],;
                        aMap[nX][2],;
                        &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")"),;
                        aMap[nX,3]})
                next
                aAux := ajustType(aAux)
                Aadd(aBFE,aAux)

                lRet := .T.
            endIf

        elseIf cAlias == "BA1" //BA1 carrego todos os niveis de cobertura BFE
            if BFE->(DbSeek(xFilial("BFE")+Substr(cChave,1,16)))
                aMap := PLHATMap("BFE")
                while Substr(cChave,1,16) == BFE->(BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG) .And. !BFE->(Eof())
                    if !Empty(BFE->BFE_CODGRU) .And. !Empty(BFE->BFE_TIPREG)
                        aAux := {}
                        for nX := 1 to len(aMap)
                            Aadd(aAux,{aMap[nX][1],;
                                aMap[nX][2],;
                                &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")"),;
                                aMap[nX,3]})
                        next
                        aAux := ajustType(aAux)
                        Aadd(aBFE,aAux)
                    endIf
                    BFE->(dbSkip())
                endDo
            endIf
        endIf
    endIf

Return {lRet,aBA1,aBFE}


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadPadr
Funcao padrao para carregar dados de uma Alias

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Static Function retDadPadr(cChave,cAlias,nInd)
    Local lRet := .F.
    Local aMap := PLHATMap(cAlias)
    Local aRet := {}
    Local nX := 0

    (cAlias)->(DbSetOrder(nInd))
    if (cAlias)->(DbSeek(xFilial(cAlias)+cChave))
        for nX := 1 to len(aMap)
            Aadd(aRet,{aMap[nX,1],;
                aMap[nX,2],;
                &(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
                aMap[nX,3]})
        next

        lRet := .T.
    endIf
    aRet := ajustType(aRet)

Return {lRet,aRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadBCA
Retorna array com dados do bloqueio/desbloqueio de beneficiario

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Static Function retDadBCA(cChave)
    Local lRet := .F.
    Local aMap := PLHATMap("BCA")
    Local aRet := {}
    Local nX := 0

    BCA->(DbSetOrder(1))//BCA_FILIAL+BCA_MATRIC+BCA_TIPREG+BCA_DATA+BCA_TIPO
    if BCA->(DbSeek(xFilial('BCA')+cChave))

        for nX := 1 to len(aMap)

            Aadd(aRet,{aMap[nX,1],;
                aMap[nX,2],;
                &(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
                aMap[nX,3]})

            //De/para de informacao escrita para bloqueio/desbloqueio
            if aRet[nX][1] == "eventType"
                if aRet[nX][3] == "0"
                    aRet[nX][3] := "bloqueio"
                else
                    aRet[nX][3] := "desbloqueio"
                endif
            endif
        next

        lRet := .T.
    endIf
    aRet := ajustType(aRet)

Return {lRet,aRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadBF3
Retorna array com dados das doencas pre-existentes

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Static Function retDadBF3(cChave)
    Local cCodPad		:= ""
    Local cPadBkp		:= ""
    Local cCodPro		:= ""
    Local cCodProTerm	:= ""
    Local aCodPad		:= {}
    Local aCodPro		:= {}
    Local lRet			:= .F.
    Local aMap			:= PLHATMap("BF3")
    Local aRet			:= {}
    Local nX			:= 0

    BF3->(DbSetOrder(1))//BF3_FILIAL+BF3_MATVID
    if BF3->(DbSeek(xFilial('BF3')+cChave))

        for nX := 1 to len(aMap)
            if Alltrim(aMap[nX][2]) == "BF3_CODPAD"
                cCodPad := &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")")
                aCodPad := {aMap[nX][1],;
                    aMap[nX][2],;
                    "",;
                    aMap[nX][3]}

            elseIf Alltrim(aMap[nX][2]) == "BF3_CODPSA"
                cCodPro := &(Substr(aMap[nX][2],1,3)+"->("+aMap[nX][2]+")")
                aCodPro := {aMap[nX][1],;
                    aMap[nX][2],;
                    "",;
                    aMap[nX][3]}

            else
                Aadd(aRet,{aMap[nX,1],;
                    aMap[nX,2],;
                    &(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
                    aMap[nX,3]})
            endif
        next

        cPadBkp	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.F.))
        cCodProTerm	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  cCodPad + cCodPro, .F. ,aTabDup, @cPadBkp))
        cCodPro	:= iif(len(cCodProTerm) <> len(cCodPro), cCodPro, cCodProTerm)
        cCodPad := cPadBkp

        aCodPad[3] := cCodPad
        aCodPro[3] := cCodPro

        aAdd(aRet, aClone(aCodPad))
        aAdd(aRet, aClone(aCodPro))

        freeArr(@aCodPad)
        freeArr(@aCodPro)

        lRet := .T.
    endIf
    aRet := ajustType(aRet)

Return {lRet,aRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} retDadBCI
Retorna array com dados de lotes de faturamento

@author  Victor Silva
@version P12
@since    26.06.20
/*/
//-------------------------------------------------------------------
Static Function retDadBCI(cChave)
    Local lRet := .F.
    Local aMap := PLHATMap("BCI")
    Local cCodPegHat := ""
    Local aRet := {}
    Local nX := 0

    BCI->(DbSetOrder(1))//BCI_FILIAL+BCI_CODOPE+BCI_CODLDP+BCI_CODPEG+BCI_FASE+BCI_SITUAC
    if BCI->(DbSeek(xFilial('BCI') + cChave))

        for nX := 1 to len(aMap)

            if Alltrim(aMap[nX][2]) == "BCI_LOTGUI"
                BXX->( dbSetOrder(6) )//BXX_FILIAL+BXX_CODINT+BXX_CODPEG
                If BXX->( msSeek(xFilial("BXX") + BCI->BCI_CODOPE + BCI->BCI_CODPEG))
                    if (BXX->BXX_TPNFS == VIAWSDL)
                        cCodPegHat := BCI->BCI_LOTGUI
                    elseif !empty(BXX->BXX_PLSHAT)
                        cCodPegHat := BXX->BXX_PLSHAT
                    endif
                endif

                Aadd(aRet,{aMap[nX,1],;
                    aMap[nX,2],;
                    cCodPegHat,;
                    aMap[nX,3]})
            else
                Aadd(aRet,{aMap[nX,1],;
                    aMap[nX,2],;
                    &(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
                    aMap[nX,3]})
            endif

        next
        lRet := .T.

    endIf
    aRet := ajustType(aRet)

Return {lRet,aRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} EnvPrest
Faz o envio dos pedidos para o EndPoint de prestadores

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Static Function EnvPrest()
    Local nX         := 0
    Local nY         := 0
    Local nBAU       := 1
    Local nBC0       := 0
    Local nTotItems  := 0
    Local cSql       := ""
    Local cLastPrest := ""
    Local cPrestCov := ""
    Local aAux       := {}
    Local aRetBAU    := {}
    Local aRetBC0    := {}
    Local aPedidos   := {}
    Local oObjPrest  := nil

    BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    BA0->(MsSeek(xFilial("BA0")+PlsIntPad()))

    //------------------------------------------------------------
    //            Envio de pedidos nao processados
    //------------------------------------------------------------
    cSQL := " SELECT BNV_CHAVE, BNV_CAMPOS, BNV_ALIAS, BNV_CODIGO, BNV_IDINT "
    cSQL += "  FROM " + retSQLName("BNV")
    cSQL += "  WHERE BNV_FILIAL = '" + xFilial("BNV") + "' "
    cSQL += "  AND BNV_CODTRA IN ('"+_healthProviders_inc+"','"+_healthProviders_alt+ "') "
    cSQL += "  AND BNV_STATUS = '" + HAT_PENDENTE_ENVIO + "' "
    cSQL += "  AND BNV_PEDSUB = ' ' "
    cSQL += "  AND D_E_L_E_T_ = ' ' "
    cSQL += "  ORDER BY BNV_CHAVE, BNV_CAMPOS "

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,changeQuery(cSQL)),"BNVTRB",.T.,.F.)
    PLSLogHAT("Buscando itens de Prestadores na BNV: " + cSQL)
    while !BNVTRB->(eof())

        PLSLogHAT("Item Prestador Alias " + BNVTRB->BNV_ALIAS + " Pedido " + BNVTRB->BNV_CODIGO)

        //Inicia o objeto oObjPrest para capturar todos os dados
        oObjPrest := JsonObject():new()

        aAux := retPrestad(Alltrim(BNVTRB->BNV_CHAVE),BNVTRB->BNV_ALIAS,BNVTRB->BNV_IDINT)

        if !aAux[1] //Verifico se o registro posicionado existe no Alias correspondente
            errorCriPed(BNVTRB->BNV_ALIAS, BNVTRB->BNV_CODIGO)
            BNVTRB->(DbSkip())
            loop
        else
            oObjPrest['healthInsurerId'] := BA0->(BA0_CODIDE+BA0_CODINT)
            oObjPrest['ansRegistry'] := Alltrim(BA0->BA0_SUSEP)
            oObjPrest['providers'] := {}
            aAdd(oObjPrest['providers'], JsonObject():new())

            aRetBAU  := aAux[2]
            aRetBC0  := aAux[3]
        endIf

        //Aqui adiciono as chaves primarias do JSON
        oObjPrest['providers'][nBAU]['healthProviderCode'] := retDadArr(aRetBAU,'healthProviderCode')
        oObjPrest['providers'][nBAU]['healthProviderDocument'] := retDadArr(aRetBAU,'healthProviderDocument')

        ///------------------------------------------------------------
        // Alteracao/Inclusao de dados do prestador
        //------------------------------------------------------------
        if Alltrim(BNVTRB->BNV_ALIAS) == "BAU"

            //Dados do prestador - enviar todos os campos
            for nX := 1 to len(aRetBAU)
                if len(aRetBAU[nX]) > 3
                    if !Empty(aRetBAU[nX][3]) .Or. aRetBAU[nX][4]
                        oObjPrest['providers'][nBAU][aRetBAU[nX][1]]  := aRetBAU[nX][3]
                    endIf
                else
                    if !Empty(aRetBAU[nX][3])
                        oObjPrest['providers'][nBAU][aRetBAU[nX][1]]  := aRetBAU[nX][3]
                    endIf
                endIf
            next
            //procedimentos autorizados se houver
            if len(aRetBC0) > 0
                oObjPrest['providers'][nBAU]['procedureCoverage'] := {}
                cPrestCov := Substr(retDadArr(aRetBAU,'healthProviderCode'),1,6)
                for nX := 1 to len(aRetBC0) //nX controla o Grupo de procedimentos autorizados
                    //Adiciona novo grupo
                    aAdd(oObjPrest['providers'][nBAU]['procedureCoverage'], JsonObject():new())

                    //Adiciona campos do grupo
                    for nY := 1 to len(aRetBC0[nX]) //nY controla os Campos do Grupo de procedimentos autorizados
                        if len(aRetBC0[nX][nY]) > 4
                            if !Empty(aRetBC0[nX][nY][3]) .Or. aRetBC0[nX][nY][4]
                                oObjPrest['providers'][nBAU]['procedureCoverage'][nX][aRetBC0[nX][nY][1]]  := aRetBC0[nX][nY][3]
                            endIf
                        else
                            if !Empty(aRetBC0[nX][nY][3])
                                oObjPrest['providers'][nBAU]['procedureCoverage'][nX][aRetBC0[nX][nY][1]]  := aRetBC0[nX][nY][3]
                            endIf
                        endIf
                    next
                next
            endIf

            //------------------------------------------------------------
            // Alteracao/Inclusao de dados da procedimentos autorizados
            //------------------------------------------------------------
        elseIf Alltrim(BNVTRB->BNV_ALIAS) == "BC0" .And. len(aRetBC0) > 0

            oObjPrest['providers'][nBAU]['procedureCoverage'] := {}

            for nY := 1 to len(aRetBC0)

                aAux := aRetBC0[nY]

                //Verifica se a chave ja existe no JSON - caso exista, pega sempre o ultimo, pois e' o que tem os dados mais atualizados
                //Caso nao exista, adiciona um novo item no array
                nBC0 := ascan(oObjPrest['providers'][nBAU]['procedureCoverage'],{|x|x['procedureTableCode'] == retDadArr(aAux,'procedureTableCode') .And. ;
                    x['procedureCode'] == retDadArr(aAux,'procedureCode') .And. ;
                    x['initialTerm'] == retDadArr(aAux,'initialTerm') .And. ;
                    x['finalTerm'] == retDadArr(aAux,'finalTerm') })

                if nBC0	== 0
                    aAdd(oObjPrest['providers'][nBAU]['procedureCoverage'],JsonObject():new())
                    nBC0 := len(oObjPrest['providers'][nBAU]['procedureCoverage'])
                endIf

                //Aqui adiciono as chaves primarias do JSON
                oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0]['procedureTableCode'] := retDadArr(aAux,'procedureTableCode')
                oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0]['procedureCode'] := retDadArr(aAux,'procedureCode')

                for nX := 1 to len(aAux)
                    if len(aAux[nX]) > 3
                        if !Empty(aAux[nX][3]) .Or. aAux[nX][4]
                            oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0][aAux[nX][1]] := aAux[nX][3]
                        endIf
                    else
                        if !Empty(aAux[nX][3])
                            oObjPrest['providers'][nBAU]['procedureCoverage'][nBC0][aAux[nX][1]] := aAux[nX][3]
                        endIf
                    endIf
                next
            next
        endIf

        cLastPrest := retDadArr(aRetBAU,'healthProviderCode')

        Aadd(aPedidos, { BNVTRB->BNV_CODIGO, oObjPrest, _healthProviders_inc } )

        BNVTRB->(DbSkip())

        nTotItems := nTotItems + 1
    endDo

    BNVTRB->(DbCloseArea())

    PLSLogHAT("Total Prestadores encontrados -> " +cValtoChar(nTotItems),.F.)

    //Realiza o envio dos pedidos localizados
    if len(aPedidos) > 0
        sendIntegr(aPedidos)
    endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} retPrestad
Retorna array com dados dos Prestadores

@author  Renan Sakai
@version P12
@since    11.10.18
/*/
//-------------------------------------------------------------------
Static Function retPrestad(cChave,cAlias,nRecno)
    Local nX			:= 0
    Local lRet			:= .F.
    Local aRetBAU		:= {}
    Local aRetBC0		:= {}
    Local aAux			:= {}
    Local aCodPad		:= {}
    Local aCodPro		:= {}
    Local aMapBAU  		:= PLHATMap("BAU")
    Local aMapBC0  		:= PLHATMap("BC0")
    Local cCodPad  		:= ""
    Local cPadBkp  		:= ""
    Local cCodPro  		:= ""
    Local cCodProTerm	:= ""
    Default nRecno 		:= 0

    BAU->(DbSetOrder(1))//BTS_FILIAL+BTS_MATVID
    if BAU->(DbSeek(xFilial('BAU')+Substr(cChave,1,6)))

        for nX := 1 to len(aMapBAU)
            Aadd(aRetBAU,{aMapBAU[nX][1],;
                aMapBAU[nX][2],;
                &(Substr(aMapBAU[nX][2],1,3)+"->("+aMapBAU[nX][2]+")"),;
                aMapBAU[nX][3]})
        next

        lRet := .T.
    endIf

    //Se o Alias é BC0, carrego somente o registro correspondente
    if cAlias == "BC0"
        BC0->(DbSetOrder(1))//BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
        if BC0->(MsSeek(xFilial("BC0")+cChave))
            aAux := {}
            while Alltrim(BC0->(BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC)) == cChave .And. !BC0->(eof())

                //Itens com vigencia, devo considerar o Recno para posicionar no registro correto
                if nRecno == BC0->(Recno())

                    for nX := 1 to len(aMapBC0)

                        if Alltrim(aMapBC0[nX][2]) == "BC0_CODPAD"
                            cCodPad := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
                            aCodPad :=	{aMapBC0[nX][1],;
                                aMapBC0[nX][2],;
                                "",;
                                aMapBC0[nX,3]}

                        elseIf Alltrim(aMapBC0[nX][2]) == "BC0_CODOPC"
                            cCodPro := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
                            aCodPro := 	{aMapBC0[nX][1],;
                                aMapBC0[nX][2],;
                                "",;
                                aMapBC0[nX,3]}

                        else
                            Aadd(aAux,{aMapBC0[nX][1],;
                                aMapBC0[nX][2],;
                                &(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"),;
                                aMapBC0[nX,3]})
                        endif
                    next

                    cPadBkp	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.F.))
                    cCodProTerm	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  cCodPad + cCodPro, .F. ,aTabDup, @cPadBkp))
                    cCodPro	:= iif(len(cCodProTerm) <> len(cCodPro), cCodPro, cCodProTerm)
                    cCodPad := cPadBkp

                    aCodPad[3] := cCodPad
                    aCodPro[3] := cCodPro

                    aAdd(aAux, aClone(aCodPad))
                    aAdd(aAux, aClone(aCodPro))
                    Aadd(aRetBC0,aAux)

                    freeArr(@aCodPad)
                    freeArr(@aCodPro)

                    Exit
                endIf

                BC0->(DbSkip())
            endDo
        endIf

        //Se Alias é BAU, carrego todos os procedimentos
    elseIf cAlias == "BAU"
        BC0->(DbSetOrder(1))//BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
        if BC0->(MsSeek(xFilial("BC0")+Substr(cChave,1,6)))
            while BC0->BC0_CODIGO == Substr(cChave,1,6) .And. !BC0->(eof())
                aAux := {}

                for nX := 1 to len(aMapBC0)
                    if Alltrim(aMapBC0[nX][2]) == "BC0_CODPAD"
                        cCodPad := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
                        aCodPad :=	{aMapBC0[nX][1],;
                            aMapBC0[nX][2],;
                            "",;
                            aMapBC0[nX,3]}

                    elseIf Alltrim(aMapBC0[nX][2]) == "BC0_CODOPC"
                        cCodPro := allTrim(&(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"))
                        aCodPro := 	{aMapBC0[nX][1],;
                            aMapBC0[nX][2],;
                            "",;
                            aMapBC0[nX,3]}

                    else
                        Aadd(aAux,{aMapBC0[nX][1],;
                            aMapBC0[nX][2],;
                            &(Substr(aMapBC0[nX][2],1,3)+"->("+aMapBC0[nX][2]+")"),;
                            aMapBC0[nX][3]})
                    endif
                next

                cPadBkp	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  cCodPad,.F.))
                cCodProTerm	:= allTrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodPad,  cCodPad + cCodPro, .F. ,aTabDup, @cPadBkp))
                cCodPro	:= iif(len(cCodProTerm) <> len(cCodPro), cCodPro, cCodProTerm)
                cCodPad := cPadBkp

                aCodPad[3] := cCodPad
                aCodPro[3] := cCodPro

                aAdd(aAux, aClone(aCodPad))
                aAdd(aAux, aClone(aCodPro))
                Aadd(aRetBC0,aAux)

                freeArr(@aCodPad)
                freeArr(@aCodPro)

                Aadd(aRetBC0,aAux)
                BC0->(DbSkip())
            endDo
        endIf
    endIf

    aRetBAU := ajustType(aRetBAU)
    for nX := 1 to len(aRetBC0)
        aRetBC0[nX] := ajustType(aRetBC0[nX])
    next

Return {lRet,aRetBAU,aRetBC0}



//-------------------------------------------------------------------
/*/{Protheus.doc} retDadBC4
Retorna array com dados do bloqueio/desbloqueio de prestadores

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Static Function retDadBC4(cChave)
    Local lRet := .F.
    Local aRet := {}
    Local aMap := PLHATMap("BC4")
    Local nX   := 0

    BC4->(DbSetOrder(2))//BC4_FILIAL+BC4_CODCRE+BC4_TIPO+BC4_DATA+BC4_HORA
    BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
    if BC4->(MsSeek(xFilial('BC4')+cChave)) .And. BAU->(MsSeek(xFilial("BAU")+BC4->BC4_CODCRE))

        for nX := 1 to len(aMap)
            Aadd(aRet,{aMap[nX,1],;
                aMap[nX,2],;
                &(Substr(aMap[nX,2],1,3)+"->("+aMap[nX,2]+")"),;
                aMap[nX,3]})

            //De/para de informacao escrita para bloqueio/desbloqueio
            if aRet[nX][1] == "eventType"
                if aRet[nX][3] == "0"
                    aRet[nX][3] := "bloqueio"
                else
                    aRet[nX][3] := "desbloqueio"
                endif
            endif
        next

        lRet := .T.
    endIf
    aRet := ajustType(aRet)

Return {lRet,aRet}


//-------------------------------------------------------------------
/*/{Protheus.doc} reCabCover
Retorna array com dados do cabecalho para a API coverages/level

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Static Function reCabCover(cChave,cAlias)
    Local aRet := {}

    BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    if BA0->(MsSeek(xFilial("BA0")+PlsIntPad()))
        Aadd(aRet,{'healthInsurerId',BA0->(BA0_CODIDE+BA0_CODINT)})
        Aadd(aRet,{'ansRegistry',Alltrim(BA0->BA0_SUSEP)})
        Do Case
            Case cAlias == 'BFD' //familia
                Aadd(aRet,{'coverageProcedureLevel','familia'})

            Case cAlias == 'BFG' //beneficiario
                Aadd(aRet,{'coverageProcedureLevel','beneficiario'})

            Case cAlias == 'BT8' //empresa
                Aadd(aRet,{'coverageProcedureLevel','empresa'})

            Case cAlias == 'BB2' //produto
                Aadd(aRet,{'coverageProcedureLevel','produto'})

            Case cAlias == 'BFC' //Familia
                Aadd(aRet,{'coverageGroupLevel','familia'})

            Case cAlias == 'BT7' //Empresa
                Aadd(aRet,{'coverageGroupLevel','empresa'})

            Case cAlias == 'BRV' //Produto
                Aadd(aRet,{'coverageGroupLevel','produto'})

            Case cAlias == 'BG8' //Eventos Grupo de Cobertura
                BG8->(DbSetOrder(1)) //BG8_FILIAL+BG8_CODINT+BG8_CODGRU+BG8_CODPAD+BG8_CODPSA+BG8_NIVEL
                if BG8->(MsSeek(xFilial("BG8")+cChave))
                    BG7->(DbSetOrder(1)) //BG7_FILIAL+BG7_CODINT+BG7_CODGRU
                    if BG7->(MsSeek(xFilial("BG7")+BG8->(BG8_CODINT+BG8_CODGRU)))
                        Aadd(aRet,{'coverageGroupCode',Alltrim(BG7->BG7_CODGRU)})
                        Aadd(aRet,{'coverageGroupName',Alltrim(BG7->BG7_DESCRI)})
                    endIf
                endIf

        EndCase

    endIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ajustType
Realiza ajuste nos dados baseado no tipo da variavel

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Static Function ajustType(aRet)
    Local nX := 1

    for nX := 1 to len(aRet)
        if ValType(aRet[nX][3]) == "C"
            aRet[nX][3] := Alltrim(aRet[nX][3])
        elseif ValType(aRet[nX][3]) == "D"
            if empty(DtoS(aRet[nX][3]))
                aRet[nX][3] := ""
            else
                aRet[nX][3] := SubStr(DtoS(aRet[nX][3]),1,4) + '-' + SubStr(DtoS(aRet[nX][3]),5,2) + '-' + SubStr(DtoS(aRet[nX][3]),7,2)
            endif
        endif
    next

Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} sendIntegr
Funcao centralizada para enviar pedido de integracao
@author  Rodrigo.Morgon
@since   2018-12-04
/*/
//-------------------------------------------------------------------
Static Function sendIntegr(aPedidos)

    local nPedidos := 1
    local cJson := ''
    local aCamposBNV := {}
    local aAux := {}
    local cUrl := ''

    // No array aPedidos:
    // [x][1] codigo bnv
    // [x][2] json msg
    // [x][3] tipo transacao (para recuperar a url)
    Default aPedidos := {}

    //Percorre os pedidos encontrados
    for nPedidos := 1 to len(aPedidos)
        //Gera o Json para envio
        cJson := FWJsonSerialize(aPedidos[nPedidos][2], .F., .F.)

        if cJson <> "{}"
            BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
            if BNV->(MsSeek(xFilial("BNV")+aPedidos[nPedidos][1]))
                aadd(aCamposBNV,{"BNV_JSON",cJson}) //Atualiza o json de envio na BNV
                PLS274GRV( K_Alterar, aCamposBNV )
            endIf

            //Realiza a comunicacao com o HAT
            cURL := retHATURL(aPedidos[nPedidos][3], "P")
            aAux := PLHATCOMUN(cUrl,cJson,"P",nil,aPedidos[nPedidos][1])
            If aPedidos[nPedidos][3] <> "0053"
                //Atualiza o Pedido com Status e Token
                PLHATResp("P",aAux[1],aPedidos[nPedidos][1],aAux[2],aAux[3])
            EndIf
        endIf

        sleep(1000) //Tempo de intervalo para envio entre os pedidos - garantir que a requisicao seja atendida
    next nPedidos
return


//-------------------------------------------------------------------
/*/{Protheus.doc} errorCriPed
Funcao para atribuir status de erro na criacao do pedido (status 1)
@author  Rodrigo.Morgon
@since   2019-01-09
/*/
//-------------------------------------------------------------------
Static Function errorCriPed(cAlias, cCodigo)

    local aCampos := {}

    default cAlias := ''
    default cCodigo := ''

    if !empty(cAlias) .and. !empty(cCodigo)

        Conout("Dados nao encontrados - alias: " + cAlias + " - pedido " + cCodigo)

        //Atualiza o pedido com status 1 - erro na criacao do pedido
        BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
        if BNV->(MsSeek(xFilial("BNV")+cCodigo))
            aCampos := {}
            aadd( aCampos, { "BNV_STATUS", "1" })
            PLS274GRV( K_Alterar, aCampos )
        endIf
    endif
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLGDadHead
Busca dados do header da transacao configurados nos parametros

@author  Renan Sakai
@version P12
@since   19.06.19
/*/
//-------------------------------------------------------------------
Function PLGDadHead()

    local aRet := {}
    local lRet := .t.
    local nX := 0

    // Pega as chaves de configuracao do HAT
    Aadd(aRet,{"authorization",GetNewPar("MV_PHATTOK","0c0012bbee40400082DEcb1a7f726c41" )})
    Aadd(aRet,{"idTenant"     ,GetNewPar("MV_PHATIDT","5" )})
    Aadd(aRet,{"tenantName"   ,GetNewPar("MV_PHATNMT","suporte" )})

    for nX := 1 to len(aRet)

        if empty(aRet[nX,2])
            lRet := .f.
            exit
        endIf

    next

    if ! lRet
        UserException("Nao foi possivel realizar a comunicacao com o HAT, dados do cabeaalho da requisicao estao incorretos.")
    endIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PHlogCabec
Monta o cabecalho padrao do log HAT

@author  Renan Sakai
@version P12
@since   24.06.19
/*/
//-------------------------------------------------------------------
Static Function PHlogCabec(cMsg)
    Local lLog := GetNewPar("MV_PHATLOG","0") == "1"
    Default cMsg := ""

    If lLog
        PLSLogHAT(Replicate("*",50),.F.)
        PLSLogHAT(cMsg)
        PLSLogHAT(Replicate("*",50),.F.)
    EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} P790PdfDow
Realiza a comunicacao com o endpoint de download de arquivos anexos

@author  Renan Sakai
@version P12
@since    06.11.18
/*/
//-------------------------------------------------------------------
Function P790PdfDow(cGuia,cAtion)

    Local nX := 0
    Local lHeader    := .T.
    Local cEndPoint  := retHATURL("","G")

    Local aRetCom    := {}
    Local aFiles     := {}
    Local lEnd       := .T.
    Default cAtion   := 'v1/authorizations'
    
    //Verifica dados do header configurados nos parametros
    aDadHeader := PLGDadHead()

    if len(aDadHeader) == 0
        lHeader := .F.
    else
        for nX := 1 to len(aDadHeader)
            if Empty(aDadHeader[nX,2])
                lHeader := .F.
                exit
            endIf
        next
    endIf

    if lHeader

        processa( { | lEnd | aRetCom := PLHATCOMUN(cEndPoint,nil,"G",cGuia,cGuia,"/"+cAtion+"/","?expand=attachments&fields=attachments") }, "Aguarde...","Baixando Arquivos...",lEnd )

        if aRetCom[1] .and. !Empty(aRetCom[2])

            oResponse := JsonObject():New()
            oResponse:fromJSON(aRetCom[2])

            if ValType(oResponse['attachments']) == 'J' .And. ValType(oResponse['attachments']['files']) == "A" .And. ;
                    (nLen := len(oResponse['attachments']['files'])) > 0

                for nX := 1 to nLen
                    aaDD(aFiles,{oResponse['attachments']['path'] + oResponse['attachments']['files'][nX] + oResponse['attachments']['sasToken'],;
                        oResponse['attachments']['files'][nX]})
                next
            else
                Aviso( "Atenção","Não foram encontrados arquivos para realizar o download.",{ "Ok" }, 2 )
            endIf

            //Nao foi possivel comunicar
        elseIf !aRetCom[1]
            if aRetCom[4] == '404'
                Aviso( "Atenção","Não foram encontrados arquivos no Portal Autorizador para realizar o download.",{ "Ok" }, 2 )
            else
                Aviso( "Atenção","Não foi possível realizar a comunicacao, erro: "+ aRetCom[3],{ "Ok" }, 2 )
            endif
        endIf

    else
        Aviso( "Atenção","Não foi possível realizar a comunicacao, o arquivo 'plshat.ini' não está configurado corretamente.",{ "Ok" }, 2 )
    endIf

Return aFiles

static function freeArr(aArray)
    aSize(aArray,0)
    aArray := Nil
    aArray := {}
return
