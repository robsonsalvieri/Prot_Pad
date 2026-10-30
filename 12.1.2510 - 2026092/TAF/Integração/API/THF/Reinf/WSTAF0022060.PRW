#INCLUDE "TOTVS.CH"

#DEFINE SINTETICO 	1,1
#DEFINE ATIVIDADE 	2,1

/*/{Protheus.doc} WS0022060
    Retorna os registros pendentes de apuração para o evento R-2060
    @author Matheus Prada
    @since 13/01/2020
    @version 1.0
    @return Alias da tabela de onde serão extraídos os protocolos.
/*/
Function WS0022060(aApurac, oCprbVld, cPerApu, oErrorVld, npage, npageSize )

    local nPos      as numeric
    Local nTotReg   as Numeric


    default oCprbVld["eventDetail"]  := {}
    default oErrorVld["registryKey"] := {}
	default npage 		:= 0
	default npageSize	:= 0

    nPos    := 0
    nTotReg := 0

    (aApurac[SINTETICO])->(DbSetOrder(3))
    (aApurac[SINTETICO])->(dbGoTop())

    IF TAFColumnPos("V48_PROCID")
        while (aApurac[SINTETICO])->(!EOF())
            aadd(oCprbVld["eventDetail"],JsonObject():New())
            nPos := len(oCprbVld["eventDetail"])
            nTotReg++
            //Filial do registro
            oCprbVld["eventDetail"][nPos]['branchId']                                            := (aApurac[SINTETICO])->FILIAL

            //Id do registro
            oCprbVld["eventDetail"][nPos]['key']                                                 := (aApurac[SINTETICO])->CHAVE

            //Status do evento
            oCprbVld["eventDetail"][nPos]['status']                                              := Iif(RetStQtd((aApurac[SINTETICO])->FILIAL, (aApurac[SINTETICO])->ID, (aApurac[SINTETICO])->CTPINSC, (aApurac[SINTETICO])->CNRINSC, cPerApu) $ ' |0|1|2|', 'notValidated', 'validated')

            //Periodo do evento
            oCprbVld["eventDetail"][nPos]['period']                                              := (aApurac[SINTETICO])->CPERIODO

            //Tipo de inscricao
            oCprbVld["eventDetail"][nPos]['typeOfInscription']                                   := (aApurac[SINTETICO])->CTPINSC + Iif((aApurac[SINTETICO])->CTPINSC == '1', " - CNPJ", " - CNO")

            //Numero de inscricao
            oCprbVld["eventDetail"][nPos]['taxNumber']                                           := (aApurac[SINTETICO])->CNRINSC

            //Numero de inscricao
            oCprbVld["eventDetail"][nPos]['totalInvoice']                                        := CntAtiv(aApurac, (aApurac[SINTETICO])->FILIAL, (aApurac[SINTETICO])->CHAVE)

            //Valor da Receita Bruta Total
            oCprbVld["eventDetail"][nPos]['totalGrossValue']                                     := (aApurac[SINTETICO])->VLRECBTT

            //Valor total de CPRB
            oCprbVld["eventDetail"][nPos]['sociaSecurityContributionValue']                      := (aApurac[SINTETICO])->VLCPAPUT

            //Valor total da contribuição previdenciária com exigibilidade suspensa
            oCprbVld["eventDetail"][nPos]['socialSecurityContributionValueSuspended']            := (aApurac[SINTETICO])->VLCSUSPT

            //Propriedade errors que habilita o icone no frontend
            oCprbVld["eventDetail"][nPos]["errors"]                                              := 'errors'

            If Len(oErrorVld["registryKey"]) > 0
                // Chave de busca do erro da apuração
                oCprbVld["eventDetail"][nPos]["keyValidationErrors"]                             := KeyError(oCprbVld["eventDetail"][nPos], oErrorVld)
            EndIf

            (aApurac[SINTETICO])->(dbSkip())
        EndDo
    Else
        aadd(oCprbVld["eventDetail"],JsonObject():New())
        //Verifica se o campo V48_PROCID existe.
        oCprbVld["eventDetail"][1]['existProcId']                                                := EncodeUTF8("Atualize o sistema com o último pacote do portal para utilizar essa funcionalidade.")
    EndIF
    oCprbVld['hasNext'] := Iif((npage * npageSize) >= nTotReg, .F., .T.)


