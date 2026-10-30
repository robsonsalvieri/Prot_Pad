#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TAFA626
@type        function
@description Realiza busca da LEM e V3U no TAF
@author      Rafael de Paula Leme
@since       07/06/2024
@return

/*/
//-------------------------------------------------------------------
Function TAFA626(cIdReq, lAutomato)

    Local oRequest as object
    Local aRetFil  as array
    Local aFilProc as array
    Local cIDV3A   as character
    Local cFilProc as character
    Local lOk      as logical
    Local nFil     as numeric

    Default cIdReq    := ""
    Default lAutomato := .F.

    oRequest := JsonObject():New()
    aRetFil  := {}
    aFilProc := {}
    IIf (lAutomato, cIDV3A := cIdReq, cIDV3A := MV_PAR01)
    lOk      := .T.
    nFil     := 1
    cFilProc := ""

    DBSelectArea("V3A")
    V3A->(DBSetOrder(1))

    If V3A->(DbSeek(xFilial("V3A") + cIDV3A))
        If Reclock("V3A", .F.)
            If V3A->V3A_STATUS == '0'
                V3A->V3A_STATUS	:= '1'
            EndIf
            V3A->V3A_STSTAF := '1'
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

        If oRequest['onlyTaf'] == 1 .or. oRequest['onlyTaf'] == 3
            ProcTitTaf(oRequest, cIDV3A, aFilProc)
        EndIf

        If Reclock("V3A", .F.)
            V3A->V3A_STSTAF := '2'
            If V3A->V3A_STSFIN == '2'
                V3A->V3A_STATUS := '2'
                lOk := TAFXFIN(oRequest, cIDV3A, V3A->V3A_FILIAL)
                V3A->V3A_DTRESP	:= Date()
			    V3A->V3A_HRRESP	:= StrTran(Time(), ":", "")                    
            EndIf

            If !lOk .or. V3A->V3A_STSFIN == '3'
                V3A->V3A_STSTAF := '3'
                V3A->V3A_STATUS := '3'
                V3A->V3A_DTRESP	:= Date()
			    V3A->V3A_HRRESP	:= StrTran(Time(), ":", "")    
            EndIf

		    V3A->(MsUnlock())
		EndIf
    EndIf

    FreeObj(oRequest)

Return

/*/{Protheus.doc} ProcTitTaf
@type        function
@description Monta e executa query de faturas e pagamentos.
@author      Rafael de Paula Leme
@since       07/06/2024
@return

