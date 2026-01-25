#include "protheus.ch"

Function GFEICMPAUT(cCdTrp, cCdRem, cCdDest, cCidOri, cCidDest, cClFre, cTpOp, nTotPeso, lLog)
    Local nValPaut  := 0
    Local nDistan   := 0

    Local cAliasGU7 := ""
    Local cAliasGUT := ""
    Local cAliasGV9 := ""
    Local cAliasGV8 := ""
    Local cAliasGV7 := ""
    Local cAliasGV1 := ""
    
    Local cUFOri    := ""
    Local cDtBase   := ""
    
    Local aResult   := {}
    Local nI        := 0
    
    Default cCdTrp   := ""
    Default cCdRem   := ""
    Default cCdDest  := ""
    Default cCidOri  := ""
    Default cCidDest := ""
    Default cClFre   := ""
    Default cTpOp    := ""
    Default nTotPeso := 0
    Default lLog     := .T.

    If lLog
        oGFEXFBFLog:setTexto(CRLF + "    # Buscando ICMS de Pauta..." + CRLF + CRLF)
    EndIf

    If GFXCP12131("GUT_EMITAB") .And. GFXCP12131("GUT_NRTAB")
        If nTotPeso == 0
            For nI := 1 To Len(aTRBITE1)
                If aTRBITE1[nI][16] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
                    nTotPeso := nTotPeso + aTRBITE1[nI][9]
                EndIf
            Next nI
        EndIf
        
        If lLog
            oGFEXFBFLog:setTexto("        Peso Total.." + cValToChar(nTotPeso) + CRLF + CRLF)
        EndIf

        If !Empty(cCidOri)
            cAliasGU7 := GetNextAlias()

            BeginSQL Alias cAliasGU7
                SELECT GU7.GU7_CDUF
                FROM %Table:GU7% GU7
                WHERE GU7.GU7_NRCID = %Exp:cCidOri%
                AND GU7.%NotDel%
            EndSQL

            If (cAliasGU7)->(!EoF())
                cUFOri := (cAliasGU7)->GU7_CDUF
            EndIf

            (cAliasGU7)->(dbCloseArea())

            If !Empty(cUFOri)
                cAliasGUT := GetNextAlias()

                BeginSQL Alias cAliasGUT
                    SELECT GUT.GUT_EMITAB,
                        GUT.GUT_NRTAB 
                    FROM %Table:GUT% GUT
                    WHERE GUT.GUT_UF = %Exp:cUFOri% 
                    AND GUT.%NotDel%
                EndSQL

                If (cAliasGUT)->(!EoF()) .And. !Empty((cAliasGUT)->GUT_NRTAB)
                    If lLog
                        oGFEXFBFLog:setTexto("        Estado " + cUFOri + " possui tabela ICMS pauta. Emitente: " + (cAliasGUT)->GUT_EMITAB + ". Tabela: " + (cAliasGUT)->GUT_NRTAB + CRLF + CRLF)
                    EndIf

                    cAliasGV9 := GetNextAlias()

                    cDtBase := Iif(!Empty(DTOS(GWN->GWN_DTSAI)),DTOS(GWN->GWN_DTSAI),DTOS(dDataBase)) 

                    BeginSQL Alias cAliasGV9
                        SELECT GV9.GV9_NRNEG
                        FROM %Table:GV9% GV9
                        WHERE GV9.GV9_CDEMIT= %Exp:(cAliasGUT)->GUT_EMITAB%
                        AND GV9.GV9_NRTAB = %Exp:(cAliasGUT)->GUT_NRTAB%
                        AND GV9.GV9_DTVALI <= %Exp:cDtBase%
                        AND (GV9.GV9_DTVALF = '' OR GV9.GV9_DTVALF >= %Exp:cDtBase%)
                        AND (GV9.GV9_CDCLFR = '' OR GV9.GV9_CDCLFR = %Exp:cClFre%)
                        AND (GV9.GV9_CDTPOP = '' OR GV9.GV9_CDTPOP = %Exp:cTpOp%)
                        AND GV9.%NotDel%
                        ORDER BY GV9.GV9_DTVALI DESC
                    EndSQL

                    If (cAliasGV9)->(!EoF())
                        nDistan := GWN->GWN_DISTAN

                        If lLog
                            oGFEXFBFLog:setTexto("        KM Romaneio: " + cValToChar(nDistan) + CRLF + CRLF)
                        EndIf

                        If nDistan == 0
                            If lLog
                                oGFEXFBFLog:setTexto("        # Buscando KM do cadastro de distância... " + CRLF + CRLF)
                            EndIf

                            aCriterios := {cCdRem,;
                                           cCdDest,;
                                           cCidOri,;
                                           cCidDest,;
                                           (cAliasGUT)->GUT_EMITAB,;
                                           POSICIONE("GU3",1,XFILIAL("GU3")+(cAliasGUT)->GUT_EMITAB,"GU3_CDGREM") ,;
                                           cTpOp,;
                                           GWN->GWN_CDTPVC,;
                                           "1",;
                                           cClFre}

                            aResult := GFETabPrzQbr(aCriterios, cDtBase, , "2")

                            If aResult[10] > 0
                                nDistan := aResult[10]

                                If lLog
                                    oGFEXFBFLog:setTexto("            Distância entre cidade " + cCidOri + " e cidade " + cCidDest + " : " + cValToChar(nDistan) + CRLF + CRLF)
                                EndIf
                            Else
                                If lLog
                                    oGFEXFBFLog:setTexto("            Não encontrada distância entre cidades ou o valor está zerado!" + CRLF + CRLF)
                                EndIf
                            EndIf
                        EndIf

                        cAliasGV8 := GetNextAlias()

                        BeginSQL Alias cAliasGV8
                            SELECT GV8.GV8_NRROTA
                            FROM %Table:GV8% GV8
                            WHERE GV8.GV8_CDEMIT= %Exp:(cAliasGUT)->GUT_EMITAB%
                            AND GV8.GV8_NRTAB = %Exp:(cAliasGUT)->GUT_NRTAB%
                            AND GV8.GV8_NRNEG = %Exp:(cAliasGV9)->GV9_NRNEG%
                            AND ((GV8.GV8_TPORIG = '1' AND GV8.GV8_NRCIOR = %Exp:cCidOri%)
                            OR (GV8.GV8_TPORIG = '4' AND GV8.GV8_CDUFOR = %Exp:cUFOri%)
                            OR (GV8.GV8_TPORIG = '2' AND GV8.GV8_DSTORI <= %Exp:nDistan% AND GV8.GV8_DSTORF >= %Exp:nDistan%))
                            AND ((GV8.GV8_TPDEST = '1' AND GV8.GV8_NRCIDS = %Exp:cCidDest%)
                            OR (GV8.GV8_TPDEST = '2')
                            OR (GV8.GV8_TPDEST = '2' AND GV8.GV8_DSTDEI <= %Exp:nDistan% AND GV8.GV8_DSTDEF >= %Exp:nDistan%))
                            AND GV8.%NotDel%
                            ORDER BY GV8.GV8_NRROTA DESC
                        EndSQL

                        cAliasGV7 := GetNextAlias()

                        BeginSQL Alias cAliasGV7
                            SELECT GV7.GV7_CDFXTV
                            FROM %Table:GV7% GV7
                            WHERE GV7.GV7_CDEMIT= %Exp:(cAliasGUT)->GUT_EMITAB%
                            AND GV7.GV7_NRTAB = %Exp:(cAliasGUT)->GUT_NRTAB%
                            AND GV7.GV7_NRNEG = %Exp:(cAliasGV9)->GV9_NRNEG%
                            AND GV7.GV7_QTFXFI >= %Exp:nTotPeso%
                            AND GV7.%NotDel%
                            ORDER BY GV7.GV7_QTFXFI
                        EndSQL

                        If (cAliasGV8)->(!EoF()) .And. (cAliasGV7)->(!EoF())
                            cAliasGV1 := GetNextAlias()

                            BeginSQL Alias cAliasGV1
                                SELECT GV1.GV1_VLFIXN,
                                    GV1.GV1_VLUNIN
                                FROM %Table:GV1% GV1
                                WHERE GV1.GV1_CDEMIT= %Exp:(cAliasGUT)->GUT_EMITAB%
                                AND GV1.GV1_NRTAB = %Exp:(cAliasGUT)->GUT_NRTAB%
                                AND GV1.GV1_NRNEG = %Exp:(cAliasGV9)->GV9_NRNEG%
                                AND GV1.GV1_NRROTA = %Exp:(cAliasGV8)->GV8_NRROTA%
                                AND GV1.GV1_CDFXTV = %Exp:(cAliasGV7)->GV7_CDFXTV%
                                AND GV1.%NotDel%
                            EndSQL

                            If (cAliasGV1)->(!EoF())
                                If lLog
                                    oGFEXFBFLog:setTexto("        Tarifa Encontrada! " + CRLF + CRLF)
                                    oGFEXFBFLog:setTexto("        Emitente: " + (cAliasGUT)->GUT_EMITAB + CRLF)
                                    oGFEXFBFLog:setTexto("        Tabela: " + (cAliasGUT)->GUT_NRTAB + CRLF)
                                    oGFEXFBFLog:setTexto("        Negociação: " + (cAliasGV9)->GV9_NRNEG + CRLF)
                                    oGFEXFBFLog:setTexto("        Rota: " + (cAliasGV8)->GV8_NRROTA + CRLF)
                                    oGFEXFBFLog:setTexto("        Faixa: " + (cAliasGV7)->GV7_CDFXTV + CRLF + CRLF)
                                
                                    oGFEXFBFLog:setTexto("        Montagem do valor de ICMS Pauta " + CRLF + CRLF)
                                EndIf

                                (cAliasGV1)->(dbGoTop())

                                While((cAliasGV1)->(!EoF()))
                                    If lLog
                                        oGFEXFBFLog:setTexto("        Valor atual Base ICMS Pauta: " + cValToChar(nValPaut) + CRLF)
                                        oGFEXFBFLog:setTexto("        Valor Fixo componente: " + cValToChar((cAliasGV1)->GV1_VLFIXN) + CRLF)
                                        oGFEXFBFLog:setTexto("        Peso Unidade de cálculo: " + cValToChar(nTotPeso) + CRLF)
                                        oGFEXFBFLog:setTexto("        Valor Unitário componente: " + cValToChar((cAliasGV1)->GV1_VLUNIN) + CRLF)
                                        oGFEXFBFLog:setTexto("        Cálculo componente: " + cValToChar(nValPaut) + " + " + cValToChar((cAliasGV1)->GV1_VLFIXN) + " + (" + cValToChar(nTotPeso) + "*" + cValToChar((cAliasGV1)->GV1_VLUNIN) + ")" + CRLF)
                                    EndIf

                                    nValPaut := nValPaut + (cAliasGV1)->GV1_VLFIXN + (nTotPeso * (cAliasGV1)->GV1_VLUNIN)
                                    
                                    If lLog
                                        oGFEXFBFLog:setTexto("        Base ICMS Pauta: " + cValToChar(nValPaut) + CRLF)
                                    EndIf

                                    (cAliasGV1)->(dbSkip())
                                EndDo
                            Else
                                If lLog
                                    oGFEXFBFLog:setTexto("        Tarifa não Encontrada! " + CRLF + CRLF)
                                EndIf
                            EndIf

                            (cAliasGV1)->(dbCloseArea())
                        Else
                            If lLog
                                oGFEXFBFLog:setTexto("Não encontrado a Rota ou Faixa conforme documentação ICMS Pauta" + CRLF + CRLF)
                            EndIf
                        EndIf
                        
                        (cAliasGV8)->(dbCloseArea())
                        (cAliasGV7)->(dbCloseArea())
                    Else
                        If lLog
                            oGFEXFBFLog:setTexto("Não encontrada negociação válida!" + CRLF + CRLF)    
                        EndIf
                    EndIf

                    (cAliasGV9)->(dbCloseArea())
                EndIf

                (cAliasGUT)->(dbCloseArea())
            EndIf
        EndIf
    Else
        If lLog
            oGFEXFBFLog:setTexto("        Os campos GUT_EMITAB e GUT_NRTAB não existem na base." + CRLF + CRLF)
        EndIf
    EndIf

    If lLog
        oGFEXFBFLog:setTexto(CRLF + "        Valor Total Base ICMS Pauta: " + cValToChar(nValPaut) + CRLF + CRLF)
    EndIf
Return nValPaut
