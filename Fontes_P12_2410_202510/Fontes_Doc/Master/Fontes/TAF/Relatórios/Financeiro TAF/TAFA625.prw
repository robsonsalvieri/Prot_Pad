#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFA625
@type        function
@description Realiza busca no financeiro dos titulos de emissão e baixa.
@author      Rafael de Paula Leme
@since       29/05/2024
@return

/*/
//------------------------------------------------------------------------
Function TAFA625(cIdReq, lAutomato)

    Local oRequest as object
    Local cIDV3A   as character
    Local cFilProc as character
    Local lOk      as logical
    Local aRetFil  as array
    Local aFilProc as arrays
    Local nFil     as numeric

    Default cIdReq    := ""
    Default lAutomato := .F.
   
    oRequest := JsonObject():New()
    cIDV3A   := MV_PAR01
    cFilProc := ""
    lOk      := .T.
    aRetFil  := {}
    aFilProc := {}
    nFil     := 1

    If lAutomato
        cIDV3A := MV_PAR01 := cIdReq
    EndIf

    DBSelectArea("V3A")
    V3A->(DBSetOrder(1))

    If V3A->(DbSeek(xFilial("V3A") + cIDV3A))
        If Reclock("V3A", .F.)
            V3A->V3A_STSFIN := '1'
            If V3A->V3A_STATUS == '0'
                V3A->V3A_STATUS	:= '1'
            EndIf
		    V3A->(MsUnlock())
        EndIf

        oRequest:FromJson(V3A->V3A_PARAMS)

        If oRequest['branchId'] == 'Todas'
            aRetFil := GetFilRel(V3A->V3A_FILIAL)
            For nFil := 1 to Len(aRetFil)
                aadd(aFilProc,aRetFil[nFil][1])
            Next nFil
        Else
            aadd(aFilProc,oRequest['branchId'])
        EndIf

        For nFil := 1 to Len(aFilProc)

            cFilProc := aFilProc[nFil]
            TafConout( "---> Processando filial: " + cFilProc)

             //1-Emissão 2-Baixa 3-Todos
            If cValToChar(oRequest['emissionLow']) $ "1|3"
                lOk := GetEmission(oRequest, cFilProc)
            EndIf

             //1-Emissão 2-Baixa 3-Todos
             //WSTAF06244 Simula erro na gravação das faturas e pagamentos
            If (lOk .and. cValToChar(oRequest['emissionLow']) $ "2|3") .or. (lAutomato .and. FWIsInCallStack('WSTAF06244'))
                lOk := GetLow(oRequest, cFilProc)
            EndIf
        Next nFil

        If Reclock("V3A", .F.)
            If lOk
                V3A->V3A_STSFIN := '2'
                If V3A->V3A_STSTAF == '2' .or. oRequest['onlyTaf'] == 2
                    V3A->V3A_STATUS := '2'
                    lOk := TAFXFIN(oRequest, cIDV3A, V3A->V3A_FILIAL)
                    V3A->V3A_DTRESP	:= Date()
			        V3A->V3A_HRRESP	:= StrTran(Time(), ":", "")      
                EndIf
            EndIf

            If !lOk .or. V3A->V3A_STSTAF == '3'
                V3A->V3A_STSFIN := '3'
                V3A->V3A_STATUS := '3'
                V3A->V3A_DTRESP	:= Date()
			    V3A->V3A_HRRESP	:= StrTran(Time(), ":", "")    
            EndIf

            V3A->(MsUnlock())
        EndIf
    EndIf

    FreeObj(oRequest)
Return

/*/{Protheus.doc} GetEmission
@type        function
@description Busca no financeiro títulos emissão
@author      Rafael de Paula Leme
@since       31/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GetEmission(oRequest, cFilProc)
    
    Local oFin       as object
	Local oResponse  as object
    Local oInsertV5I as object
    Local oInsertV58 as object
	Local jParam     as json
	Local lHasNext   as logical    
    Local lGrava     as logical
    Local lOk        as logical
	Local nPage      as numeric
    Local nX         as numeric
    Local nY         as numeric
    Local cIDV5I     as character
    Local cIDV3A     as character

    Default cFilProc := ""

    oFin       := totvs.protheus.backoffice.fin.taf.integration.TafIntegration():new() 
	oResponse  := Nil
	oInsertV5I := Nil
    oInsertV58 := Nil
    jParam     := JsonObject():new()
	lHasNext   := .T.
    lGrava     := .T.
    lOk        := .T.
	nPage      := 1
    nX         := 1
    nY         := 1
    cIDV5I     := ""
    cIDV3A     := MV_PAR01  

    jParam['branch']             := cFilProc
    jParam['initialDate']        := StoD(Substr(oRequest['initialDate'],1,4) + Substr(oRequest['initialDate'],6,2) + Substr(oRequest['initialDate'],9,2))
    jParam['finalDate']          := StoD(Substr(oRequest['finalDate'],1,4) + Substr(oRequest['finalDate'],6,2) + Substr(oRequest['finalDate'],9,2))
    jParam['typeDatePayable']    := cValToChar(oRequest['typeDatePayable'])
    jParam['typeDateReceivable'] := "2"
    jParam['event4020']          := "40"
    jParam['pageSize']           := "100"

	oFin:setParameters(jParam)

    oInsertV5I := FwBulk():New(RetSQLName("V5I"))
    oInsertV5I:SetFields(V5I->(DbStruct()))

    oInsertV58 := FwBulk():New(RetSQLName("V58"))
    oInsertV58:SetFields(V58->(DbStruct()))

	While lHasNext .and. Empty(oInsertV5I:GetError()) .and. Empty(oInsertV58:GetError())
        oResponse := oFin:getBills(nPage++)
        If oResponse:hasProperty('hasNext')
            lHasNext := oResponse['hasNext']
            For nX := 1 to Len(oResponse['items'])
                If Len(oResponse['items'][nX]['natureOfIncome']) > 0
                    If oRequest['onlyTaf'] == 3
                        lGrava := .T.
                    ElseIf oRequest['onlyTaf'] == 1 .and. oResponse['items'][nX]['finSentTaf'] == '1'
                        lGrava := .T.
                    ElseIf oRequest['onlyTaf'] == 2 .and. oResponse['items'][nX]['finSentTaf'] == '2'
                        lGrava := .T.
                    Else
                        lGrava := .F.                
                    EndIf

                    If lGrava
                        cIDV5I := TAFGeraID("TAFV5I")
                        oInsertV5I:AddData({xFilial("V5I"),;
                        cIDV3A,;
                        AllTrim(cIDV5I),;
                        "1",;
                        oResponse['items'][nX]['branch'],;
                        oResponse['items'][nX]['billPrefix'],;
                        oResponse['items'][nX]['billNumber'],;
                        oResponse['items'][nX]['operationType'],;
                        DtoS(CtoD(oResponse['items'][nX]['billDate'])),;
                        oResponse['items'][nX]['participatingCode'],;
                        oResponse['items'][nX]['documentValue'],;
                        '',;
                        oResponse['items'][nX]['finSentTaf'];
                        })
                        
                        For nY := 1 to Len(oResponse['items'][nX]['natureOfIncome'])
                            oInsertV58:AddData({xFilial("V58"),;
                            cIDV3A,;
                            cIDV5I,;
                            oResponse['items'][nX]['natureOfIncome'][nY]['code'],;
                            '',;
                            0;
                            })
                        Next nY
                        cIDV5I := ""
                    EndIf
                EndIf
            Next nX
        EndIf
    EndDo

    //Simulação de erro de gravação para caso de teste WSTAF06244
    If FWIsInCallStack('WSTAF06244')
        oInsertV5I:CERROR := 'Simula erro de gravação'
    EndIf

    If !Empty(oInsertV5I:GetError()) .or. !Empty(oInsertV58:GetError()) .or. !oInsertV5I:Flush() .or. !oInsertV58:Flush() 
        lOk := .F.
    EndIf

    FreeObj(oFin)
    FreeObj(oResponse)
    FreeObj(oInsertV5I)
    FreeObj(oInsertV58)
    FreeObj(jParam)