/*/
//-------------------------------------------------------------------
Static Function ProcTitTaf(oRequest, cIDV3A, aFilProc)

    Local oPrepTit   as object
    Local cQuery     as character
    Local cAliasFat  as character
    Local cIDV5W     as character
    Local cBd        as character
    Local nIndBind   as numeric
    Local cCompC1H   as character
    Local aInfEUF    as array
    
    oPrepTit   := Nil
    cQuery     := ""
    cAliasFat  := ''
    cIDV5W     := ""
    cBd	       := Upper(AllTrim(TcGetDb()))
    nIndBind   := 1
    cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
    aInfEUF    := TAFTamEUF(Upper(AllTrim(FWSM0Util():GetSM0Data(,,{'M0_LEIAUTE'})[1][2])))

    If cValToChar(oRequest['emissionLow']) $ "1|3"

        cQuery += " SELECT "
        cQuery += " LEM.LEM_FILIAL                     FILIAL, "
        cQuery += " '1'                                EMISBX, "
        cQuery += " COALESCE(C1H.C1H_CNPJ,C1H.C1H_CPF) CPFCGC, "
        cQuery += " C1H.C1H_NOME                         NOME, "
        cQuery += " LEM.LEM_NUMERO                     NUMERO, "
        cQuery += " LEM.LEM_PREFIX                     PREFIX, "
        cQuery += " ' '                                SEQUEN, "
        cQuery += " LEM.LEM_NATTIT                     NATTIT, "

        If cValToChar(oRequest['typeDatePayable']) == '2'
            cQuery += " LEM.LEM_DTEMIS                DTEMIS, "
        Else
            cQuery +="  LEM.LEM_DTCONT                DTEMIS, "
        EndIf

        cQuery += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIf Else C1H.C1H_CODPAR END CODPAR, "
        cQuery += " SUM(LEM.LEM_VLBRUT)              VALBRUTO, "
        cQuery += " V3O.V3O_CODIGO                     NATREN, "
        cQuery += " V3S.V3S_DECTER                     DECTER, "
        cQuery += " SUM(V3S.V3S_VALOR)                  VALOR, "
        cQuery += " SUM(V47.V47_VLTRIB)                 VALIR, "
        cQuery += " SUM(0)                             VALPIS, "
        cQuery += " SUM(0)                          VALCOFINS, "
        cQuery += " SUM(0)                            VALCSLL, "
        cQuery += " SUM(0)                             VAGREG, "
        cQuery += " ' '                                 IDCOMP  "
        
        cQuery += " FROM " + RetSqlName("LEM") + " LEM "

        cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON " 

        If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. aInfEUF[1] + aInfEUF[2] == 0)
            cQuery += " C1H.C1H_FILIAL = ? "
        Else
            cQuery += FwJoinFilial("C1H", "LEM")
        EndIf

        cQuery += " AND C1H.C1H_ID = LEM.LEM_IDPART "
        cQuery += " AND C1H.D_E_L_E_T_ = ? "

        cQuery += " LEFT JOIN " + RetSqlName("V3S") + " V3S ON V3S.V3S_FILIAL = LEM.LEM_FILIAL "
        cQuery += " AND V3S.V3S_ID = LEM.LEM_ID "
        cQuery += " AND V3S.V3S_IDPART = LEM.LEM_IDPART "
        cQuery += " AND V3S.V3S_NUMFAT = LEM.LEM_NUMERO "
        cQuery += " AND V3S.D_E_L_E_T_ = ? "

        cQuery += " LEFT JOIN " + RetSqlName("V47") + " V47 ON V47.V47_FILIAL = V3S.V3S_FILIAL "
        cQuery += " AND V47.V47_ID = V3S.V3S_ID "
        cQuery += " AND V47.V47_IDPART = V3S.V3S_IDPART "
        cQuery += " AND V47.V47_NUMFAT = V3S.V3S_NUMFAT "
        cQuery += " AND V47.V47_IDNATR = V3S.V3S_IDNATR "
        cQuery += " AND V47.V47_DECTER = V3S.V3S_DECTER "
        cQuery += " AND V47.V47_IDTRIB = ? "
        cQuery += " AND V47.D_E_L_E_T_ = ? "

        cQuery += " LEFT JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
        cQuery += " AND V3O.V3O_ID = V3S.V3S_IDNATR "
        cQuery += " AND V3O.D_E_L_E_T_ = ? "
    
        cQuery += " WHERE "
        cQuery += " LEM.LEM_FILIAL IN ( ? ) "
        
        If cValToChar(oRequest['typeDatePayable']) == '2'
            cQuery += " AND LEM.LEM_DTEMIS  BETWEEN ? AND ? "
        Else
            cQuery += " AND LEM.LEM_DTCONT  BETWEEN ? AND ? "
        EndIf
    
        cQuery += " AND LEM.LEM_NATTIT = ? "       
        cQuery += " AND LEM.D_E_L_E_T_ = ? "
        
        cQuery += " GROUP BY "
        cQuery += " LEM.LEM_FILIAL, "
        cQuery += " C1H.C1H_CNPJ, "
        cQuery += " C1H.C1H_CPF, "
        cQuery += " C1H.C1H_NOME, "
        cQuery += " LEM.LEM_NUMERO, "
        cQuery += " LEM.LEM_PREFIX, "
        cQuery += " LEM.LEM_NATTIT, "
        
        If cValToChar(oRequest['typeDatePayable']) == '2'
            cQuery += " LEM.LEM_DTEMIS, "
        Else
            cQuery +="  LEM.LEM_DTCONT, "
        EndIf
        
        cQuery += " C1H.C1H_PAISEX, "
        cQuery += " C1H.C1H_NIf, "
        cQuery += " C1H.C1H_CODPAR, "
        cQuery += " V3O.V3O_CODIGO, "
        cQuery += " V3S.V3S_DECTER "
    EndIf

    If cValToChar(oRequest['emissionLow']) $ "2|3"

        If cValToChar(oRequest['emissionLow']) == "3"
             cQuery += " UNION ALL "
        EndIf

        cQuery += " SELECT "
	    cQuery += " V3U.V3U_FILIAL                     FILIAL, "
        cQuery += " '2'                                EMISBX, "
	    cQuery += " COALESCE(C1H.C1H_CNPJ,C1H.C1H_CPF) CPFCGC, "
	    cQuery += " C1H.C1H_NOME                         NOME, "
	    cQuery += " V3U.V3U_NUMERO                     NUMERO, "
	    cQuery += " V3U.V3U_SERIE                      PREFIX, "
	    cQuery += " V3U.V3U_SEQUEN                     SEQUEN, "
	    cQuery += " V3U.V3U_NATTIT                     NATTIT, "
	    cQuery += " V3U.V3U_DTPAGT                     DTEMIS, "
        cQuery += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIf Else C1H.C1H_CODPAR END CODPAR, "   
        cQuery += " COALESCE((SELECT SUM(V3V.V3V_VALOR) FROM " + RetSqlName("V3V") + " V3V  "
        cQuery += " WHERE V3VA.V3V_ID = V3V.V3V_ID AND V3V.D_E_L_E_T_ = ?), 0)  VALBRUTO, "
        cQuery += " V3O.V3O_CODIGO                     NATREN, "
        cQuery += " V3VA.V3V_DECTER                    DECTER, "
        cQuery += " V3VA.V3V_VALOR                     VALOR,  "
	    
        cQuery += " COALESCE(SUM(CASE WHEN V46.V46_IDTRIB = ? THEN V46.V46_VALOR Else 0 END), 0)     VALIR, "
	    cQuery += " COALESCE(SUM(CASE WHEN V46.V46_IDTRIB = ? THEN V46.V46_VALOR Else 0 END), 0)    VALPIS, "
        cQuery += " COALESCE(SUM(CASE WHEN V46.V46_IDTRIB = ? THEN V46.V46_VALOR Else 0 END), 0) VALCOFINS, "
        cQuery += " COALESCE(SUM(CASE WHEN V46.V46_IDTRIB = ? THEN V46.V46_VALOR Else 0 END), 0)   VALCSLL, "
        cQuery += " COALESCE(SUM(CASE WHEN V46.V46_IDTRIB IN (?) THEN V46.V46_VALOR Else 0 END), 0) VAGREG, "
        
        cQuery += " V3VA.V3V_ID                         IDCOMP "//ID PARA COMPARAÇÃO
        
        cQuery += " FROM " + RetSqlName("V3U") + " V3U "
        
        cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "

        If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. aInfEUF[1] + aInfEUF[2] == 0)
            cQuery += " C1H.C1H_FILIAL = ? "
        Else
            cQuery += FwJoinFilial("C1H", "V3U")
        EndIf

        cQuery += " AND C1H.C1H_ID = V3U.V3U_IDPART "
        cQuery += " AND C1H.D_E_L_E_T_ = ? "
        
        cQuery += " LEFT JOIN " + RetSqlName("V3V") + " V3VA ON V3VA.V3V_FILIAL = V3U.V3U_FILIAL "
        cQuery += " AND V3VA.V3V_ID = V3U.V3U_ID "
        cQuery += " AND V3VA.V3V_CNATRE <> '" + Space(TamSX3("V3V_CNATRE")[1]) + "' "
        cQuery += " AND V3VA.D_E_L_E_T_ = ? "
               
        cQuery += " LEFT JOIN " + RetSqlName("V46") + " V46 ON V46.V46_FILIAL = V3VA.V3V_FILIAL "
        cQuery += " AND V46.V46_ID = V3VA.V3V_ID "
        cQuery += " AND V46.V46_IDNAT = V3VA.V3V_CNATRE "
        cQuery += " AND V46.V46_IDTRIB IN (?) "
        cQuery += " AND V46.D_E_L_E_T_ = ? "

        cQuery += " LEFT JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
        cQuery += " AND V3O.V3O_ID = V3VA.V3V_CNATRE "
        cQuery += " AND V3O.D_E_L_E_T_ = ? "
        
        cQuery += " WHERE V3U.V3U_FILIAL IN ( ? )"
        cQuery += " AND V3U.V3U_NATTIT = ? "
        cQuery += " AND V3U.V3U_DTPAGT BETWEEN ? AND ? "
        cQuery += " AND V3U.D_E_L_E_T_ = ? "

        cQuery += " GROUP BY "
        cQuery += " V3U.V3U_FILIAL, "
        cQuery += " C1H.C1H_CNPJ, "
        cQuery += " C1H.C1H_CPF, "
        cQuery += " C1H.C1H_NOME, "
        cQuery += " V3U.V3U_NUMERO, "
        cQuery += " V3U.V3U_SERIE,  "
        cQuery += " V3U.V3U_SEQUEN, "
        cQuery += " V3U.V3U_NATTIT, "
        cQuery += " V3U.V3U_DTEMIS, "
        cQuery += " C1H.C1H_PAISEX, "
        cQuery += " C1H.C1H_NIf, "
        cQuery += " C1H.C1H_CODPAR, "
        cQuery += " V3U.V3U_DTPAGT, "
        cQuery += " V3O.V3O_CODIGO, "
        cQuery += " V3VA.V3V_DECTER, "
        cQuery += " V3VA.V3V_ID, "
        cQuery += " V3VA.V3V_VALOR"
    EndIf

    cQuery += " ORDER BY "
    cQuery += " FILIAL, "
    cQuery += " EMISBX, "
    cQuery += " CPFCGC, "
    cQuery += " NUMERO, "
    cQuery += " PREFIX, "
    cQuery += " NATTIT "

    If !("DB2" $ cBd)
		cQuery := ChangeQuery(cQuery)
	EndIf

    oPrepTit := FWPreparedStatement():New()	
    oPrepTit:SetQuery(cQuery)

    If cValToChar(oRequest['emissionLow']) $ "1|3"
        oPrepTit:SetString(nIndBind++, space(1)) //C1H.C1H_PAISEX <> ? 
        If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. aInfEUF[1] + aInfEUF[2] == 0)
            oPrepTit:SetString(nIndBind++, xFilial("C1H")) //C1H.C1H_FILIAL = ?
        EndIf
        oPrepTit:SetString(nIndBind++, space(1)) //C1H.D_E_L_E_T_ = ? 
        oPrepTit:SetString(nIndBind++, space(1)) //V3S.D_E_L_E_T_ = ?
        oPrepTit:SetString(nIndBind++, '000012') //V47.V47_IDTRIB = ?
        oPrepTit:SetString(nIndBind++, space(1)) //V47.D_E_L_E_T_ = ?
        oPrepTit:SetString(nIndBind++, space(1)) //V3O.D_E_L_E_T_ = ?
        oPrepTit:SetIn(nIndBind++, aFilProc) //LEM.LEM_FILIAL IN
        oPrepTit:SetString(nIndBind++, Substr(oRequest['initialDate'],1,4) + Substr(oRequest['initialDate'],6,2) + Substr(oRequest['initialDate'],9,2)) //LEM.LEM_DTEMIS  BETWEEN
        oPrepTit:SetString(nIndBind++, Substr(oRequest['finalDate'],1,4) + Substr(oRequest['finalDate'],6,2) + Substr(oRequest['finalDate'],9,2)) //LEM.LEM_DTEMIS  BETWEEN
        oPrepTit:SetString(nIndBind++, '0') //LEM.LEM_NATTIT = ?
        oPrepTit:SetString(nIndBind++, space(1)) //LEM.D_E_L_E_T_ = ?
    EndIf

    If cValToChar(oRequest['emissionLow']) $ "2|3"
        oPrepTit:SetString(nIndBind++, space(1)) //C1H.C1H_PAISEX <> 
        oPrepTit:SetString(nIndBind++, space(1)) //V3V.D_E_L_E_T_ = 
        oPrepTit:SetString(nIndBind++, '000028') //V46.V46_IDTRIB =
        oPrepTit:SetString(nIndBind++, '000010') //V46.V46_IDTRIB =
        oPrepTit:SetString(nIndBind++, '000011') //V46.V46_IDTRIB =
        oPrepTit:SetString(nIndBind++, '000018') //V46.V46_IDTRIB =
        oPrepTit:SetIn(nIndBind++, {'000029','000030'}) //V46.V46_IDTRIB IN
        If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. aInfEUF[1] + aInfEUF[2] == 0)
            oPrepTit:SetString(nIndBind++, xFilial("C1H")) //C1H.C1H_FILIAL = ?
        EndIf
        oPrepTit:SetString(nIndBind++, space(1)) //C1H.D_E_L_E_T_ =
        oPrepTit:SetString(nIndBind++, space(1)) //V3VA.D_E_L_E_T_ =
        oPrepTit:SetIn(nIndBind++, {'000010','000011','000018','000028','000029','000030'}) //V46.V46_IDTRIB IN
        oPrepTit:SetString(nIndBind++, space(1)) //V46.D_E_L_E_T_ = 
        oPrepTit:SetString(nIndBind++, space(1)) //V3O.D_E_L_E_T_ = 
        oPrepTit:SetIn(nIndBind++, aFilProc) //V3U.V3U_FILIAL IN
        oPrepTit:SetString(nIndBind++, '0') //V3U.V3U_NATTIT = 
        oPrepTit:SetString(nIndBind++, Substr(oRequest['initialDate'],1,4) + Substr(oRequest['initialDate'],6,2) + Substr(oRequest['initialDate'],9,2)) //V3U.V3U_DTPAGT BETWEEN
        oPrepTit:SetString(nIndBind++, Substr(oRequest['finalDate'],1,4) + Substr(oRequest['finalDate'],6,2) + Substr(oRequest['finalDate'],9,2)) //V3U.V3U_DTPAGT BETWEEN
        oPrepTit:SetString(nIndBind++, space(1)) //V3U.D_E_L_E_T_ =
    EndIf

    cQuery := oPrepTit:GetFixQuery()
    cAliasFat := MPSysOpenQuery(cQuery)

    GravaV5WR(cAliasFat, cIDV3A)

    (cAliasFat)->(DbCloseArea())
    oPrepTit:Destroy()

Return

/*/{Protheus.doc} TAFXFIN
@type        function
@description Realiza comparação TAF x Financeiro
@author      Carlos Pister
@since       06/08/2024
@return

