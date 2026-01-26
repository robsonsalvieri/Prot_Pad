#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE PRECAD  1,1
Static __lApurBx
//-------------------------------------------------------------------
/*/{Protheus.doc} WS002PRECAD

@description Retorna o json com as filiais pendentes de apuração dos eventos R-2030 e R-2040
@author Katielly Rezende 
@since 24/02/2020
@version 1.0
@return Retorna a estrutura da mensagem do json

/*/ 
//-------------------------------------------------------------------
function WS002PRECAD(aApurac, oEstruct, cEvent, oValidationError)

    local cNrInsc		as character
    local cBranch		as character
    local cCompany		as character
    local cCompAux		as character
    local cStatus		as character
    local nTSintetic    as numeric
    local lNewBranch	as logical
    local aSM0          as array

    default oValidationError["registryKey"] = {}

    cNrInsc		:= ""
    cBranch		:= ""
    cCompany	:= ""
    cCompAux    := ""
    cStatus     := ""
    nTSintetic  := 0
    aSM0        := {}
    SetalApurBx()

    while !(aApurac[PRECAD])->(eof())

        aSM0 := FWSM0Util():GetSM0Data( SM0->M0_CODIGO , (aApurac[PRECAD])->FILIAL , { "M0_FILIAL", "M0_NOMECOM" , "M0_CGC" } )
        cBranch     := aSM0[1][2]
        cCompany    := aSM0[2][2]
        cNrInsc     := aSM0[3][2]
        lNewBranch  := cNrInsc <> cCompAux

        if lNewBranch
            cStatus := ""

            aadd(oEstruct["eventDetail"],JsonObject():New())
            nTSintetic := len(oEstruct["eventDetail"])

            // Código da Filial
            oEstruct["eventDetail"][nTSintetic]["branchId"]             := (aApurac[PRECAD])->FILIAL

            // Nome da Filial
            oEstruct["eventDetail"][nTSintetic]["branch"]               := alltrim(EncodeUTF8(cBranch))

            // CNPJ
            oEstruct["eventDetail"][nTSintetic]["branchTaxNumber"]      := cNrInsc

            // Razão Social
            oEstruct["eventDetail"][nTSintetic]["company"]              := alltrim(EncodeUTF8(cCompany))

            // Total bruto
            
            oEstruct["eventDetail"][nTSintetic]["totalGrossValue"]      := IIf(__lApurBx,(aApurac[PRECAD])->VLPGTO,(aApurac[PRECAD])->VLRBRUTO)


            // Chave de registro
            oEstruct["eventDetail"][nTSintetic]["key"]                  := (aApurac[PRECAD])->FILIAL

            // Status
            if Empty(cStatus) .or. cStatus == 'validated'
                cStatus := Iif(Empty((aApurac[PRECAD])->STATUS), 'notValidated', 'validated')
            endIf

            oEstruct["eventDetail"][nTSintetic]["status"]               := cStatus

            //Propriedade errors que habilita o icone no frontend
            oEstruct["eventDetail"][nTSintetic]["errors"]               := 'errors'

            If Len(oValidationError["registryKey"]) > 0
                // Chave de busca do erro da apuração
                oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"]  := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
            EndIf
        else
            // Total bruto
            oEstruct["eventDetail"][nTSintetic]["totalGrossValue"]      += IIf(__lApurBx,(aApurac[PRECAD])->VLPGTO,(aApurac[PRECAD])->VLRBRUTO)

            // Status
            if Empty(cStatus) .or. cStatus == 'validated'
                cStatus := Iif(Empty((aApurac[PRECAD])->STATUS), 'notValidated', 'validated')
            endIf

            oEstruct["eventDetail"][nTSintetic]["status"]               := cStatus

            //Propriedade errors que habilita o icone no frontend
            oEstruct["eventDetail"][nTSintetic]["errors"]               := 'errors'

            If Len(oValidationError["registryKey"]) > 0
                // Chave de busca do erro da apuração
                oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"]  := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
            EndIf

        endIf

        cCompAux := cNrInsc

        (aApurac[PRECAD])->(dbSkip())

    endDo

return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WS002DPRECAD

@description Retorna o json com a os participantes pendentes de apuração 
@author Katielly Rezende 
@since 24/02/2020
@version 1.0
@return Retorna a estrutura da mensagem do json

