#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmOrdemServicoPlano()
Função que retornar a quantidade de OS, data da ultima OS e Data do encerramento da OS
  dos serviços em equipamentos de plano de manutenção 
@author fernanda.rigolin
@since 26/06/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmOrdemServicoPlano(oRequest, oResponse, cMsgRet)

    Local lRet := .T.

    Local nPlano := 0
    Local nVinc  := 0

    Local cPlano := ""
    Local cVincPlanoEquip := ""

    oResponse["items"] := {}

    If oRequest:HasProperty("planos") .And. ;
            Len(oRequest["planos"]) > 0

        For nPlano := 1 To Len(oRequest["planos"])

            cPlano := oRequest["planos"][nPlano]

            CarregaOSPlano(;
                cPlano, ;
                "", ;
                oResponse)


        Next

    ElseIf oRequest:HasProperty("vincPlanoEquip") .And. ;
            Len(oRequest["vincPlanoEquip"]) > 0

        For nVinc := 1 To Len(oRequest["vincPlanoEquip"])

            cVincPlanoEquip := ;
                oRequest["vincPlanoEquip"][nVinc]

            CarregaOSPlano(;
                "", ;
                cVincPlanoEquip, ;
                oResponse)

        Next
    EndIf

    oResponse["total"] := Len(oResponse["items"])

    If oResponse["total"] == 0
        cMsgRet := "Nenhuma ordem de serviço encontrada."
    EndIf

Return lRet