/*/
//-------------------------------------------------------------------
Function TAFXFIN(oRequest, cIDV3A, cFilV3A)

    Local oExecQry   as object
    Local cQuery     as character
    Local cAliasFat  as character
    Local lOk        as logical
    Local cBd        as character
    Local cCompC1H   as character 
    Local nIndBind   as numeric
    local aInfEUF    as array

    Default cIDV3A   := ''
    Default cFilV3A  := ''

    oExecQry   := Nil
    cQuery     := ""
    cAliasFat  := ''
    lOk        := .T.
    cBd	       := Upper(AllTrim(TcGetDb()))
    nIndBind   := 1
    cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
    aInfEUF    := TAFTamEUF(Upper(AllTrim(FWSM0Util():GetSM0Data(,,{'M0_LEIAUTE'})[1][2])))

    cQuery += " SELECT "
	cQuery += "       V5I.V5I_IDREQ                                 V5I_IDREQ "
	cQuery += "     , V5W.V5W_IDREQ                                 V5W_IDREQ "
    cQuery += "     , V5W.V5W_ID                                    V5W_ID "
    cQuery += "     , COALESCE(V5W.V5W_EMISBX, V5I.V5I_EMISBX)      EMISBX "
    cQuery += "     , COALESCE(V5I.V5I_FILTIT, V5W.V5W_FILTIT)      FILIAL "
    cQuery += "     , COALESCE(V5I.V5I_PREFIX, V5W.V5W_PREFIX)      PREFIX "
    cQuery += "     , COALESCE(V5I.V5I_NUMERO, V5W.V5W_NUMERO)      NUMERO "
    cQuery += "     , COALESCE(V5I.V5I_NATTIT, V5W.V5W_NATTIT)      NATTIT "
    cQuery += "     , COALESCE(V5I.V5I_DTEMIS, V5W.V5W_DTEMIS)      DTEMIS "
    cQuery += "     , COALESCE(V5I.V5I_CODPAR, V5W.V5W_CODPAR)      CODPAR "
    cQuery += "     , CASE WHEN V5I.V5I_CODPAR IS NULL
    cQuery += "         THEN V5W.V5W_CPFCGC 
    cQuery += "         Else COALESCE(C1H.C1H_CNPJ,C1H.C1H_CPF) END CPFCGC "
    cQuery += "     , COALESCE(C1H.C1H_NOME, V5W.V5W_NOME)          NOME "
	cQuery += "     , V5I.V5I_VLBRUT                                VALERP "
	cQuery += "     , V5W.V5W_VLBRTA                                VALBRUTO "
	cQuery += "     , V5W.V5W_SEQUEN                                SEQUEN "
    cQuery += "     , V5I.V5I_ENVTAF                                ENVTAF "
    cQuery += "     , V58.V58_NATREN                                NATFIN "
    cQuery += "     , V44.V44_NATREN                                NATTAF "
    cQuery += "     , COALESCE(V58.V58_NATREN, V44.V44_NATREN)      NATREN "
	cQuery += "     , V44.V44_DECTER                                DECTER "
	cQuery += "     , V44.V44_VALOR                                 VALOR "
	cQuery += "     , V44.V44_VALIR                                 VALIR "
	cQuery += "     , V44.V44_VALPIS                                VALPIS "
	cQuery += "     , V44.V44_VALCOF                                VALCOFINS "
	cQuery += "     , V44.V44_VALCSL                                VALCSLL "
	cQuery += "     , V44.V44_VLAGRG                                VAGREG "
    cQuery += "     , COALESCE(V5W.V5W_ID,V5I.V5I_ID)               IDCOMP "

    cQuery += " FROM " + RetSqlName("V5I") + " V5I " 

    cQuery += " LEFT JOIN " + RetSqlName("V58") + " V58 ON V58.V58_FILIAL = V5I.V5I_FILIAL "
    cQuery += "     AND V58.V58_IDREQ = V5I.V5I_IDREQ "
    cQuery += "     AND V58.V58_IDV5I = V5I.V5I_ID "
    cQuery += "     AND V58.D_E_L_E_T_ = ? "

    cQuery += " FULL OUTER JOIN " + RetSqlName("V5W") + " V5W ON V5I.V5I_FILIAL = V5W.V5W_FILIAL "    
    cQuery += "     AND V5I.V5I_IDREQ  = V5W.V5W_IDREQ  "
    cQuery += "     AND V5I.V5I_FILTIT = V5W.V5W_FILTIT "
    cQuery += "     AND V5I.V5I_PREFIX = V5W.V5W_PREFIX "
    cQuery += "     AND V5I.V5I_NUMERO = V5W.V5W_NUMERO "
    cQuery += "     AND V5I.V5I_CODPAR = V5W.V5W_CODPAR "
    cQuery += "     AND V5I.V5I_SEQUEN = V5W.V5W_SEQUEN "
    cQuery += "     AND V5W.D_E_L_E_T_ = ? "

    cQuery += " LEFT JOIN " + RetSqlName("V44") + " V44 ON V44.V44_FILIAL = V5W.V5W_FILIAL  "
    cQuery += "     AND V44.V44_IDV5W = V5W.V5W_ID "
    cQuery += "     AND V44.D_E_L_E_T_ = ? "
    
    cQuery += " LEFT JOIN " + RetSqlName("C1H") + " C1H ON "
    
    If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. aInfEUF[1] + aInfEUF[2] == 0)
        cQuery += " C1H.C1H_FILIAL = ? "
    Else
       cQuery += FwJoinFilial("C1H", "V5I")
    EndIf

    cQuery += "     AND C1H.C1H_CODPAR = V5I.V5I_CODPAR "
    cQuery += "     AND C1H.D_E_L_E_T_ = ? "

    cQuery += " WHERE "

    cQuery += " (V5W_FILIAL = ? OR V5I_FILIAL = ?) AND "
	cQuery += " (V5I.V5I_IDREQ = ? OR V5W.V5W_IDREQ = ?) "

    cQuery += " ORDER BY "
    cQuery += "     FILIAL "
    cQuery += "     , PREFIX "
    cQuery += "     , NUMERO "
    cQuery += "     , CODPAR "
    cQuery += "     , SEQUEN "

    If !("DB2" $ cBd)
		cQuery := ChangeQuery(cQuery)
	EndIf
    
    oExecQry := FWPreparedStatement():new()
    oExecQry:SetQuery(cQuery)

    oExecQry:SetString(nIndBind++, space(1)) //V58.D_E_L_E_T_ =
    oExecQry:SetString(nIndBind++, space(1)) //V5W.D_E_L_E_T_ =
    oExecQry:SetString(nIndBind++, space(1)) //V44.D_E_L_E_T_ =
    If cCompC1H == "CCC" .or. (cCompC1H == "EEC" .and. aInfEUF[1] + aInfEUF[2] == 0)
        oExecQry:SetString(nIndBind++, xFilial("C1H")) //C1H.C1H_FILIAL = 
    EndIf
    oExecQry:SetString(nIndBind++, space(1)) //C1H.D_E_L_E_T_ =
    oExecQry:SetString(nIndBind++, cFilV3A)  //V5W_FILIAL =
    oExecQry:SetString(nIndBind++, cFilV3A)  //V5I_FILIAL =
    oExecQry:SetString(nIndBind++, cIDV3A)   //V5I.V5I_IDREQ =
    oExecQry:SetString(nIndBind++, cIDV3A)   //V5W.V5W_IDREQ =

    cQuery := oExecQry:GetFixQuery()
    cAliasFat := MPSysOpenQuery(cQuery)

    lOk := GravaV5W(oRequest, cAliasFat, cIDV3A)

    (cAliasFat)->(DbCloseArea())
    oExecQry:Destroy()

Return lOk

/*/{Protheus.doc} GravaV5W
@type        function
@description Grava V5W e V44.
@author      Carlos Pister
@since       06/08/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GravaV5W(oRequest, cAliasFat, cIDV3A)

    Local oInsertV5W as object
    Local oInsertV44 as object
    Local lOk        as logical
    Local MostraLink as logical
    Local cDivTaf    as character
    Local cExtERP    as character
    Local cExtTaf    as character
    Local cIdLog     as character
    Local cIdComp    as character
    Local cMsgDiv    as character
    Local cTipDiv    as character

    oInsertV5W := Nil
    oInsertV44 := Nil
    lOk        := .T.
    MostraLink := .F.
    cDivTaf	   := ''
    cExtERP	   := ''
    cExtTaf	   := ''
    cIdComp    := ''
    cMsgDiv    := ''
    cTipDiv    := ''
 
    If !(cAliasFat)->(EOF())        

        oInsertV5W := FwBulk():New(RetSQLName("V5W"))
        oInsertV5W:SetFields(V5W->(DbStruct()))

        oInsertV44 := FwBulk():New(RetSQLName("V44"))
        oInsertV44:SetFields(V44->(DbStruct()))

        While !(cAliasFat)->(EOF())

            cDivTaf	   := "2"
            cExtERP	   := "1"
            If oRequest['onlyTaf'] == 2
                cExtTaf := "2"
            Else
                cExtTaf := "1"
            EndIf
            cIdLog     := ""
            cTipDiv    := ""
            MostraLink := .F.                       
                
            //Registro não encontrado no ERP ou no TAF           
            If Empty((cAliasFat)->V5W_IDREQ) .and. oRequest['onlyTaf'] <> 2 //VerIfico se o registo esta no TAF
                cExtTaf := "2"

                If (cAliasFat)->ENVTAF == '1'
                    cDivTaf := "1"
                    cIdLog += "Documento não localizado no TAF. Favor verificar o erro de integração pelo Gerenciador de Integração (TAFTICKET).;"
                EndIf
            ElseIf Empty((cAliasFat)->V5I_IDREQ) .and. oRequest['onlyTaf'] <> 2 //VerIfico se o registo existe no financeiro
                cDivTaf := "1"
                cExtERP := "2"
                cIdLog += "Documento não localizado no Financeiro.;"
            ElseIf Empty((cAliasFat)->VALERP == (cAliasFat)->VALBRUTO) .and. oRequest['onlyTaf'] <> 2 //verIfico os valores divergentes
                cDivTaf := "1"
                cIdLog  += "O documento está com valores divergentes.;"
            EndIf    

            //VerIfico se a nat. rendimento ta preenchida
            If (Empty((cAliasFat)->NATREN) .or. Empty((cAliasFat)->NATFIN) .or. Empty((cAliasFat)->NATTAF)) .and. oRequest['onlyTaf'] <> 2 
                
                If Empty((cAliasFat)->NATREN) .and. cExtERP == '1' .and. cExtTaf == '1'
                    cDivTaf    := "1"
                    cIdLog     += "Natureza de rendimento não informada no documento Financeiro e TAF Fiscal.; "
                    MostraLink := .T.
                ElseIf Empty((cAliasFat)->NATFIN) .and. cExtERP == '1'
                    cIdLog     += "Natureza de rendimento não informada no documento do Financeiro.; "
                    cDivTaf    := "1"
                    MostraLink := .T.
                ElseIf Empty((cAliasFat)->NATTAF) .and. cExtTaf == '1'
                    cIdLog     += "Natureza de rendimento não informada no documento do TAF Fiscal.; "
                    cDivTaf    := "1"
                    MostraLink := .T.
                EndIf

                If MostraLink
                    cIdLog  += "Verificar configuração do título conforme documentação abaixo: "
                    cIdLog  += Chr(13) + Chr(10)
                    cIdLog  += "https://tdn.totvs.com/pages/releaseview.action?pageId=728637277;"
                EndIf         
            Else
                If ((cAliasFat)->NATFIN <> (cAliasFat)->NATTAF) .and. oRequest['onlyTaf'] <> 2
                    cDivTaf := "1"
                    cIdLog  += "Natureza de rendimento divergente entre os módulos: Financeiro " + (cAliasFat)->NATFIN + " e TAF " + (cAliasFat)->NATTAF + ".; "
                EndIf
            EndIf    

            If !Empty(cIdLog) 
                cMsgDiv := 'Alerta - Documento: ' + AllTrim((cAliasFat)->NUMERO) + ' ' + AllTrim((cAliasFat)->PREFIX) + ' ' + dToc(sTod((cAliasFat)->DTEMIS)) + ' ' + (cAliasFat)->CODPAR
                cMsgDiv +=  Chr(13) + Chr(10)  
                cIdLog  :=  cMsgDiv + cIdLog 
            EndIf

            If (oRequest['onlyDivergent'] == 1 .and. cDivTaf == "2") .and. oRequest['onlyTaf'] <> 2

                //Exclui o registro da V5W do alias
                oPrepDel := FWPreparedStatement():New()
		        cQuery := ''
		        cQuery += " DELETE FROM " + RetSqlName("V5W") + " WHERE "
		        cQuery += " V5W_FILIAL = ?"
		        cQuery += " AND V5W_IDREQ = ?"
                cQuery += " AND V5W_ID = ?"

                oPrepDel:SetQuery(cQuery)
                oPrepDel:SetString(1,cFilAnt)
                oPrepDel:SetString(2,cIDV3A)
                oPrepDel:SetString(3,(cAliasFat)->V5W_ID)

                cQuery := oPrepDel:getFixQuery()
		        lRet := TCSQLExec(cQuery) >= 0

                oPrepDel:Destroy()

                If lRet
                    oPrepDel := FWPreparedStatement():New()

		            cQuery := ''
		            cQuery += " DELETE FROM " + RetSqlName("V44") + " WHERE "
		            cQuery += " V44_FILIAL = ? "
		            cQuery += " AND V44_IDV5W = ? "

                    oPrepDel:SetQuery(cQuery)
                    oPrepDel:SetString(1,cFilAnt)
                    oPrepDel:SetString(2,(cAliasFat)->V5W_ID)

                    cQuery := oPrepDel:getFixQuery()

		            TCSQLExec(cQuery)

                    oPrepDel:Destroy()

	            EndIf

            Else
                If !(cIdComp == AllTrim((cAliasFat)->IDCOMP)) //verIfico se tem mais de um item para gravar na V44 com o mesmo IDV5W
                    
                    cIdComp := AllTrim((cAliasFat)->IDCOMP)
                    cIDV5W := TAFGeraID("TAFV5W")
                    oInsertV5W:AddData({xFilial("V5W"),;
                    cIDV3A,;
                    cIDV5W,;
                    (cAliasFat)->EMISBX,;
                    cDivTaf,;
                    cExtERP,;
                    cExtTaf,;
                    (cAliasFat)->FILIAL,;
                    AllTrim((cAliasFat)->PREFIX),;
                    AllTrim((cAliasFat)->NUMERO),;
                    AllTrim((cAliasFat)->NATTIT),;
                    (cAliasFat)->DTEMIS,;
                    AllTrim((cAliasFat)->CODPAR),;
                    AllTrim((cAliasFat)->CPFCGC),;
                    AllTrim((cAliasFat)->NOME),;
                    (cAliasFat)->VALERP,;
                    (cAliasFat)->VALBRUTO,;
                    AllTrim((cAliasFat)->SEQUEN),;
                    (cAliasFat)->ENVTAF,;
                    cIdLog;//Divergências encontradas
                    })
                EndIf

                If !Empty((cAliasFat)->NATREN) //Grava somente se tiver natureza de rendimento
                    oInsertV44:AddData({xFilial("V44"),; 
                    cIDV3A,;
                    cIDV5W,;
                    AllTrim((cAliasFat)->NATREN),;
                    AllTrim((cAliasFat)->DECTER),;
                    (cAliasFat)->VALOR,;
                    (cAliasFat)->VALIR,;
                    (cAliasFat)->VALPIS,;
                    (cAliasFat)->VALCOFINS,;
                    (cAliasFat)->VALCSLL,;
                    (cAliasFat)->VAGREG;
                    })
                EndIf

                If oRequest['onlyTaf'] <> 2
                
                    //Exclui o registro da V5W do alias
                    oPrepDel := FWPreparedStatement():New()

                    cQuery := ''
                    cQuery += " DELETE FROM " + RetSqlName("V5W") + " WHERE "
                    cQuery += " V5W_FILIAL = ? "
                    cQuery += " AND V5W_IDREQ = ? "
                    cQuery += " AND V5W_ID = ? "

                    oPrepDel:SetQuery(cQuery)
                    oPrepDel:SetString(1,cFilAnt)
                    oPrepDel:SetString(2,cIDV3A)
                    oPrepDel:SetString(3,(cAliasFat)->V5W_ID)

                    cQuery := oPrepDel:getFixQuery()

                    lRet := TCSQLExec(cQuery) >= 0
 
                    oPrepDel:Destroy()

                    If lRet

                        oPrepDel := FWPreparedStatement():New()
                        cQuery := ''
                        cQuery += " DELETE FROM " + RetSqlName("V44") + " WHERE "
                        cQuery += " V44_FILIAL = ? "
                        cQuery += " AND V44_IDV5W = ? "

                        oPrepDel:SetQuery(cQuery)
                        oPrepDel:SetString(1,cFilAnt)
                        oPrepDel:SetString(2,(cAliasFat)->V5W_ID)
                        
                        cQuery := oPrepDel:getFixQuery()

                        lRet := TCSQLExec(cQuery) >= 0

                        oPrepDel:Destroy()
                    EndIf
                EndIf
            EndIf                

            (cAliasFat)->(DbSkip())
        EndDo

        //Simulação de erro de gravação para caso de teste WSTAF06244
        If FWIsInCallStack('WSTAF06244')
            oInsertV5W:CERROR := 'Simula erro de gravação'
        EndIf
       
        If !Empty(oInsertV5W:GetError()) .or. !Empty(oInsertV44:GetError()) .or. !oInsertV5W:Flush() .or. !oInsertV44:Flush()    
            lOk := .F.
        EndIf
    EndIf

