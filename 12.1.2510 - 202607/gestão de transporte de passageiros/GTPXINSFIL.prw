#include 'protheus.ch'
#include 'parmtype.ch'
#include 'totvs.ch'
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

Function GTPXINSFIL(cNumFch, cProcess)
Local cQuery    := ''
Local oQryTmp   as object
Local cAliasTmp as character

Default cNumFch   := ''
Default cProcess := ''

If AliasInDic("H8C")

    cQuery += " SELECT GZG_AGENCI, "
    cQuery += "        GZG_NUMFCH, "
    cQuery += "        GZG_SEQ, "
    cQuery += "        GZG_TIPO, "
    cQuery += "        GZG_COD, "
    cQuery += "        GZG_VALOR "
    cQuery += "  FROM " + RetSqlName('G6X') + " G6X "
    cQuery += "   INNER JOIN " + RetSqlName('GZG') + " GZG ON GZG.GZG_FILIAL = ? "
    cQuery += "   AND GZG.GZG_AGENCI = G6X.G6X_AGENCI "
    cQuery += "   AND GZG.GZG_NUMFCH = G6X.G6X_NUMFCH "
    cQuery += "   AND GZG.D_E_L_E_T_ = ' ' "
    cQuery += "   INNER JOIN " + RetSqlName('GZC') + " GZC ON GZC.GZC_FILIAL = ? "
    cQuery += "   AND GZC.GZC_CODIGO = GZG.GZG_COD "
    cQuery += "   AND (GZC.GZC_GERTIT = '1' OR GZC.GZC_GERTID = '1') "
    cQuery += "   AND GZC.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE "
    cQuery += "   G6X.G6X_FILIAL = ? "
    cQuery += "   AND G6X.G6X_CODIGO = ? "
    cQuery += "   AND G6X.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    oQryTmp := FwExecStatement():New(cQuery)
    oQryTmp:SetString(1, xFilial("GZG"))
    oQryTmp:SetString(2, xFilial("GZC"))
    oQryTmp:SetString(3, xFilial("G6X"))
    oQryTmp:SetString(4, cNumFch)

    cAliasTmp := oQryTmp:OpenAlias()

    While (cAliasTmp)->(!Eof())

        RecLock("H8C",.T.)

            H8C->H8C_FILIAL := xFilial("H8C")
            H8C->H8C_CODIGO := GetSxeNum("H8C","H8C_CODIGO")
            H8C->H8C_AGENCI := (cAliasTmp)->GZG_AGENCI
            H8C->H8C_NUMFCH := (cAliasTmp)->GZG_NUMFCH
            H8C->H8C_SEQ    := (cAliasTmp)->GZG_SEQ
            H8C->H8C_TIPO   := (cAliasTmp)->GZG_TIPO
            H8C->H8C_CODGZC := (cAliasTmp)->GZG_COD
            H8C->H8C_VALOR  := (cAliasTmp)->GZG_VALOR
            H8C->H8C_DTINCL := dDataBase
            H8C->H8C_HRINCL := Substr(Time(),1,2)+Substr(Time(),4,2)
            H8C->H8C_TPPROC := cProcess

        H8C->(MsUnlock())

        ConfirmSx8()

        (cAliasTmp)->(dbSkip())

    EndDo

    (cAliasTmp)->(dbCloseArea())

Endif

FwFreeObj(oQryTmp)

Return Nil