Return lOk

/*/{Protheus.doc} GetLow
@type        function
@description Busca baixas no financeiro
@author      Rafael de Paula Leme
@since       31/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GetLow(oRequest, cFilProc)
    
    Local oFin       as object
	Local oResponse  as object
    Local oInsertV5I as object
    Local oInsertV58 as object
	Local jParam     as json
	Local lHasNext   as logical    
    Local lGrava     as logical
    Local lOk        as logical
    Local lRet       as logical
	Local nPage      as numeric
    Local nX         as numeric
    Local nY         as numeric
    Local nTotV58    as numeric
    Local cIDV5I     as character
    Local cIDV3A     as character
    Local NumPgto    as character

    Default cFilProc := ""

    oFin       := totvs.protheus.backoffice.fin.taf.integration.TafIntegration():new() 
	oResponse  := Nil
    oInsertV5I := Nil
    oInsertV58 := Nil
	jParam     := JsonObject():new()
	lHasNext   := .T.
    lGrava     := .T.
    lOk        := .T.
    lRet       := .T.
	nPage      := 1
    nX         := 0
    nY         := 0
    nTotV58    := 0
    cIDV5I     := ""
    cIDV3A     := MV_PAR01
    NumPgto    := ""

    jParam['branch']             := cFilProc
    jParam['initialDate']        := StoD(Substr(oRequest['initialDate'],1,4) + Substr(oRequest['initialDate'],6,2) + Substr(oRequest['initialDate'],9,2))
    jParam['finalDate']          := StoD(Substr(oRequest['finalDate'],1,4) + Substr(oRequest['finalDate'],6,2) + Substr(oRequest['finalDate'],9,2))
    jParam['typeDatePayable']    := cValToChar(oRequest['typeDatePayable'])
    jParam['typeDateReceivable'] := "2"
    jParam['event4020']          := "40"
    jParam['pageSize']           := "100"

	oFin:setParameters(jParam)

    oInsertV5I := FwBulk():New(RetSQLName("V5I"))
    oInsertV5I:SetFields(V5I->(DbStruct()))

    oInsertV58 := FwBulk():New(RetSQLName("V58"))
    oInsertV58:SetFields(V58->(DbStruct()))

	While lHasNext .and. Empty(oInsertV5I:GetError()) .and. Empty(oInsertV58:GetError())
        oResponse := oFin:getWriteOff(nPage++)
        If oResponse:hasProperty('hasNext')
            lHasNext := oResponse['hasNext']
            For nX := 1 to Len(oResponse['items'])
                nTotV58 := 0
                NumPgto := ""
                If Len(oResponse['items'][nX]['natureOfIncome']) > 0
                    If oRequest['onlyTaf'] == 3
                        lGrava := .T.
                    ElseIf oRequest['onlyTaf'] == 1 .and. oResponse['items'][nX]['finSentTaf'] == '1'
                        lGrava := .T.
                    ElseIf oRequest['onlyTaf'] == 2 .and. oResponse['items'][nX]['finSentTaf'] == '2'
                        lGrava := .T.
                    Else
                        lGrava := .F.                
                    EndIf

                    If lGrava
                        DBSelectArea("V5I")
                        V5I->(DBSetOrder(2))
                        V5I->(dbGoTop())         
                        If V5I->(DbSeek(xFilial("V5I") + cIDV3A + oResponse['items'][nX]['branch'] + '1' + oResponse['items'][nX]['billPrefix'] + oResponse['items'][nX]['billNumber']))
                            If Empty(V5I->V5I_SEQUEN) .and. oResponse['items'][nX]['participatingCode'] == AllTrim(V5I->V5I_CODPAR)
                                GravaV5I(oResponse, nX, cIDV3A, V5I->V5I_ID)
                                lRet := .F.
                            Endif
                        EndIf
                        
                        If lRet
                            cIDV5I := TAFGeraID("TAFV5I")

                            For nY := 1 to Len(oResponse['items'][nX]['natureOfIncome'])
                                oInsertV58:AddData({xFilial("V58"),;
                                cIDV3A,;
                                cIDV5I,;
                                oResponse['items'][nX]['natureOfIncome'][nY]['code'],;
                                '',;
                                oResponse['items'][nX]['natureOfIncome'][nY]['grossValue'];
                                })
                                nTotV58 += oResponse['items'][nX]['natureOfIncome'][nY]['grossValue']
                            Next nY

                            //Verifico se existe parcela no pagamento para compor o numero.
                            If !Empty(oResponse['items'][nX]['billInstallment'])
                                NumPgto := (oResponse['items'][nX]['billNumber']) + '-' + AllTrim(oResponse['items'][nX]['billInstallment'])
                            Else
                                NumPgto := oResponse['items'][nX]['billNumber']
                            EndIf

                            oInsertV5I:AddData({xFilial("V5I"),;
                            cIDV3A,;
                            cIDV5I,;
                            "2",;
                            oResponse['items'][nX]['branch'],;
                            oResponse['items'][nX]['billPrefix'],;
                            AllTrim(NumPgto),;
                            oResponse['items'][nX]['operationType'],;
                            DtoS(CtoD(oResponse['items'][nX]['paymentDate'])),;
                            oResponse['items'][nX]['participatingCode'],;
                            nTotV58,;
                            oResponse['items'][nX]['paymentSequence'],;
                            oResponse['items'][nX]['finSentTaf'];
                            })
                        EndIf
                    EndIf
                    lRet := .T.
                EndIf
            Next nX
        EndIf
    EndDo

    //Simulação de erro de gravação para caso de teste WSTAF06243
    If FWIsInCallStack('WSTAF06244')
        oInsertV5I:CERROR := 'Simula erro de gravação'
    EndIf
   
    If !Empty(oInsertV5I:GetError()) .or. !Empty(oInsertV58:GetError()) .or. !oInsertV5I:Flush() .or. !oInsertV58:Flush()
        lOk := .F.
    EndIf

    FreeObj(oFin)
    FreeObj(oResponse)
    FreeObj(oInsertV5I)
    FreeObj(oInsertV58)
    FreeObj(jParam)

Return lOk

/*/{Protheus.doc} Scheddef
@type        function
@author      Rafael de Paula Leme
@since       24/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function Scheddef()
    Local aParam := {}

    aParam := {'P', 'TAFRELFIN', '', {}, ''}

