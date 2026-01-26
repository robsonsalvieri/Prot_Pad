#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmGerPed()
Função que gera pedido de venda das Ordens de Serviço
@author flavio.martins
@since 13/08/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmGerPed(cCodigoOS, cMsgRet, cCodRet)
Local lRet      := .T.
Local aSC5      := {}
Local aSC6      := {}
Local aItem     := {}
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local cAliasTmp := Nil
Local nItems    := 0
Local cQuery    := ''
Local oQryTmp   := Nil
Local cCodServ  := ''
Local aOrdens   := {}

Private lMsErroAuto := .F.

Begin Transaction
    cQuery += " SELECT "
    cQuery += "   JN3.JN3_CODIGO, "
    cQuery += "   JN3.JN3_CLIENT, "
    cQuery += "   JN3.JN3_LOJA, "
    cQuery += "   JN3.JN3_CONPAG, "
    cQuery += "   JN3.JN3_CODORI, "
    cQuery += "   JN3.JN3_SITUAC, "
    cQuery += "   JN3.JN3_PEDIDO, "
    cQuery += "   SA1.A1_TIPO, "
    cQuery += "   JN4.JN4_CODIGO, "
    cQuery += "   JN4.JN4_CODPRO, "
    cQuery += "   JN4.JN4_VALOR, "
    cQuery += "   JN1.JN1_DESCRI, "
    cQuery += "   SB1SRV.B1_TS AS TES_SRV, "
    cQuery += "   SB1PRD.B1_TS AS TES_PRD, "
    cQuery += "   COALESCE(JO4.JO4_CODIGO, '') JO4_CODIGO, "
    cQuery += "   COALESCE(JO4.JO4_CODPRO, '') JO4_CODPRO, "
    cQuery += "   COALESCE(JO4_QTDPRO, 0) JO4_QTDPRO, "
    cQuery += "   COALESCE(JO4_VALOR, 0) JO4_VALOR "
    cQuery += " FROM " + RetSqlName('JN3') + " JN3 "
    cQuery += "   INNER JOIN " + RetSqlName('SA1') + " SA1 ON SA1.A1_FILIAL = ? "
    cQuery += "   AND SA1.A1_COD = JN3.JN3_CLIENT "
    cQuery += "   AND SA1.A1_LOJA = JN3.JN3_LOJA "
    cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += "   INNER JOIN " + RetSqlName('JN4') + " JN4 ON JN4.JN4_FILIAL = ? "
    cQuery += "   AND JN4.JN4_CODJN3 = JN3.JN3_CODIGO "
    cQuery += "   AND JN4.D_E_L_E_T_ = ' ' "
    cQuery += "   INNER JOIN " + RetSqlName('JN1') + " JN1 ON JN1.JN1_FILIAL = ? "
    cQuery += "   AND JN1.JN1_CODIGO = JN4.JN4_CODJN1 "
    cQuery += "   AND JN1.D_E_L_E_T_ = ' ' "
    cQuery += "   INNER JOIN " + RetSqlName('SB1') + " SB1SRV ON SB1SRV.B1_FILIAL = ? "
    cQuery += "   AND SB1SRV.B1_COD = JN4.JN4_CODPRO "
    cQuery += "   AND SB1SRV.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('JO4') + " JO4 ON JO4.JO4_FILIAL = ? "
    cQuery += "   AND JO4.JO4_CODJN4 = JN4.JN4_CODIGO "
    cQuery += "   AND JO4.JO4_STATUS = '2' "
    cQuery += "   AND JO4.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('SB1') + " SB1PRD ON SB1PRD.B1_FILIAL = ? "
    cQuery += "   AND SB1PRD.B1_COD = JO4.JO4_CODPRO "
    cQuery += "   AND SB1PRD.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE "
    cQuery += "   JN3.JN3_FILIAL = ? "
    cQuery += "   AND (JN3.JN3_CODIGO = ? OR JN3.JN3_CODORI = ?)"
    cQuery += "   AND JN3.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY JN3.JN3_CODIGO, JN4.JN4_CODIGO "

    oQryTmp := FwPreparedStatement():New(cQuery)

    oQryTmp:SetString(1, xFilial("SA1"))
    oQryTmp:SetString(2, xFilial("JN4"))
    oQryTmp:SetString(3, xFilial("JN1"))
    oQryTmp:SetString(4, xFilial("SB1"))
    oQryTmp:SetString(5, xFilial("JN5"))
    oQryTmp:SetString(6, xFilial("SB1"))
    oQryTmp:SetString(7, xFilial("JN3"))
    oQryTmp:SetString(8, cCodigoOS)
    oQryTmp:SetString(9, cCodigoOS)

    cQuery    := oQryTmp:GetFixQuery()
    cAliasTmp := MpSysOpenQuery(cQuery)

    aAdd(aSC5,{"C5_TIPO","N", Nil})  //Tipo do Pedido = Normal
    aAdd(aSC5,{"C5_CLIENTE", (cAliasTmp)->JN3_CLIENT, Nil})
    aAdd(aSC5,{"C5_LOJA", (cAliasTmp)->JN3_LOJA, Nil})
    aAdd(aSC5,{"C5_TIPOCLI",(cAliasTmp)->A1_TIPO, Nil}) 
    aAdd(aSC5,{"C5_CONDPAG", (cAliasTmp)->JN3_CONPAG, Nil})
    aAdd(aSC5,{"C5_ORIGEM","FSMX004", Nil})

    While !(cAliasTmp)->(Eof())

        If !Empty((cAliasTmp)->JN3_PEDIDO) 
            lRet := .F.
            cMsgRet := 'Ordem de serviço ' + (cAliasTmp)->JN3_CODIGO + ' já possui pedido de venda gerado.'
        Endif

        If (cAliasTmp)->JN3_SITUAC != '04' //Status da O.S. Encerrada
            lRet := .F.
            cMsgRet := 'Status da ordem de serviço ' + (cAliasTmp)->JN3_CODIGO + ' não permite a geração do pedido de venda'
        Endif

        If lRet .And. cCodigoOS == (cAliasTmp)->JN3_CODIGO .And. !Empty((cAliasTmp)->JN3_CODORI)
            lRet := .F.
            cMsgRet := 'Ordem de serviço ' + (cAliasTmp)->JN3_CODIGO + ' está vinculada na ordem de serviço ' + (cAliasTmp)->JN3_CODORI
            cMsgRet += ' a geração do pedido deve ser feita pela ordem de serviço de origem.'
        Endif

        If !lRet 
            DisarmTransaction()
            Exit
        Endif

        nItems++

        If (cCodServ != (cAliasTmp)->JN4_CODIGO)

            aAdd(aItem,{"C6_ITEM", StrZero(nItems,TamSx3("C6_ITEM")[1]), Nil})
            aAdd(aItem,{"C6_PRODUTO", (cAliasTmp)->JN4_CODPRO, Nil})
            aAdd(aItem,{"C6_QTDVEN", 1, Nil})
            aAdd(aItem,{"C6_PRCVEN", (cAliasTmp)->JN4_VALOR, Nil})
            aAdd(aItem,{"C6_QTDLIB", 1, Nil})
            aAdd(aItem,{"C6_TES", (cAliasTmp)->TES_SRV, Nil})
            aAdd(aItem,{"AUTDELETA","N",Nil})

            cCodServ := (cAliasTmp)->JN4_CODIGO

            nItems++

            aAdd(aSC6,aClone(aItem))
            aItem := {}

        Endif

        If !Empty((cAliasTmp)->JO4_CODPRO)

            aAdd(aItem,{"C6_ITEM", StrZero(nItems,TamSx3("C6_ITEM")[1]), Nil})
            aAdd(aItem,{"C6_PRODUTO", (cAliasTmp)->JO4_CODPRO, Nil})
            aAdd(aItem,{"C6_QTDVEN", (cAliasTmp)->JO4_QTDPRO, Nil})
            aAdd(aItem,{"C6_PRCVEN", (cAliasTmp)->JO4_VALOR, Nil})
            aAdd(aItem,{"C6_QTDLIB", (cAliasTmp)->JO4_QTDPRO, Nil})
            aAdd(aItem,{"C6_TES", (cAliasTmp)->TES_PRD, Nil})
            aAdd(aItem,{"AUTDELETA","N",Nil})

            aAdd(aSC6,aClone(aItem))
            aItem := {}

        Endif

        If aScan(aOrdens, (cAliasTmp)->JN3_CODIGO) == 0
            aAdd(aOrdens, (cAliasTmp)->JN3_CODIGO)
        Endif

        (cAliasTmp)->(dbSkip())

    EndDo

    If lRet 
        MsExecAuto({|x,y,z| MATA410(x,y,z)},aSC5,aSC6,3)

        If lMsErroAuto

            cFileLog := NomeAutoLog()
            cPath := "\"
            If !Empty(cFileLog)
                cMsgRet := MostraErro(cPath, cFileLog)
                lRet := .F.
                DisarmTransaction()
            Endif

        Else

            cCodRet := SC5->C5_NUM

            lRet := UpdNumPed(aOrdens, cCodRet)

            cMsgRet := "Pedido de venda " + cCodRet + " gerado com sucesso."
        Endif
    Endif

End Transaction    

RestArea(aAreaSC5)
RestArea(aAreaSC6)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdNumPed()
Função para atualizar as ordens de serviço com o número do pedido de venda gerado
@author flavio.martins
@since 13/08/2025
@version 1.0
*/
//-------------------------------------------------------------------
Static Function UpdNumPed(aOrdens, cNumPed)
Local lRet      := .T.
Local aAreaJN3  := JN3->(GetArea())
Local nX := 0

For nX := 1 To Len(aOrdens)

    JN3->(dbSetOrder(1))

    If JN3->(dbSeek(xFilial('JN3')+aOrdens[nX]))

        JN3->(RecLock("JN3",.F.))
            JN3->JN3_PEDIDO := cNumPed
        JN3->(MsUnLock())

    Endif

Next

RestArea(aAreaJN3)

Return lRet