/*/ 
//-------------------------------------------------------------------
function WS002DPRECAD(aApurac, oEstruct, cEvent)

    Local cCNPJAux    as character
    Local cCNPJ       as character
    Local cPartEx     as character
    Local lNewPartic  as Logical
    Local nProp       as Numeric  
    Local nVlrBruto   as Numeric  
    Local nVlrImposto as Numeric  

    cCNPJAux    := ""
    cCNPJ       := ""
    cPartEx     := ""
    SetalApurBx()

    while !(aApurac[PRECAD])->(eof())

        If cEvent == "R-2030"
            cCNPJ := (aApurac[PRECAD])->CNPJORIREC
            If TAFColumnPos("V1G_IDEXTE")
                If cCNPJ <> ' '
                    lNewPartic := cCNPJ <> cCNPJAux
                Else
                    lNewPartic := (aApurac[PRECAD])->CODPAR <> cPartEx
                EndIf
            Else
                lNewPartic  := cCNPJ <> cCNPJAux
            EndIf
        Else
            cCNPJ      := (aApurac[PRECAD])->CNPJASDESP
            lNewPartic := cCNPJ <> cCNPJAux
        EndIf    
        
        nProp := 1
        
        If __lApurBx
            nProp :=  TafCalProp((aApurac[PRECAD])->VLRBRUTO,  (aApurac[PRECAD])->VLPGTO) 
            nVlrBruto	:= (aApurac[PRECAD])->VLPGTO
            nVlrImposto := Round((aApurac[PRECAD])->TOTTRIB * nProp, 2)
        Else
            nVlrBruto	:= (aApurac[PRECAD])->VLRBRUTO
            nVlrImposto := (aApurac[PRECAD])->TOTTRIB	
        EndIf        

        if lNewPartic
            aAdd( oEstruct["invoices"],JsonObject():New())
            nTAnalytic   :=  len(oEstruct["invoices"])

            // Código da Filial
            oEstruct["invoices"][nTAnalytic]["branchId"]             :=  (aApurac[PRECAD])->FILIAL

            if cEvent == "R-2030"
                // CNPJ Origem do recurso
                oEstruct["invoices"][nTAnalytic]["sourceTaxNumber"]         := cCNPJ
            else
                // CNPJ da Associação Desportiva
                oEstruct["invoices"][nTAnalytic]["associationTaxNumber"]    := cCNPJ
            endIf

            // Razão Social
            oEstruct["invoices"][nTAnalytic]["company"]              := alltrim(EncodeUTF8((aApurac[PRECAD])->RAZAOSOCIAL))

            if cEvent == "R-2030"
                oEstruct["invoices"][nTAnalytic]["providerCode"]            := alltrim((aApurac[PRECAD])->CODPAR)
            endif

            // Total de documentos
            oEstruct["invoices"][nTAnalytic]["totalInvoice"]         := (aApurac[PRECAD])->QTDDOC

            // Total de repasse
            oEstruct["invoices"][nTAnalytic]["totalTransferAmount"]  := IIf(__lApurBx,nVlrImposto,(aApurac[PRECAD])->VLRREPASSE)

            // Total bruto
            oEstruct["invoices"][nTAnalytic]["totalGrossValue"]      := nVlrBruto

            // Total base de cálculo
            oEstruct["invoices"][nTAnalytic]["totalTaxBase"]         := IIf(__lApurBx,(aApurac[PRECAD])->VLPGTO,(aApurac[PRECAD])->TOTBASCALC)

            // Total de tributo
            oEstruct["invoices"][nTAnalytic]["totalTaxes"]           := nVlrImposto 

            // Chave de registro
            oEstruct["invoices"][nTAnalytic]["invoiceKey"]           := cCNPJ
        else
            // Total de repasse
            oEstruct["invoices"][nTAnalytic]["totalTransferAmount"]  += IIf(__lApurBx,nVlrImposto,(aApurac[PRECAD])->VLRREPASSE)

            // Total bruto
            oEstruct["invoices"][nTAnalytic]["totalGrossValue"]      += nVlrBruto

            // Total base de cálculo
            oEstruct["invoices"][nTAnalytic]["totalTaxBase"]         += IIf(__lApurBx,(aApurac[PRECAD])->VLPGTO,(aApurac[PRECAD])->TOTBASCALC)

            // Total de tributo
            oEstruct["invoices"][nTAnalytic]["totalTaxes"]           += nVlrImposto

            // Total de documentos
            oEstruct["invoices"][nTAnalytic]["totalInvoice"]         += (aApurac[PRECAD])->QTDDOC
        endIf

        cCNPJAux := cCNPJ
        cPartEx  := (aApurac[PRECAD])->CODPAR

        (aApurac[PRECAD])->(dbSkip())
    endDo

return oEstruct

/*/{Protheus.doc} RETTIPO
    Retorna o tipo de repasse.
    @type  Static Function
    @author José Mauro
    @since 27/07/2020
    @version version
    @param 
        cTipo - Valor do tipo de repasse.
    @return 
        aTipoRet[VAL(cTipo)] - Posição do array referente ao valor do repasse informado.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETTIPO(cTipo)
    Local aTipoRet as array

    aTipoRet := {}

    AADD(aTipoRet, "1 - Patrocínio")
    AADD(aTipoRet, "2 - Licenciamento de marcas e símbolos")
    AADD(aTipoRet, "3 - Publicidade")
    AADD(aTipoRet, "4 - Propaganda")
    AADD(aTipoRet, "5 - Transmissão de espetáculos")