return oCprbVld

/*/{Protheus.doc} WS002D2060
    Retorna o detalhe dos registros pendentes de apuração
    @author Bruno Cremaschi
    @since 13/01/2020
    @version 1.0
    @return Alias da tabela de onde serão extraídos os protocolos.
/*/
Function WS002D2060(aApurac, oCprbVld, cChave)

    local nPos as numeric

    default oCprbVld["invoices"] := {}

    nPos :=  0

    (aApurac[ATIVIDADE])->(DbSetOrder(2))
    (aApurac[ATIVIDADE])->(dbGoTop())

    while (aApurac[ATIVIDADE])->(!EOF())
        if Alltrim((aApurac[ATIVIDADE])->CHAVE) $ cChave
            aadd(oCprbVld["invoices"],JsonObject():New())
            nPos := len(oCprbVld["invoices"])

            //Código de Atividade
            oCprbVld["invoices"][nPos]['activityCode']                       := (aApurac[ATIVIDADE])->CODATIV + " - " + EncodeUTF8( Alltrim( ( aApurac[ATIVIDADE])->CDSATIV ) )

            //Valor de Atividade
            oCprbVld["invoices"][nPos]['totalGrossValue']                    := (aApurac[ATIVIDADE])->C5MVATIV

            //Valor base
            oCprbVld["invoices"][nPos]['totalTaxBase']                       := (aApurac[ATIVIDADE])->VBCCPRB

            //Valor adicional de ajuste
            oCprbVld["invoices"][nPos]['additionalValueOfAdjustment']        := (aApurac[ATIVIDADE])->T9TVAJU

            //Valor de exclusão do ajuste
            if (aApurac[ATIVIDADE])->T9TVEXC > 0 
                oCprbVld["invoices"][nPos]['exclusionValueOfAdjustment']     := (aApurac[ATIVIDADE])->T9TVEXC
            else
                oCprbVld["invoices"][nPos]['exclusionValueOfAdjustment']     := (aApurac[ATIVIDADE])->C5MVEXC
            endIf

            //Alíquota
            oCprbVld["invoices"][nPos]['aliquot']                            := (aApurac[ATIVIDADE])->ALQATIV

            //Valor de contribuição
            oCprbVld["invoices"][nPos]['contributionValue']                  := Round(((aApurac[ATIVIDADE])->ALQATIV * (aApurac[ATIVIDADE])->VBCCPRB) / 100,2)
        EndIf

        (aApurac[ATIVIDADE])->(dbSkip())
    EndDo

return oCprbVld

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetStQtd
Função responsável por retornar o status dos documentos

