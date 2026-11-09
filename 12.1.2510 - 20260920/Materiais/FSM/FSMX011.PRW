#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmAgendaTec()
Função que retornar a agenda dos técnicos
@author fernanda.rigolin
@since 06/08/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function fsmxagetec(cDataInicio, cDataFinal, oResponse, cMsgRet)

    Local lRet := .T.

    oResponse["atendentes"] := {}
    oResponse["total"] := 0

    CarregaAgenda(;
        cDataInicio,;
        cDataFinal,;
        oResponse)

Return lRet


Static Function CarregaAgenda(;
    cDataInicio,;
    cDataFinal,;
    oResponse)

    Local cCodAtendente := ""
    Local nAtendentes := 0
    Local nAgendas := 0

    Local cAlias  := GetNextAlias()
    Local cQuery  := ""
    Local oQryTmp := Nil

    Local nParam  := 1

    cQuery := "	SELECT AA1.AA1_CODTEC, "
    cQuery += "	       AA1.AA1_NOMTEC, "
    cQuery += "	       AA1.AA1_FUNCAO, "
    cQuery += "		   SRJ.RJ_DESC,    "
    cQuery += "		   JN6.JN6_CODJN3, "
    cQuery += "	       JN6.JN6_DTINI,  "
    cQuery += "	       JN6.JN6_DTFIM,  "
    cQuery += "	       JN6.JN6_HRINI,  "
    cQuery += "	       JN6.JN6_HRFIM,  "
    cQuery += "		   JN6.JN6_SITUAC,  "
    cQuery += "		   JN6.JN6_CODIGO "
    cQuery += "	FROM "+RetSqlName('AA1') + " AA1 "

    cQuery += " LEFT JOIN  "+RetSqlName("JN6")+" JN6 "
	cQuery += "    ON JN6.JN6_FILIAL = ? "
	cQuery += "   AND JN6.JN6_CODAA1 = AA1.AA1_CODTEC "
    cQuery += "	  AND JN6.JN6_STATUS = '1'  "
    cQuery += "   AND JN6.D_E_L_E_T_ = ' ' "
    cQuery += "   AND JN6.JN6_DTINI BETWEEN ? AND ? "

    cQuery += " INNER JOIN "+ RetSqlName('SRJ') + " SRJ  "
	cQuery += "      ON SRJ.RJ_FILIAL = ? "
	cQuery += "     AND SRJ.RJ_FUNCAO = AA1.AA1_FUNCAO  "
    cQuery += "     AND SRJ.D_E_L_E_T_ = ' ' "

    cQuery += " WHERE "
    cQuery += "      AA1.D_E_L_E_T_ = ' ' "
    cQuery += "  AND AA1.AA1_FILIAL = ? "

    cQuery += " ORDER BY "
    cQuery += "     AA1.AA1_CODTEC, "
    cQuery += "     JN6.JN6_DTINI, "
    cQuery += "     JN6.JN6_HRINI "

    oQryTmp := FWPreparedStatement():New(cQuery)

    oQryTmp:SetString(nParam++, xFilial("JN6"))
    oQryTmp:SetString(nParam++, cDataInicio)
    oQryTmp:SetString(nParam++, cDataFinal)
    oQryTmp:SetString(nParam++, xFilial("SRJ"))
    oQryTmp:SetString(nParam++, xFilial("AA1"))


    cQuery := oQryTmp:GetFixQuery()
    cAlias := MpSysOpenQuery(cQuery)

    While !(cAlias)->(Eof())

        If cCodAtendente != AllTrim((cAlias)->AA1_CODTEC)
		    cCodAtendente := AllTrim((cAlias)->AA1_CODTEC)
		    Aadd(oResponse['atendentes'], JsonObject():New())
  		    nAtendentes++

		    oResponse['atendentes'][nAtendentes]['codigoAtendente'] := AllTrim((cAlias)->AA1_CODTEC)
		    oResponse['atendentes'][nAtendentes]['nomeAtendente'] := AllTrim((cAlias)->AA1_NOMTEC)
		    oResponse['atendentes'][nAtendentes]['codigoFuncao'] := AllTrim((cAlias)->AA1_FUNCAO)
		    oResponse['atendentes'][nAtendentes]['descricaoFuncao'] := AllTrim((cAlias)->RJ_DESC)
		

		    oResponse['atendentes'][nAtendentes]['agendas'] := {}
		
		    nAgendas := 0
            oResponse["total"]++

	    Endif
		
        If !Empty((cAlias)->JN6_CODIGO)
	    	nAgendas++

	   	 	Aadd(oResponse['atendentes'][nAtendentes]['agendas'], JsonObject():New())
	
		    oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['codigo'] := AllTrim((cAlias)->JN6_CODIGO)
		    oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['ordemServico'] := AllTrim((cAlias)->JN6_CODJN3)
		    oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['dataInicial'] := AllTrim((cAlias)->JN6_DTINI)
		    oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['dataFinal'] := AllTrim((cAlias)->JN6_DTFIM)
	    	oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['horaInicial'] := AllTrim((cAlias)->JN6_HRINI)
		    oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['horaFinal'] := AllTrim((cAlias)->JN6_HRFIM)
		    oResponse['atendentes'][nAtendentes]['agendas'][nAgendas]['situacao'] := AllTrim((cAlias)->JN6_SITUAC)
        EndIf

	    (cAlias)->(dbSkip())
    EndDo

    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf
Return