Return aTipoRet[VAL(cTipo)]
//-------------------------------------------------------------------
/*/{Protheus.doc} WS002SPRECAD

@description Retorna o json com as notas e faturas pendentes de apuração
@author Katielly Rezende 
@since 24/02/2020
@version 1.0
@return Retorna a estrutura da mensagem do json

/*/ 
//-------------------------------------------------------------------
Function WS002SPRECAD(aApurac, oEstruct)

    local cTiporep      as character
    local nTAnalytic    as numeric
    
    local nProp         as numeric
    local nVlrBruto     as numeric
    local nVlrImposto   as numeric
    local dDtDoc        as Date

    cTiporep    := ""
    nTAnalytic  := 0
    SetalApurBx()

    (aApurac[PRECAD])->(dbGoTop())

    While !(aApurac[PRECAD])->(eof())

        cTiporep := RETTIPO((aApurac[PRECAD])->TPREPASSE)
        nProp       := 1
        If __lApurBx
            nProp :=  TafCalProp((aApurac[PRECAD])->VLRBRUTO,  (aApurac[PRECAD])->VLPGTO) 
            nVlrBruto	:= (aApurac[PRECAD])->VLPGTO
            nVlrImposto := Round((aApurac[PRECAD])->TOTTRIB * nProp, 2)
            dDtDoc      := SToD((aApurac[PRECAD])->DTPGTO)
        Else
            nVlrBruto	:= (aApurac[PRECAD])->VLRBRUTO
            nVlrImposto := (aApurac[PRECAD])->TOTTRIB
            dDtDoc      := SToD((aApurac[PRECAD])->DTEMISSAONF)
        EndIf        
        aAdd( oEstruct["tax"],JsonObject():New())
        nTAnalytic   :=  len(oEstruct["tax"])

        // Tipo de documento
        oEstruct["tax"][nTAnalytic]["type"]                  :=  (aApurac[PRECAD])->TIPODOC

        //Num. doc
        oEstruct["tax"][nTAnalytic]["invoice"]               :=  alltrim((aApurac[PRECAD])->NUMDOCTO)

        // Série
        oEstruct["tax"][nTAnalytic]["invoiceSeries"]         :=  alltrim((aApurac[PRECAD])->SERIE)

        // Item
        oEstruct["tax"][nTAnalytic]["item"]                  :=  (aApurac[PRECAD])->ITEMDOC

        // Tipo de repasse
        oEstruct["tax"][nTAnalytic]["typeOfTransfer"]        :=  alltrim(EncodeUTF8(cTiporep))

        // Data de emissão
        oEstruct["tax"][nTAnalytic]["issueDate"]             :=  dDtDoc

        // Valor bruto
        oEstruct["tax"][nTAnalytic]["grossValue"]            :=  nVlrBruto

        // Base de Cálculo
        oEstruct["tax"][nTAnalytic]["taxBase"]               :=  Iif(__lApurBx,(aApurac[PRECAD])->VLPGTO,(aApurac[PRECAD])->TOTBASCALC)

        // Alíquota
        oEstruct["tax"][nTAnalytic]["aliquot"]               :=  (aApurac[PRECAD])->ALIQ

        // Tributo
        oEstruct["tax"][nTAnalytic]["tax"]                   :=  nVlrImposto

        (aApurac[PRECAD])->(DbSkip())
    EndDo

return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQryPreCa

@description Retorna os documentos pendentes de apuração
@author Katielly Rezende 
@since 26/01/2020
@version 1.0
@return Retorna o alias para consulta das informações
/*/ 
//-------------------------------------------------------------------
function WSQryPreCa(cPeriodo, aFil, nView, cKey, cEvent, cCodPart)

    local cAlPreCad as character
    local cBd		as Character
    Local cCompC1H	as Character
    local cFiliais  as character
    local cQuery    as character
    local aRet      as array
    local aInfoEUF	as array
    

    cAlPreCad   := getNextAlias()
    cBd			:= TcGetDb()
    cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
    cFiliais	:= RetFil(aFil)
    cQuery      := ""
    aRet        := {}
    aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
    SetalApurBx()

    If !__lApurBx
        if nView == 1
            cQuery	+= " C20.C20_FILIAL AS FILIAL, "
            cQuery	+= " SUM(C30.C30_TOTAL) AS VLRBRUTO, "
            cQuery	+= " CASE "
            cQuery	+= " WHEN C20.C20_PROCID <> ' ' THEN '3' "
            cQuery	+= " WHEN C20.C20_PROCID = ' ' THEN ' ' "
            cQuery	+= " END AS STATUS "
        elseIf nView == 2
            cQuery	+= " C20.C20_FILIAL AS FILIAL, "
            cQuery	+= " COUNT(*) AS QTDDOC, "

            if cEvent == "R-2030"
                cQuery	+= " C1H.C1H_CNPJ AS CNPJORIREC, "
            else
                cQuery	+= " C1H.C1H_CNPJ AS CNPJASDESP, "
            endIf
            
            cQuery	+= " C1H.C1H_CODPAR AS CODPAR, "
            cQuery	+= " C1H.C1H_NOME AS RAZAOSOCIAL, "
            cQuery	+= " SUM(C35.C35_VALOR) AS VLRREPASSE, "
            cQuery	+= " SUM(C30.C30_TOTAL) AS VLRBRUTO, "
            cQuery	+= " SUM(C35.C35_BASE) AS TOTBASCALC, "
            cQuery	+= " SUM(C35.C35_VALOR) AS TOTTRIB "
        elseIf nView == 3
            cQuery	+= " 'NFS' AS TIPODOC, "
            cQuery	+= " C20.C20_NUMDOC AS NUMDOCTO, "
            cQuery	+= " C20.C20_SERIE AS SERIE, "
            cQuery	+= " C30.C30_NUMITE AS ITEMDOC, "
            cQuery	+= " C30.C30_TPREPA AS TPREPASSE, "
            cQuery	+= " C20.C20_DTDOC AS DTEMISSAONF, "
            cQuery	+= " C30.C30_TOTAL AS VLRBRUTO, "
            cQuery	+= " C35.C35_BASE AS TOTBASCALC, "
            cQuery	+= " C35.C35_VALOR AS TOTTRIB, "
            cQuery	+= " C35.C35_ALIQ AS ALIQ "
        endIf

        cQuery	+= " FROM " + RetSqlName("C20") + " C20 "
        cQuery	+= " INNER JOIN " + RetSqlName("C30") + " C30 ON "
        cQuery	+= " C20.C20_FILIAL = C30.C30_FILIAL "
        cQuery	+= " AND C20.C20_CHVNF = C30.C30_CHVNF "
        cQuery	+= " AND C30.D_E_L_E_T_ = ' ' "
        cQuery	+= " INNER JOIN " + RetSqlName("C35") + " C35 ON "
        cQuery	+= " C30.C30_FILIAL = C35.C35_FILIAL "
        cQuery	+= " AND C30.C30_CHVNF = C35.C35_CHVNF "
        cQuery	+= " AND C30.C30_NUMITE = C35.C35_NUMITE "
        cQuery	+= " AND C35.D_E_L_E_T_ = ' ' "

        cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
        cQuery	+= " C1H.C1H_ID = C20.C20_CODPAR "

        if cEvent == "R-2040"
            cQuery 	+= " AND C1H.C1H_INDDES = '1'"
        endIf

        if cCompC1H == "EEE"
            cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "
        else
            if cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
                cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
            elseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
                cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
            endIf
        endIf

        cQuery	+= " AND C1H.D_E_L_E_T_ = ' ' "

        cQuery	+= " WHERE	"
        cQuery	+= " C20.C20_FILIAL IN ( " + cFiliais + " )"

        If cEvent == "R-2030"
            cQuery	+= " AND C20.C20_INDOPE = '1' "
        Else
            cQuery	+= " AND C20.C20_INDOPE = '0' "
        EndIf

        if cBd $ "ORACLE|POSTGRES|DB2"
            cQuery	+=  " AND SUBSTR(C20.C20_DTDOC,1,6) = '"+ cPeriodo +"'"

        elseIf cBd $ "INFORMIX"
            cQuery	+=  " AND C20.C20_DTDOC[1,6] = '"+ cPeriodo +"'"

        else
            cQuery	+=  " AND SUBSTRING(C20.C20_DTDOC,1,6) = '"+ cPeriodo +"'"
        endIf

        cQuery	+= " AND C30.C30_TPREPA <> '' "
        cQuery	+= " AND C35.C35_CODTRI = '000013' "
        
        If cEvent == "R-2030"
            cQuery	+= " AND C1H.C1H_PPES IN ('2','3') "
            cQuery	+= " AND (C1H.C1H_CNPJ <> '' OR (C1H.C1H_CNPJ = ' ' AND C1H.C1H_PAISEX <> ' ' AND C1H.C1H_PEEXTE = '2')) "
        Else
            cQuery	+= " AND C1H.C1H_PPES = '2' "
            cQuery	+= " AND C1H.C1H_CNPJ <> '' "
        EndIf

        if nView == 3 .and. !empty(cKey)
            cQuery	+= " AND C1H.C1H_CNPJ = '" + cKey + "' "
        elseif nView == 3 .and. empty(cKey) .and. !empty(cCodPart) .and. cEvent == "R-2030" 
            cQuery += " AND C1H.C1H_CODPAR = '" + AllTrim(cCodPart) + "' "
        endif

        cQuery	+= " AND C20.D_E_L_E_T_ = ' ' "

        if nView == 1
            cQuery	+= " GROUP BY C20_FILIAL, C20_PROCID "
        elseIf nView == 2
            cQuery	+= " GROUP BY C20_FILIAL, C1H_CNPJ, C1H_NOME, C1H_PAISEX, C1H_CODPAR, C1H_PEEXTE "
        endIf

        cQuery	+= " UNION ALL "

        cQuery	+= " SELECT "
    EndIf
    
    if nView == 1
        cQuery	+= " LEM.LEM_FILIAL AS FILIAL, "
        cQuery	+= " SUM(T5M.T5M_VLBRUT) AS VLRBRUTO, "
        cQuery	+= " CASE "
        If __lApurBx
            cQuery	+= " WHEN T5P.T5P_PROCID <> ' ' THEN '3' "
            cQuery	+= " WHEN T5P.T5P_PROCID = ' ' THEN ' ' "
        Else
            cQuery	+= " WHEN LEM.LEM_PROCID <> ' ' THEN '3' "
            cQuery	+= " WHEN LEM.LEM_PROCID = ' ' THEN ' ' "
        EndIf
        cQuery	+= " END AS STATUS "    

    elseIf nView == 2
        cQuery	+= " LEM.LEM_FILIAL AS FILIAL, "
        cQuery	+= " COUNT(*) AS QTDDOC, "
        
        if cEvent == "R-2030"
            cQuery	+= " C1H.C1H_CNPJ AS CNPJORIREC, "
        else
            cQuery	+= " C1H.C1H_CNPJ AS CNPJASDESP, "
        endIf

        cQuery	+= " C1H.C1H_CODPAR AS CODPAR, "
        cQuery	+= " C1H.C1H_NOME AS RAZAOSOCIAL, "
        cQuery	+= " SUM(T5M.T5M_VLREAP) AS VLRREPASSE, "
        cQuery	+= " SUM(T5M.T5M_VLBRUT) AS VLRBRUTO, "
        cQuery	+= " SUM(T5M.T5M_BSINSS) AS TOTBASCALC, "
        cQuery	+= " SUM(T5M.T5M_VLREAP) AS TOTTRIB "
    elseIf nView == 3
        cQuery	+= " 'FAT' AS TIPODOC, "
        cQuery	+= " LEM.LEM_NUMERO AS NUMDOCTO, "
        cQuery	+= " LEM.LEM_PREFIX AS SERIE, "
        cQuery	+= " '' AS ITEMDOC, "
        cQuery	+= " T5M.T5M_TPREPA AS TPREPASSE, "
        cQuery	+= " LEM.LEM_DTEMIS AS DTEMISSAONF, "
        cQuery	+= " T5M.T5M_VLBRUT AS VLRBRUTO, "
        cQuery	+= " T5M.T5M_BSINSS AS TOTBASCALC, "
        cQuery	+= " T5M.T5M_VLREAP AS TOTTRIB, "
        cQuery	+= " 0 AS ALIQ "
    endIf
    If __lApurBx 
        if nView == 1 .or. nView == 2
            cQuery	+= ", SUM(T5P.T5P_VLPGTO) AS VLPGTO "
        Else
            cQuery	+= ", T5P.T5P_VLPGTO AS VLPGTO, T5P.T5P_DTPGTO AS DTPGTO "
        EndIf
    EndIf

    cQuery	+= " FROM " + RetSqlName("LEM") + " LEM "
    cQuery	+= " INNER JOIN " + RetSqlName("T5M") + " T5M ON "
    cQuery	+= " LEM.LEM_FILIAL = T5M.T5M_FILIAL "
    cQuery	+= " AND T5M.D_E_L_E_T_ = ' ' "
    cQuery	+= " AND T5M.T5M_ID = LEM.LEM_ID "
    cQuery	+= " AND T5M.T5M_IDPART = LEM.LEM_IDPART "

	If __lApurBx 
		cQuery	+= " INNER JOIN " + RetSqlName("T5P") + " T5P ON LEM.LEM_FILIAL = T5P.T5P_FILIAL AND T5P.D_E_L_E_T_ = ' ' AND T5P.T5P_ID = LEM.LEM_ID AND  "
		cQuery	+= " T5P.T5P_IDPART = LEM.LEM_IDPART "
	EndIf

    cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
    cQuery	+= " C1H.C1H_ID = LEM.LEM_IDPART "

    if cEvent == "R-2040"
        cQuery 	+= " AND C1H.C1H_INDDES = '1'"
    endIf

    if cCompC1H == "EEE"
        cQuery += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "
    else
        if cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
        elseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
        endIf
    endIf

    cQuery	+= " AND C1H.D_E_L_E_T_ = ' ' "
    cQuery	+= " WHERE "
    cQuery	+= " LEM.LEM_FILIAL IN (" + cFiliais + ") "

    if cEvent == "R-2030"
        cQuery	+= " AND LEM.LEM_NATTIT = '1' "
    else
        cQuery	+= " AND LEM.LEM_NATTIT = '0' "
    endIf

	if __lApurBx
		if cBd $ "ORACLE|POSTGRES|DB2"
			cQuery	+=  " AND SUBSTR(T5P.T5P_DTPGTO,1,6) = '"+ cPeriodo +"'"
				
		elseIf cBd $ "INFORMIX"
			cQuery	+=  " AND T5P.T5P_DTPGTO[1,6] = '"+ cPeriodo +"'"
		
		else
			cQuery	+=  " AND SUBSTRING(T5P.T5P_DTPGTO,1,6) = '"+ cPeriodo +"'"
		endIf
	else
        if cBd $ "ORACLE|POSTGRES|DB2"
            cQuery	+=  " AND SUBSTR(LEM.LEM_DTEMIS,1,6) = '"+ cPeriodo +"'"

        elseIf cBd $ "INFORMIX"
            cQuery	+=  " AND LEM.LEM_DTEMIS[1,6] = '"+ cPeriodo +"'"

        else
            cQuery	+=  " AND SUBSTRING(LEM.LEM_DTEMIS,1,6) = '"+ cPeriodo +"'"
        endIf
    endIf
    cQuery	+= " AND T5M.T5M_TPREPA <> '' "

    If cEvent == "R-2030"
        cQuery	+= " AND C1H.C1H_PPES IN ('2','3') "
        cQuery	+= " AND (C1H.C1H_CNPJ <> '' OR (C1H.C1H_CNPJ = ' ' AND C1H.C1H_PAISEX <> ' ' AND C1H.C1H_PEEXTE = '2')) "
    Else
        cQuery	+= " AND C1H.C1H_PPES = '2' "
        cQuery	+= " AND C1H.C1H_CNPJ <> '' "
    EndIf

    if nView == 3 .and. !empty(cKey)
        cQuery	+= " AND C1H.C1H_CNPJ = '" + cKey + "' "
    elseif nView == 3 .and. empty(cKey) .and. !empty(cCodPart) .and. cEvent == "R-2030" 
        cQuery += " AND C1H.C1H_CODPAR = '" + AllTrim(cCodPart) + "' "
    endif

    cQuery	+= " AND LEM.D_E_L_E_T_ = ' ' "

    if nView == 1
        cQuery	+= " GROUP BY LEM_FILIAL, "
        if __lApurBx
            cQuery	+= " T5P_PROCID "
        else
            cQuery	+= " LEM_PROCID "
        endIf
    elseIf nView == 2
        cQuery	+= " GROUP BY LEM_FILIAL, C1H_CNPJ, C1H_NOME, C1H_PAISEX, C1H_CODPAR, C1H_PEEXTE "
    endIf

    if nView = 2
        cQuery	+= "ORDER BY 3, 4 "
    else
        cQuery	+= "ORDER BY 1, 2 "
    endIf

    cQuery	:= "%" + cQuery + "%"

    beginSql alias cAlPreCad
        SELECT 
            %exp:cQuery%
    endSql

    aAdd(aRet, { cAlPreCad })

return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

@description Trata o array de filiais passado pela tela da apuração
@description para que fique no formato de execução do IN no SQL
@author Katielly Rezende 
@since 24/02/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function RetFil(aFil)
    Local cRetFils	as Character
    Local nX		as Numeric

    cRetFils	:= ""
    nX			:= 0

    For nX := 1 to Len(aFil)
        if nX > 1
            cRetFils += " , '" + aFil[nX][2] + "'"
        else
            cRetFils += "'" + aFil[nX][2] + "'"
        endIf
    Next nX

Return cRetFils


//-------------------------------------------------------------------
/*/{Protheus.doc} WSQryPreCa