@author Matheus Prada
@since 13/01/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function RetStQtd(cFil, cId, cTpInsc, cNrInsc, cPerApu)

    Local cAlQry    as character
    Local cStatus   as character
    Local cQuery    as character
    Local cPerIni   as character
    Local cPerFin   as character
    Local aBind     as array
    Local nI		as numeric
    Local oPrepare  as object

    cStatus := "3"
    cAlQry  := GetNextAlias()
    cPerApu := SUBSTR(cPerApu,3,4) +SUBSTR(cPerApu,1,2)
    cPerIni := cPerApu + "01"
    cPerFin := dTos(LastDate(STOD(cPerIni)))
    cQuery  := ""
    aBind   := {}
    nI      := 0
    oPrepare := Nil

    If cTpInsc == "1"

        cQuery := " SELECT "
        cQuery += " COUNT(*) TOTAL "
        cQuery += " FROM "
        cQuery += " ( SELECT "
        cQuery += "     CASE "
        cQuery += "     WHEN C5M.C5M_PROCID <> ? "
                aAdd(aBind, space(1))
        cQuery += "     THEN ? "
                aAdd(aBind, '3')
        cQuery += "     WHEN C5M.C5M_PROCID = ? "
                aAdd(aBind, space(1))
        cQuery += "     THEN ? "
                aAdd(aBind, space(1))
        cQuery += "     END AS STATUS "
        cQuery += "   FROM " + RetSqlName("C5M") + " C5M"
        cQuery += "   WHERE C5M.C5M_FILIAL IN (?) "
                aAdd(aBind, {cFil})
        cQuery += "   AND C5M.C5M_DTINI BETWEEN ? AND ? "
                aAdd(aBind, cPerIni)
                aAdd(aBind, cPerFin)
        cQuery += "   AND C5M.C5M_DTFIM BETWEEN ? AND ? "
                aAdd(aBind, cPerIni)
                aAdd(aBind, cPerFin)
        cQuery += "   AND C5M.D_E_L_E_T_ = ?) STATUS  "
                aAdd(aBind, space(1))
        cQuery += " WHERE "          
        cQuery += " STATUS.STATUS = ? "
                aAdd(aBind, space(1))   

    Else

        cQuery := " SELECT "
        cQuery += " COUNT(*) TOTAL "
        cQuery += " FROM "
        cQuery += " ( SELECT "
        cQuery += "     CASE "
        cQuery += "     WHEN V48.V48_PROCID <> ? "
                aAdd(aBind, space(1))
        cQuery += "     THEN ? "
                aAdd(aBind, '3')
        cQuery += "     WHEN V48.V48_PROCID = ? "
                aAdd(aBind, space(1))
        cQuery += "     THEN ? "
                aAdd(aBind, space(1))
        cQuery += "     END AS STATUS "
        cQuery += "   FROM " + RetSqlName("V48") + " V48"
        cQuery += "   INNER JOIN " + RetSqlName("T9C") + " T9C "
        cQuery += "   ON T9C.T9C_FILIAL = V48.V48_FILIAL "
        cQuery += "   AND T9C.T9C_ID = V48.V48_IDCNO "
        cQuery += "   AND T9C.D_E_L_E_T_ = ? "
                aAdd(aBind, space(1))
        cQuery += "   WHERE "
        cQuery += "   T9C_NRINSC = ? "
                aAdd(aBind, cNrInsc)
        cQuery += "   AND V48.D_E_L_E_T_ = ?) STATUS  "
                aAdd(aBind, space(1))
        cQuery += " WHERE "        
        cQuery += " STATUS.STATUS = ? "
                aAdd(aBind, space(1))   

    EndIf

    cQuery := ChangeQuery(cQuery)

    oPrepare := FwExecStatement():New( cQuery )

	For nI := 1 To Len(aBind)
		If Valtype(aBind[nI]) == 'A'
			oPrepare:setIn( nI, aBind[nI] )
		Else
			oPrepare:setString( nI, aBind[nI] )
		Endif
	Next nI

    if "INFORMIX" $ Alltrim(Upper(TCGetDB()))
        oPrepare:cbasequery := oPrepare:getfixquery()
    endif

	oPrepare:OpenAlias(cAlQry)
    
    If (cAlQry)->TOTAL > 0
        cStatus := "0"
    EndIf

    (cAlQry)->(dbCloseArea())

    If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := nil
	EndIf

Return cStatus

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CntAtiv
Função responsável por retornar a quantidade e o status dos documentos

@author Matheus Prada
@since 13/01/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CntAtiv(aApurac, cFil, cId)

    Local nQtdDocs  as numeric

    nQtdDocs    := 0

    (aApurac[ATIVIDADE])->(dbSeek(cId))

    while (aApurac[ATIVIDADE])->(!eof()) .And. (aApurac[ATIVIDADE])->CHAVE $ cId
        nQtdDocs++

        (aApurac[ATIVIDADE])->(DbSkip())
    endDo

return nQtdDocs


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oCprbVld, oErrorVld)

    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oErrorVld["registryKey"])
        if alltrim(oErrorVld["registryKey"][nX]["branchId"]) == alltrim(oCprbVld["branchId"])
            if alltrim(oErrorVld["registryKey"][nX]["id"]) == alltrim(oCprbVld["key"])
                cKeyError := oErrorVld["registryKey"][nX]["error"]
            endif
        endif
    Next nX

return ( cKeyError )