return lOk

/*/{Protheus.doc} Scheddef
@type        function
@description Busca um processamento na V3A
@author      Rafael de Paula Leme
@since       24/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function Scheddef()
Local aParam := {}

aParam := {'P', 'TAFRELFIN', '', {}, ''}

Return aParam

/*/{Protheus.doc} GravaV5WR
@type        function
@description Grava V5W e V44 temporario.
@author      Carlos Pister
@since       06/08/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GravaV5WR(cAliasFat, cIDV3A)

    Local cIDV5W    as character
    Local lRet      as logical
    Local cDecTer   as character
    Local nValor    as numeric
    Local nValIr    as numeric
    Local nValPis   as numeric
    Local nValCof   as numeric
    Local nValCsll  as numeric
    Local nValAgreg as numeric

    cIDV5W    := ''
    lRet      := .T.
    cDecTer   := ''
    nValor    := 0
    nValIr    := 0
    nValPis   := 0
    nValCof   := 0
    nValCsll  := 0
    nValAgreg := 0

    DBSelectArea("V5W")
    V5W->(DBSetOrder(2)) 

    DBSelectArea("V44")
    V44->(DBSetOrder(1))   

    While !(cAliasFat)->(EOF())
        lRet := .T.
        If V5W->(DbSeek(xFilial("V5W") + cIDV3A + (cAliasFat)->FILIAL + '1' + (cAliasFat)->PREFIX + (cAliasFat)->NUMERO))
            If Empty(V5W->V5W_SEQUEN) .and. AllTrim((cAliasFat)->CODPAR) == AllTrim(V5W->V5W_CODPAR)
                lRet := .F.
            Else
                cIDV5W := TAFGeraID("TAFV5W")
            EndIf
        Else    
            cIDV5W := TAFGeraID("TAFV5W")
        EndIf

        If lRet 
            Reclock("V5W", lRet)
            V5W->V5W_FILIAL := xFilial("V5W")
            V5W->V5W_IDREQ  := cIDV3A
            V5W->V5W_ID     := cIDV5W
            V5W->V5W_EMISBX := (cAliasFat)->EMISBX
            V5W->V5W_DIVERG := '1'
            V5W->V5W_ERP    := '2'
            V5W->V5W_TAF    := '1'
            V5W->V5W_FILTIT := (cAliasFat)->FILIAL
            V5W->V5W_PREFIX := (cAliasFat)->PREFIX
            V5W->V5W_NUMERO := (cAliasFat)->NUMERO
            V5W->V5W_NATTIT := (cAliasFat)->NATTIT
            V5W->V5W_DTEMIS := sTod((cAliasFat)->DTEMIS)
            V5W->V5W_CODPAR := (cAliasFat)->CODPAR
            V5W->V5W_CPFCGC := (cAliasFat)->CPFCGC
            V5W->V5W_NOME   := (cAliasFat)->NOME
            V5W->V5W_VLBRER := 0
            V5W->V5W_VLBRTA := (cAliasFat)->VALBRUTO
            V5W->V5W_SEQUEN := (cAliasFat)->SEQUEN
            V5W->( MsUnlock() )
        Else
            Reclock("V5W", lRet)
            V5W->V5W_EMISBX := (cAliasFat)->EMISBX
            V5W->V5W_DTEMIS := sTod((cAliasFat)->DTEMIS)
            V5W->V5W_VLBRER := 0
            V5W->V5W_VLBRTA := (cAliasFat)->VALBRUTO
            V5W->V5W_SEQUEN := (cAliasFat)->SEQUEN
            V5W->( MsUnlock() )
        EndIf

        If !Empty((cAliasFat)->NATREN)
            lGrava := .T.
            If V44->(DbSeek(xFilial("V44") + cIDV3A + V5W->V5W_ID + (cAliasFat)->NATREN))
                lGrava := .F.
            EndIf 

            If Empty((cAliasFat)->DECTER)
                cDecTer := V44->V44_DECTER
            Else
                cDecTer := (cAliasFat)->DECTER
            EndIf

            If Empty((cAliasFat)->VALOR)
                nValor := V44->V44_VALOR
            Else
                nValor := (cAliasFat)->VALOR
            EndIf

            If Empty((cAliasFat)->VALIR)
                nValIr := V44->V44_VALIR
            Else
                nValIr := (cAliasFat)->VALIR
            EndIf

            If Empty((cAliasFat)->VALPIS)
                nValPis := V44->V44_VALPIS
            Else
                nValPis := (cAliasFat)->VALPIS
            EndIf

            If Empty((cAliasFat)->VALCOFINS)
                nValCof := V44->V44_VALCOF
            Else
                nValCof := (cAliasFat)->VALCOFINS
            EndIf

            If Empty((cAliasFat)->VALCSLL)
                nValCsll := V44->V44_VALCSL
            Else
                nValCsll := (cAliasFat)->VALCSLL
            EndIf

            If Empty((cAliasFat)->VAGREG)
                nValAgreg := V44->V44_VLAGRG
            Else
                nValAgreg := (cAliasFat)->VAGREG
            EndIf

            Reclock("V44", lGrava)        
                V44->V44_FILIAL := xFilial("V44")
                V44->V44_IDREQ  := cIDV3A
                V44->V44_IDV5W  := V5W->V5W_ID
                V44->V44_NATREN := (cAliasFat)->NATREN
                V44->V44_DECTER := cDecTer
                V44->V44_VALOR  := nValor
                V44->V44_VALIR  := nValIr
                V44->V44_VALPIS := nValPis
                V44->V44_VALCOF := nValCof
                V44->V44_VALCSL := nValCsll
                V44->V44_VLAGRG := nValAgreg
            V44->( MsUnlock() )
        EndIf

        (cAliasFat)->(DbSkip())
    EndDo
Return
