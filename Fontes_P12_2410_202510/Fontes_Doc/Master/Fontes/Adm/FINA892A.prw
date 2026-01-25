#Include "PROTHEUS.CH"
#Include "FwMVCDEF.CH"
#Include "FINA892.CH"

Static __lCFGPIX    As Logical
Static __lHttpsQu   As Logical

/*/{Protheus.doc} FINA892A
	Função responsável por realizar a baixa dos titulos transmitido pelo PIX

	@author     Rafael Riego
	@since      18/01/2021
	@version    12.1.27
	@return     Nil
/*/
Function FINA892A()
    Local lProcessa  As Logical
    Local lExistFunc As Logical
    Local cFunName   As Char   
    Local cTblReceb  As Char
    Local cDtaVenc   As Char    
    Local cBancoOfi  As Char
    Local cParams    As Char
    Local cDtHrFim   As Char
    Local cDataIni   As Char
    Local cDataFim   As Char   
    Local cDataDe    As Char
    Local cAnoMes    As Char
    Local cAnoMesIni As Char 
    Local cAnoMesFim As Char    
    Local cResult    As Char
    Local cCertifica As Char
    Local cCertiKey  As Char
    Local cHttpsQuot As Char
    Local cToken     As Char
    Local cChaveSA6  As Char
    Local cOldSA6    As Char
    Local nContador  As Numeric
    Local nPeriodos  As Numeric
    Local nHttpCode  As Numeric
    Local nEnviromen As Numeric
    Local nEnviroOld As Numeric
    Local nPaginaIni As Numeric
    Local nPaginaFim As Numeric
    Local dProxData  As Date
    Local dDtaFinal  As Date
    Local aPeriodos  As Array
    Local aCabeca    As Array
    Local oJSon      As JSon
    Local oJSonConn  As JSon
    Local oToken     As Object
    Local oTitulo    As Object
    Local oRest      As Object
    Local oPix       As JSon
    Local cCodSch    As Character
    
    //Inicializa variáveis.
    lProcessa  := .F.
    cCodSch    := "FINA892A('" + cEmpAnt + "')"
    lExistFunc := FindFunction("gfin.util.schedule.validBranchesSchedule") .and. FindFunction("F892DtHrEx") .and. FindFunction("F892Certif") .and. FindFunction("F892UltExe")
    cFunName   := "FINA892A"  
    cTblReceb  := ""
    cDtaVenc   := ""
    cBancoOfi  := ""
    cParams    := ""
    cDtHrFim   := ""
    cDataIni   := ""
    cDataFim   := ""    
    cDataDe    := ""
    cAnoMes    := ""
    cAnoMesIni := "" 
    cAnoMesFim := ""
    cResult    := ""
    cCertifica := ""
    cCertiKey  := ""
    cHttpsQuot := ""
    cToken     := ""
    cChaveSA6  := ""
    cOldSA6    := ""
    nContador  := 0
    nPeriodos  := 0
    nHttpCode  := 0
    nEnviromen := 2
    nEnviroOld := 0
    nPaginaIni := 0
    nPaginaFim := 1
    dProxData  := CToD("")
    dDtaFinal  := CToD("")  
    aPeriodos  := {}
    aCabeca    := {}          
    oJSon      := Nil
    oJSonConn  := Nil
    oToken     := Nil
    oTitulo    := Nil
    oRest      := Nil
    oPix       := Nil

    lProcessa := lExistFunc .and. &("gfin.util.schedule.validBranchesSchedule(cCodSch)")
    
    If lProcessa
        SetFunName(cFunName)
        
        //Inicializa variáveis.   
        If __lHttpsQu == Nil
            __lHttpsQu := FindFunction("HTTPSQuote")
        EndIf
        
        If __lCFGPIX == Nil
            __lCFGPIX := SA6->(FieldPos("A6_CFGPIX")) > 0 .And. FindFunction("EnvConnPix")
        EndIf
        
        //API PIX Banco do Brasil
        If __lHttpsQu .And. __lCFGPIX
            FwLogMsg("INFO", Nil, STR0104, cFunName, "", "01", FwNoAccent(STR0103 + STR0104), 0, 0, {})            
            oJSonConn := JsonObject():New()
            oTitulo   := Titulo():New()
            oToken    := Token():New()
            
            //Lista das contas bancárias configuradas no sistema PIX
            cTblReceb := ListRecCta(Nil, "001")
            
            If !Empty(cTblReceb)
                While (cTblReceb)->(!Eof())
                    SA6->(DbGoto((cTblReceb)->REGISTRO))
                    cChaveSA6  := (xFilial("SA6", SA6->A6_FILIAL) + SA6->(A6_COD+A6_AGENCIA+A6_NUMCON))                    
                    cCertifica := ""
                    cCertiKey  := ""

                    If Empty(SA6->A6_CFGPIX) .Or. (!Empty(SA6->A6_CFGPIX) .And. ValType(cResult := oJSonConn:FromJson(SA6->A6_CFGPIX)) != "U")
                        (cTblReceb)->(DbSkip())
                        Loop
                    EndIf
                    
                    If ((ValType(oJSonConn["urlwebhook"]) != "C") .Or. (!Empty(AllTrim(oJSonConn["urlwebhook"]))))
                        (cTblReceb)->(DbSkip())
                        Loop                        
                    EndIf
                    
                    If Empty(cDtHrFim)
                        F892DtHrEx(@cDtHrFim, @cDataIni, @cDataFim, .F.)                        
                        
                        cDataDe    := StrTran(SubStr(cDataIni, 1, 10), "-", "")
                        cAnoMesIni := SubStr(cDataDe, 1, 6)
                        cAnoMesFim := StrTran(SubStr(cDataFim, 1, 7), "-", "")
                        
                        While cAnoMesIni != cAnoMesFim
                            If Empty(dProxData)
                                dDtaFinal := SToD(cDataDe)
                            Else
                                dDtaFinal := dProxData
                            EndIf
                            
                            dProxData := (dDtaFinal + 1) 
                            cAnoMes   := SubStr(FwTimeStamp(1, dProxData), 1, 6)
                            
                            If cAnoMes == cAnoMesIni
                                Loop
                            EndIf
                            
                            AAdd(aPeriodos, {cDataIni, SubStr(FwTimeStamp(3, dDtaFinal), 1, 10) + "T23:59:59"})
                            cDataIni   := SubStr(FwTimeStamp(3, dProxData), 1, 10) + "T00:00:00"
                            cDataDe    := StrTran(SubStr(cDataIni, 1, 10), "-", "")
                            cAnoMesIni := SubStr(cDataDe, 1, 6)
                            dProxData  := CTOD("")
                        EndDo
                        
                        AAdd(aPeriodos, {cDataIni, cDataFim})                        
                        nPeriodos := Len(aPeriodos)
                    EndIf
                    
                    If ((nEnviromen := oJSonConn["enviroment"]) == 1)
                        F892Certif(oJSonConn, @cCertifica, @cCertiKey)
                    EndIf
                    
                    If (nEnviroOld != nEnviromen) .Or. (cChaveSA6 != cOldSA6)
                        oToken:SetGerouTk(.F.)
                        nEnviroOld := nEnviromen
                        cOldSA6    := cChaveSA6
                    EndIf
                    
                    cBancoOfi := AllTrim(SA6->A6_BCOOFI)
                    oJSon     := EnvConnPix(nEnviromen, cBancoOfi, "token", oJSonConn["clientid"], oJSonConn["clientsecret"], "")                            
                    
                    oToken:setUrlBase(oJSon["urlbase"])
                    oToken:setPath(oJSon["path"])
                    oToken:setBody(oJSon["grantype"])
                    oToken:setHeader(oJSon["header"])                    
                    
                    If !Empty(cToken := oToken:getToken())
                        oJSon   := EnvConnPix(nEnviromen, cBancoOfi, "pix", Nil, Nil, oJSonConn["appkey"], .F.)
                        aCabeca := Aclone(oJSon["header"])
                        
                        If Len(aCabeca) >= 3                            
                            For nContador := 1 To nPeriodos
                                nPaginaIni := 0
                                nPaginaFim := 1
                                nHttpCode  := 404
                                
                                If nContador > 1
                                    oJSon["header"] := Aclone(aCabeca)
                                    cToken := oToken:getToken()
                                EndIf
                                
                                While nPaginaIni < nPaginaFim
                                    If nPaginaIni > 0
                                        oJSon["header"] := Aclone(aCabeca)
                                        cToken := oToken:getToken()
                                    EndIf
                                    
                                    If !Empty(cToken)
                                        oJSon["header"][3] += cToken                                        
                                        
                                        cParams := "&" + StrTran(oJSon["appkey"], "?", "")
                                        cParams += "&inicio=" + aPeriodos[nContador, 1]
                                        cParams += "&fim=" + aPeriodos[nContador, 2]
                                        cParams += "&status=CONCLUIDA"
                                        
                                        If nPaginaFim > 1 
                                            cParams += "&paginacao.paginaAtual=" + cValToChar(nPaginaIni)
                                        EndIf
                                        
                                        cHttpsQuot := 'HTTPSQuote((oJSon["urlbase"]+oJSon["path"]), cCertifica, cCertiKey, "", "GET", cParams, Nil, 120, oJSon["header"], Nil, .F.)'
                                        cResult    := &cHttpsQuot
                                        nHttpCode  := HTTPGetStatus(Nil, Nil)
                                        
                                        If ((nHttpCode == 200) .Or. (nHttpCode == 201))
                                            oPix    := JSONObject():New()
                                            
                                            If ValType(cResult := oPix:FromJSON(cResult)) == "U"
                                                If nPaginaIni == 0
                                                    nPaginaFim := oPix["parametros"]["paginacao"]["quantidadeDePaginas"]
                                                EndIf                                                
                                                
                                                oTitulo:baixaTitul(oPix)
                                            EndIf
                                        EndIf
                                    EndIf
                                    
                                    nPaginaIni += 1
                                EndDo
                                
                                If (nHttpCode != 200) .And. (nHttpCode != 201)
                                    If nContador < nPeriodos
                                        Loop
                                    EndIf
                                    
                                    (cTblReceb)->(DbSkip())
                                    Loop
                                EndIf
                            Next nContador
                        EndIf
                    EndIf
                    
                    (cTblReceb)->(DbSkip())
                EndDo
                
                If !Empty(cDtHrFim)
                    F892UltExe(cDtHrFim)
                    cDtHrFim := ""
                EndIf
                
                (cTblReceb)->(DbCloseArea())
                cTblReceb := ""
                cResult   := ""
            EndIf
        EndIf
    Endif    

    FwFreeArray(aPeriodos)
Return Nil

/*/{Protheus.doc} SchedDef
	Função que permite ao frame fazer a preparação do
    ambiente de execuçãodo schedule.
	  
    @author Sivaldo Oliveira
    @since 09/01/2023
    @return aParam, vetor de 5 posições.
/*/
Static Function SchedDef()
	Local aParam As Array

    //Inicializa variável
	aParam := {"P", "", Nil, Nil, Nil}
Return aParam