@description Retorna os documentos pendentes de apuração
@author José Mauro
@since 28/07/2020
@version 1.0
@return Retorna as colunas necessárias para montagem do excel na exportação através do PO-UI
/*/ 
//-------------------------------------------------------------------
Function WSRETREL(cPeriodo,cEvent,aFil)

Local cAlPreCad as character
Local cBd		as Character
Local cCompC1H	as Character
Local cCompC1G	as Character
Local cFiliais  as character
Local cQuery    as character
Local aInfoEUF	as array

cAlPreCad   := getNextAlias()
cBd			:= TcGetDb()
cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cCompC1G	:= Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3)))
cFiliais	:= RetFil(aFil)
cQuery      := ""
aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

SetalApurBx()

if !__lApurBx
    cQuery	+= " 'Nota Fiscal' AS TIPODOC               ,"
    cQuery	+= " C20_FILIAL AS FILIAL           ,"
    cQuery	+= " C1H_CNPJ AS CNPJ               ,"
    cQuery	+= " C1H_NOME AS NOME               ,"
    cQuery	+= " C20.C20_NUMDOC AS NUMDOCTO     ,"
    cQuery	+= " C20.C20_CHVNF AS CHAVE         ,"
    cQuery	+= " C20.C20_SERIE AS SERIE         ,"
    cQuery	+= " C1L.C1L_CODIGO AS CODITEM      ,"
    cQuery	+= " C1L.C1L_DESCRI AS DESCITEM     ,"
    cQuery	+= " C30.C30_TPREPA AS TPREPASSE    ,"
    cQuery	+= " C20.C20_DTDOC AS DTEMISSAONF   ,"
    cQuery	+= " C30.C30_TOTAL AS VLRBRUTO      ,"
    cQuery	+= " C35.C35_VALOR AS TOTTRIB       ,"
    cQuery	+= " C1G.C1G_NUMPRO AS PROCESSO     ,"
    cQuery	+= " C1G.C1G_TPPROC AS TIPOPROC     ,"
    cQuery	+= " C1G.C1G_DESCRI AS DESCPROC     ,"
    cQuery	+= " T9Q.T9Q_VALSUS AS VLRNRET       "

    cQuery	+= " FROM " + RetSqlName("C20") + " C20 "
    cQuery	+= " INNER JOIN " + RetSqlName("C30") + " C30 ON "
    cQuery	+= " C20.C20_FILIAL = C30.C30_FILIAL "
    cQuery	+= " AND C20.C20_CHVNF = C30.C30_CHVNF "
    cQuery	+= " AND C30.D_E_L_E_T_ = ' ' "
    cQuery	+= " LEFT JOIN " + RetSqlName("T9Q") + " T9Q  "
    cQuery	+= " ON T9Q.T9Q_FILIAL = C30.C30_FILIAL "
    cQuery	+= " AND T9Q_CHVNF = C30.C30_CHVNF "
    cQuery	+= " AND T9Q.D_E_L_E_T_ = ' ' "
    cQuery	+= " INNER JOIN " + RetSqlName("C35") + " C35 ON "
    cQuery	+= " C30.C30_FILIAL = C35.C35_FILIAL "
    cQuery	+= " AND C30.C30_CHVNF = C35.C35_CHVNF "
    cQuery	+= " AND C30.C30_NUMITE = C35.C35_NUMITE "
    cQuery	+= " AND C35.D_E_L_E_T_ = ' ' "
    cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
    cQuery	+= " C1H.C1H_ID = C20.C20_CODPAR "

    If cEvent == "R-2040"
        cQuery 	+= " AND C1H.C1H_INDDES = '1'"
    EndIf

    If cCompC1H == "EEE"
        cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "
    Else
        If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
        ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
        EndIf
    EndIf

    cQuery	+= " AND C1H.D_E_L_E_T_ = ' ' "

    cQuery	+= " LEFT JOIN                             "
    cQuery	+=   RetSqlName("C1L") + " C1L "           "
    cQuery	+= " ON C30.C30_FILIAL = C1L.C1L_FILIAL    "
    cQuery	+= " AND C30.C30_CODITE = C1L.C1L_ID       "
    cQuery	+= " AND  C1L.D_E_L_E_T_ = ' '             "
    cQuery	+= " LEFT JOIN                             "
    cQuery	+=   RetSqlName("C1G") + " C1G "           "
    If cCompC1G == "EEE"
        cQuery += "ON T9Q.T9Q_FILIAL = C1G.C1G_FILIAL "
    Else
        If cCompC1G == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cQuery += "ON SUBSTRING(T9Q.T9Q_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C1G.C1G_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
        ElseIf cCompC1G == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
            cQuery += "ON SUBSTRING(T9Q.T9Q_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C1G.C1G_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
        ElseIf cCompC1G == "CCC"
            cQuery += "ON C1G.C1G_FILIAL = '" + xFilial('C1G') + "'"
        EndIf
    EndIf

    cQuery	+= " AND C1G.C1G_ID = T9Q.T9Q_NUMPRO       "
    cQuery	+= " AND C1G.D_E_L_E_T_ = ' '              "

    cQuery	+= " WHERE	"
    cQuery	+= " C20.C20_FILIAL IN ( " + cFiliais + " )"

    If cEvent == "R-2030"
        cQuery	+= " AND C20.C20_INDOPE = '1' "
    Else
        cQuery	+= " AND C20.C20_INDOPE = '0' "
    EndIf

    If cBd $ "ORACLE|POSTGRES|DB2"
        cQuery	+=  " AND SUBSTR(C20.C20_DTDOC,1,6) = '"+ cPeriodo +"'"
    ElseIf cBd $ "INFORMIX"
        cQuery	+=  " AND C20.C20_DTDOC[1,6] = '"+ cPeriodo +"'
    Else
        cQuery	+=  " AND SUBSTRING(C20.C20_DTDOC,1,6) = '"+ cPeriodo +"'"
    EndIf

    cQuery	+= " AND C30.C30_TPREPA <> '' "
    cQuery	+= " AND C35.C35_CODTRI = '000013' "
    
    If cEvent == 'R-2030'
        cQuery	+= " AND C1H.C1H_PPES IN ('2','3') "
        cQuery	+= " AND (C1H.C1H_CNPJ <> '' OR ( C1H.C1H_CNPJ = ' ' AND C1H.C1H_PAISEX <> ' ' AND C1H.C1H_PEEXTE = '2' )) "
    Else
        cQuery	+= " AND C1H.C1H_PPES = '2' "
        cQuery	+= " AND C1H.C1H_CNPJ <> '' "
    EndIf
    
    cQuery	+= " AND C20.D_E_L_E_T_ = ' ' "

    cQuery	+= " UNION ALL "

    cQuery	+= " SELECT                           "
endif

cQuery	+= " 'Fatura' AS TIPODOC "
cQuery	+= " ,LEM_FILIAL AS FILIAL "
cQuery	+= " ,C1H_CNPJ AS CNPJ "
cQuery	+= " ,C1H_NOME AS NOME "
cQuery	+= " ,LEM.LEM_NUMERO AS NUMDOCTO "
cQuery	+= " ,'' AS CHAVE "
cQuery	+= " ,LEM.LEM_PREFIX AS SERIE "
cQuery	+= " ,'' AS CODITEM "
cQuery	+= " ,'' AS DESCITEM "
cQuery	+= " ,T5M.T5M_TPREPA AS TPREPASSE "
cQuery	+= " ,LEM.LEM_DTEMIS AS DTEMISSAONF "
cQuery	+= " ,T5M.T5M_VLBRUT AS VLRBRUTO "
cQuery	+= " ,T5M.T5M_VLREAP AS TOTTRIB "
cQuery	+= " ,C1G.C1G_NUMPRO AS PROCESSO "

If __lApurBx
    cQuery += ",SUM(T5P.T5P_VLPGTO) AS VLPGTO "
endif

cQuery	+= " ,C1G.C1G_TPPROC AS TIPOPROC "
cQuery	+= " ,C1G.C1G_DESCRI AS DESCPROC "
cQuery	+= " ,T9E.T9E_VALSUS AS VLRNRET "

cQuery	+= " FROM " + RetSqlName("LEM") + " LEM "
cQuery	+= " INNER JOIN " + RetSqlName("T5M") + " T5M ON "
cQuery	+= " LEM.LEM_FILIAL = T5M.T5M_FILIAL "
cQuery	+= " AND T5M.D_E_L_E_T_ = ' ' "
cQuery	+= " AND T5M.T5M_ID = LEM.LEM_ID "
cQuery	+= " AND T5M.T5M_IDPART = LEM.LEM_IDPART "

If __lApurBx
	cQuery	+= " INNER JOIN " + RetSqlName("T5P") + " T5P ON "
    cQuery	+= " LEM.LEM_FILIAL = T5P.T5P_FILIAL "
    cQuery	+= " AND LEM.LEM_ID = T5P.T5P_ID "
	cQuery	+= " AND LEM.LEM_IDPART = T5P.T5P_IDPART "
    cQuery	+= " AND T5P.D_E_L_E_T_ = ' ' "
EndIf

cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
cQuery	+= " C1H.C1H_ID = LEM.LEM_IDPART "

If cEvent == "R-2040"
        cQuery 	+= " AND C1H.C1H_INDDES = '1'"
EndIf

If cCompC1H == "EEE"
	cQuery += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "
Else
    If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
        cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," +  cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
    ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
        cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
    EndIf
EndIf

cQuery	+= " AND C1H.D_E_L_E_T_ = ' ' "

cQuery	+= " LEFT JOIN                              "
cQuery	+=   RetSqlName("T9E") + " T9E"             "
cQuery	+= " ON LEM.LEM_FILIAL = T9E.T9E_FILIAL     "
cQuery	+= " AND LEM.LEM_ID = T9E.T9E_ID            "
cQuery	+= " AND T9E.D_E_L_E_T_ = ' '               "
cQuery	+= " LEFT JOIN                              "
cQuery	+=   RetSqlName("C1G") + " C1G"             "
cQuery	+= " ON T9E.T9E_FILIAL = C1G.C1G_FILIAL     "
cQuery	+= " AND C1G.C1G_ID = T9E.T9E_NUMPRO        "
cQuery	+= " AND C1G.D_E_L_E_T_ = ' '               "
cQuery	+= " WHERE

cQuery	+= " LEM.LEM_FILIAL IN (" + cFiliais + ")   "

If cEvent == "R-2030"
    cQuery	+= " AND LEM.LEM_NATTIT = '1' "
Else
    cQuery	+= " AND LEM.LEM_NATTIT = '0' "
EndIf

if __lApurBx
    If cBd $ "ORACLE|POSTGRES|DB2"
        cQuery += " AND SUBSTR(T5P.T5P_DTPGTO,1,6) = '"+ cPeriodo +"' "
    ElseIf cBd $ "INFORMIX"
        cQuery += " AND T5P.T5P_DTPGTO[1,6] = '"+ cPeriodo +"' "
    Else
        cQuery += " AND SUBSTRING(T5P.T5P_DTPGTO,1,6) = '"+ cPeriodo +"' "
    EndIf
else
    If cBd $ "ORACLE|POSTGRES|DB2"
    	cQuery += " AND SUBSTR(LEM.LEM_DTEMIS,1,6) = '"+ cPeriodo +"' "
    ElseIf cBd $ "INFORMIX"
    	cQuery += " AND LEM.LEM_DTEMIS[1,6] = '"+ cPeriodo +"' "
    Else
    	cQuery += " AND SUBSTRING(LEM.LEM_DTEMIS,1,6) = '"+ cPeriodo +"' "
    EndIf
endif

cQuery	+= " AND T5M.T5M_TPREPA <> '' "

If cEvent == 'R-2030'
    cQuery	+= " AND C1H.C1H_PPES IN ('2','3') "
    cQuery	+= " AND (C1H.C1H_CNPJ <> '' OR ( C1H.C1H_CNPJ = ' ' AND C1H.C1H_PAISEX <> ' ' AND C1H.C1H_PEEXTE = '2' )) "
Else
    cQuery	+= " AND C1H.C1H_PPES = '2' "
    cQuery	+= " AND C1H.C1H_CNPJ <> '' "
EndIf

cQuery	+= " AND LEM.D_E_L_E_T_ = ' ' "

If __lApurBx
    cQuery += " GROUP BY LEM.LEM_FILIAL, C1H.C1H_CNPJ, C1H.C1H_NOME, LEM.LEM_NUMERO, LEM.LEM_PREFIX, T5M.T5M_TPREPA "
    cQuery += " ,LEM.LEM_DTEMIS, T5M.T5M_VLBRUT, T5M.T5M_VLREAP, C1G.C1G_NUMPRO, C1G.C1G_TPPROC, C1G.C1G_DESCRI, T9E.T9E_VALSUS "
endif

cQuery	+= "ORDER BY 1, 2 "

cQuery	:= "%" + cQuery + "%"

BEGINSQL ALIAS cAlPreCad
    	COLUMN DTEMISSAONF AS DATE
        SELECT %exp:cQuery%
ENDSQL

return cAlPreCad

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function KeyError(oEstruct, oValidationError)
    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oValidationError["registryKey"])
        if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
            if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
                cKeyError := oValidationError["registryKey"][nX]["error"]
            endif
        endif
    Next nX

return ( cKeyError )

//-------------------------------------------------------------------
/*/{Protheus.doc} SetalApurBx()
Seta a variavel __lApurBx conforme o parâmetro

@author Karen Honda
@since 20/05/2021
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function SetalApurBx()
If __lApurBx == nil
    // "1"- Emissão ; "2" - Baixa 
	__lApurBx	:= SuperGetMv('MV_TAFRECD',.F.,"1") == "2" .and. TAFColumnPos("T5P_PROCID") .and. FindFunction("TafCalProp")
EndIf
Return