Static Function CarregaOSPlano(cPlano, cVincPlanoEquip, oResponse)

    Local cAlias   := GetNextAlias()
    Local cQuery   := ""
    Local oQryTmp  := Nil

    Local oItem    := Nil
    Local oServico := Nil

    Local cKey     := ""
    Local cUltKey  := ""

    Local nParam   := 1

    cQuery := ""

    cQuery += " SELECT "
    cQuery += "   JN3F.JN3_CLIENT, "
    cQuery += "   JN3F.JN3_LOJA, "
    cQuery += "   JN3F.JN3_CODPRO, "
    cQuery += "   JN3F.JN3_NUMSER, "
    cQuery += "   JN3F.JN3_CODJOQ, "
    cQuery += "   JN3F.JN3_CODJOS, "
    cQuery += "   JN4F.JN4_CODJN1, "
    cQuery += "   JN4F.JN4_CODJOR, "

    cQuery += "   HIST.QTDEOS, "
    cQuery += "   HIST.ULTOS, "
    cQuery += "   HIST.ULTMANUT "

    cQuery += " FROM " + RetSqlName("JN3") + " JN3F "

    cQuery += " INNER JOIN " + RetSqlName("JN4") + " JN4F "
    cQuery += "    ON JN4F.JN4_FILIAL = ? "
    cQuery += "   AND JN4F.JN4_CODJN3 = JN3F.JN3_CODIGO "
    cQuery += "   AND JN4F.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN ( "

    cQuery += " SELECT "
    cQuery += "     H3.JN3_CLIENT, "
    cQuery += "     H3.JN3_LOJA, "
    cQuery += "     H3.JN3_CODPRO, "
    cQuery += "     H3.JN3_NUMSER, "
    cQuery += "     H3.JN3_CODJOQ, "
    cQuery += "     H3.JN3_CODJOS, "
    cQuery += "     H4.JN4_CODJOR, "
    cQuery += "     COUNT(*) QTDEOS, "
    cQuery += "     MAX(H3.JN3_DTPREV) ULTOS, "
    cQuery += "     MAX(H3.JN3_DTENCE) ULTMANUT "

    cQuery += " FROM " + RetSqlName("JN3") + " H3 "

    cQuery += " INNER JOIN " + RetSqlName("JN4") + " H4 "
    cQuery += "    ON H4.JN4_FILIAL = ? "
    cQuery += "   AND H4.JN4_CODJN3 = H3.JN3_CODIGO "
    cQuery += "   AND H4.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
    cQuery += "     H3.D_E_L_E_T_ = ' ' "
    cQuery += " AND H3.JN3_FILIAL = ? "

    cQuery += " GROUP BY "
    cQuery += "     H3.JN3_CLIENT, "
    cQuery += "     H3.JN3_LOJA, "
    cQuery += "     H3.JN3_CODPRO, "
    cQuery += "     H3.JN3_NUMSER, "
    cQuery += "     H3.JN3_CODJOQ, "
    cQuery += "     H3.JN3_CODJOS, "
    cQuery += "     H4.JN4_CODJOR "

    cQuery += " ) HIST "

    cQuery += " ON HIST.JN3_CLIENT = JN3F.JN3_CLIENT "
    cQuery += " AND HIST.JN3_LOJA   = JN3F.JN3_LOJA "
    cQuery += " AND HIST.JN3_CODPRO = JN3F.JN3_CODPRO "
    cQuery += " AND HIST.JN3_NUMSER = JN3F.JN3_NUMSER "
    cQuery += " AND HIST.JN3_CODJOQ = JN3F.JN3_CODJOQ "
    cQuery += " AND HIST.JN3_CODJOS = JN3F.JN3_CODJOS "
    cQuery += " AND HIST.JN4_CODJOR = JN4F.JN4_CODJOR "

    cQuery += " WHERE "
    cQuery += "     JN3F.D_E_L_E_T_ = ' ' "
    cQuery += " AND JN3F.JN3_FILIAL = ? "

    If !Empty(cPlano)
        cQuery += " AND JN3F.JN3_CODJOQ = ? "
    EndIf

    If !Empty(cVincPlanoEquip)
        cQuery += " AND JN3F.JN3_CODJOS = ? "
    EndIf

    cQuery += " GROUP BY "

    cQuery += " JN3F.JN3_CLIENT, "
    cQuery += " JN3F.JN3_LOJA, "
    cQuery += " JN3F.JN3_CODPRO, "
    cQuery += " JN3F.JN3_NUMSER, "
    cQuery += " JN3F.JN3_CODJOQ, "
    cQuery += " JN3F.JN3_CODJOS, "
    cQuery += " JN4F.JN4_CODJN1, "
    cQuery += " JN4F.JN4_CODJOR, "
    cQuery += " HIST.QTDEOS, "
    cQuery += " HIST.ULTOS, "
    cQuery += " HIST.ULTMANUT "

    cQuery += " ORDER BY "
    cQuery += " JN3F.JN3_CLIENT, "
    cQuery += " JN3F.JN3_LOJA, "
    cQuery += " JN3F.JN3_CODPRO, "
    cQuery += " JN3F.JN3_NUMSER, "
    cQuery += " JN3F.JN3_CODJOQ, "
    cQuery += " JN3F.JN3_CODJOS, "
    cQuery += " JN4F.JN4_CODJOR "

    oQryTmp := FWPreparedStatement():New(cQuery)

    oQryTmp:SetString(nParam++, xFilial("JN4"))
    oQryTmp:SetString(nParam++, xFilial("JN4"))
    oQryTmp:SetString(nParam++, xFilial("JN3"))
    oQryTmp:SetString(nParam++, xFilial("JN3"))

    If !Empty(cPlano)
        oQryTmp:SetString(nParam++, cPlano)
    EndIf

    If !Empty(cVincPlanoEquip)
        oQryTmp:SetString(nParam++, cVincPlanoEquip)
    EndIf

    cQuery := oQryTmp:GetFixQuery()
    cAlias := MpSysOpenQuery(cQuery)

    While !(cAlias)->(Eof())

        cKey := ;
            AllTrim((cAlias)->JN3_CLIENT) + "|" + ;
            AllTrim((cAlias)->JN3_LOJA) + "|" + ;
            AllTrim((cAlias)->JN3_CODPRO) + "|" + ;
            AllTrim((cAlias)->JN3_NUMSER) + "|" + ;
            AllTrim((cAlias)->JN3_CODJOQ) + "|" + ;
            AllTrim((cAlias)->JN3_CODJOS)

        If cKey <> cUltKey

            oItem := JsonObject():New()

            oItem["codigoCliente"] := AllTrim((cAlias)->JN3_CLIENT)
            oItem["lojaCliente"] := AllTrim((cAlias)->JN3_LOJA)
            oItem["codigoBase"] := AllTrim((cAlias)->JN3_CODPRO)
            oItem["numeroSerie"] := AllTrim((cAlias)->JN3_NUMSER)
            oItem["codigoPlano"] := AllTrim((cAlias)->JN3_CODJOQ)
            oItem["codigoVincPlanoEquip"] := AllTrim((cAlias)->JN3_CODJOS)
            oItem["servicos"] := {}

            AAdd(oResponse["items"], oItem)

            cUltKey := cKey

        EndIf

        oServico := JsonObject():New()

        oServico["codigoServico"] := AllTrim((cAlias)->JN4_CODJN1)
		oServico["codigoVincPlanoServ"] := AllTrim((cAlias)->JN4_CODJOR)

		oServico["qtdeOSGerada"] := (cAlias)->QTDEOS

		If Empty((cAlias)->ULTOS)
			oServico["dataUltOS"] := ""
		Else
			oServico["dataUltOS"] := AllTrim(cValToChar((cAlias)->ULTOS))
		EndIf

		If Empty((cAlias)->ULTMANUT)
			oServico["dataUltManut"] := ""
		Else
			oServico["dataUltManut"] := AllTrim(cValToChar((cAlias)->ULTMANUT))
		EndIf

        AAdd(oItem["servicos"], oServico)

        (cAlias)->(dbSkip())

    EndDo

    If Select(cAlias) > 0
        (cAlias)->(dbCloseArea())
    EndIf

Return