Return aParam

/*/{Protheus.doc} GetFilRel
	(Retorna lista de filiais da empresa logada)
	@author Rafael Leme
	@since 17/06/2024
	@return aRetFil, array, filiais da empresa
/*/
Function GetFilRel(cFilRequest)

	Local nFil    := 0
	Local aRetFil := TAFGetFil(.F.,.T.,"C20",.F.,.F.,.F.)

	for nFil := 1 to len(aRetFil)
		//Após o uso da SetRestFault(), em alguns casos, a função TAFGetFil está trazendo apenas a empresa e filial atual na requisição subsequente, por isso essa proteção
		aRetFil[nFil] := iif(ValType(aRetFil[nFil]) == "C", StrTokArr( aRetFil[nFil] , "-" ),aRetFil[nFil])
		//Proteção para evitar retorno zerado da função TAFGetFil. Com a compilação do TAFGetFil() atualizado esse problema não irá mais ocorrer
		aRetFil[nFil] := iif(ValType(aRetFil[nFil]) == "A", aRetFil[nFil] ,{cFilRequest, cFilRequest})
	next

Return aRetFil

/*/{Protheus.doc} GravaV5I
@type        function
@description Atualiza V5I e V58 de registros existentes.
@author      Carlos Pister
@since       02/09/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GravaV5I(oResponse, nX, cIDV3A, cId)

    Local lRet       as logical
    Local nY         as numeric
    
    lRet       := .T.
    nY         := 0

    Reclock("V5I", .F.)
    V5I->V5I_FILIAL := xFilial("V5I")
    V5I->V5I_EMISBX := '2'
    V5I->V5I_DTEMIS := CtoD(oResponse['items'][nX]['paymentDate'])
    V5I->V5I_SEQUEN := oResponse['items'][nX]['paymentSequence']
    V5I->V5I_ENVTAF := oResponse['items'][nX]['finSentTaf']
    V5I->V5I_VLBRUT := 0
    
    For nY := 1 to Len(oResponse['items'][nX]['natureOfIncome'])
        DBSelectArea("V58")
        V58->(DBSetOrder(1))            
        If V58->(DbSeek(xFilial("V58") + cIDV3A + cId + oResponse['items'][nX]['natureOfIncome'][nY]['code']))
            lRet := .F.
        EndIf 

        Reclock("V58", lRet)        
        V58->V58_FILIAL := xFilial("V58")
        V58->V58_IDREQ  := cIDV3A
        V58->V58_IDV5I  := cId
        V58->V58_NATREN := oResponse['items'][nX]['natureOfIncome'][nY]['code']
        V58->V58_DECTER := ''
        V58->V58_VALOR  := oResponse['items'][nX]['natureOfIncome'][nY]['grossValue']
        V5I->V5I_VLBRUT += V58->V58_VALOR
        V58->( MsUnlock() )
    Next nY

    V5I->( MsUnlock() )

Return
