#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

#Define MAX_ITENS_IN 10

//-------------------------------------------------------------------
/*/{Protheus.doc} fsmxatend()
Retorna os atendentes, permitindo filtro por múltiplos grupos
de atendimento.

Quando não informado filtro de grupos, retorna todos os atendentes.
Quando informado, retorna somente os atendentes pertencentes
aos grupos selecionados.
@author fernanda.rigolin
@since 14/09/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function fsmxatends(oRequest, oResponse)

	Local aGrupos := {}	
	Local aGruposLotes := {}

    oResponse["items"] := {}
    oResponse["total"] := 0

    If oRequest:HasProperty("grupos")
        aGrupos := oRequest["grupos"]
    EndIf	

    aGruposLotes := QuebraArray(aGrupos)

    ProcessaGrupos(;
        aGruposLotes,;
        oResponse)	
Return

Static Function QuebraArray(aValores, nTam)
    Local aRetorno := {}
    Local aLote    := {}
    Local nItem    := 0
    Default nTam := MAX_ITENS_IN

    If Len(aValores) == 0
        AAdd(aRetorno, {})
        Return aRetorno
    EndIf

    For nItem := 1 To Len(aValores)
        AAdd(aLote, aValores[nItem])
        If Len(aLote) == nTam
            AAdd(aRetorno, aClone(aLote))
            aLote := {}
        EndIf
    Next

    If Len(aLote) > 0
        AAdd(aRetorno, aClone(aLote))
    EndIf
Return aRetorno

Static Function ProcessaGrupos(;
    aGruposLotes,;
    oResponse)

    Local nLote   := 0
    Local aGrupos := {}

    For nLote := 1 To Len(aGruposLotes)

        aGrupos := aGruposLotes[nLote]

        CarregaAtendentes(;
            aGrupos,;
            oResponse)

    Next

Return

Static Function AddWhereIn(cCampo, aValores, cQuery)
    Local nItem := 0
    cQuery += " AND " + cCampo + " IN ("
    For nItem := 1 To Len(aValores)
        If nItem > 1
            cQuery += ","
        EndIf
        cQuery += "?"
    Next
    cQuery += ")"
Return cQuery

Static Function AddParametros(oQryTmp, nParam, aValores)
    Local nItem := 0
    For nItem := 1 To Len(aValores)
        oQryTmp:SetString(nParam++, aValores[nItem])
    Next
Return nParam

Static Function AtendentesIndice(aItems, cCodigo)

    Local nItem := 0

    For nItem := 1 To Len(aItems)

        If aItems[nItem]["atendente"] == cCodigo
            Return nItem
        EndIf

    Next

Return 0

Static Function GrupoExiste(aGrupos, cGrupo)

    Local nItem := 0

    For nItem := 1 To Len(aGrupos)

        If aGrupos[nItem] == cGrupo
            Return .T.
        EndIf

    Next

Return .F.

Static Function CarregaAtendentes(aGrupos, oResponse)

    Local cAlias   := GetNextAlias()
    Local cQuery   := ""
    Local oQryTmp  := Nil
    Local nParam   := 1
    Local oItem    := Nil
    Local cCodigo  := ""
    Local cGrupo   := ""
    Local nAtend   := 0

    cQuery += " SELECT DISTINCT "
    cQuery += "     AA1.AA1_CODTEC, "
    cQuery += "     AA1.AA1_NOMTEC, "
    cQuery += "     JOU.JOU_CODJOT "

    cQuery += " FROM " + RetSqlName("AA1") + " AA1 "

    cQuery += " LEFT JOIN " + RetSqlName("JOU") + " JOU "
    cQuery += "      ON JOU.JOU_FILIAL = ? "
    cQuery += "     AND JOU.JOU_CODAA1 = AA1.AA1_CODTEC "
    cQuery += "     AND JOU.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
    cQuery += "       AA1.D_E_L_E_T_ = ' ' "
    cQuery += "   AND AA1.AA1_FILIAL = ? "

    If Len(aGrupos) > 0

        cQuery := AddWhereIn(;
            "JOU.JOU_CODJOT",;
            aGrupos,;
            cQuery)

    EndIf

    cQuery += " ORDER BY "
    cQuery += "     AA1.AA1_NOMTEC, "
    cQuery += "     JOU.JOU_CODJOT "

    oQryTmp := FWPreparedStatement():New(cQuery)

    oQryTmp:SetString(nParam++, xFilial("JOU"))
    oQryTmp:SetString(nParam++, xFilial("AA1"))

    If Len(aGrupos) > 0

        nParam := AddParametros(;
            oQryTmp,;
            nParam,;
            aGrupos)

    EndIf

    cQuery := oQryTmp:GetFixQuery()

    cAlias := MpSysOpenQuery(cQuery)

    While !(cAlias)->(Eof())

        cCodigo := AllTrim(;
            (cAlias)->AA1_CODTEC)

        cGrupo := AllTrim(;
            (cAlias)->JOU_CODJOT)

        nAtend := AtendentesIndice(;
            oResponse["items"],;
            cCodigo)

        If nAtend == 0

            oItem := JsonObject():New()

            oItem["atendente"] := cCodigo

            oItem["nome"] := AllTrim(;
                (cAlias)->AA1_NOMTEC)

            oItem["grupos"] := {}

            If !Empty(cGrupo)

                AAdd(;
                    oItem["grupos"],;
                    cGrupo)

            EndIf

            AAdd(;
                oResponse["items"],;
                oItem)

            oResponse["total"]++

        Else

            If !Empty(cGrupo)

                If !GrupoExiste(;
                    oResponse["items"][nAtend]["grupos"],;
                    cGrupo)

                    AAdd(;
                        oResponse["items"][nAtend]["grupos"],;
                        cGrupo)

                EndIf

            EndIf

        EndIf

        (cAlias)->(DbSkip())

    EndDo

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf

Return
