#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmGerPed()
Função que gera pedido de venda dos orçamentos
@author flavio.martins
@since 13/10/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmPedOrc(cCodOrc, cMsgRet, cCodRet)
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
Local cMvDupNat := SuperGetMv("MV_1DUPNAT",,"")
Local aRetPe    := {}

Default cCodOrc := ''
Default cMsgRet := ''
Default cCodRet := ''

Private lMsErroAuto := .F.

Begin Transaction
    cQuery += " SELECT "
    cQuery += "   JN7.JN7_CODIGO, "
    cQuery += "   JN7.JN7_CLIENT, "
    cQuery += "   JN7.JN7_LOJA, "
    cQuery += "   JNB.JNB_CONPAG, "
    cQuery += "   JN7.JN7_SITUA, "
    cQuery += "   JN7.JN7_PEDIDO, "
    cQuery += "   SA1.A1_TIPO, "
    cQuery += "   JN9.JN9_CODIGO, "
    cQuery += "   JN9.JN9_CODPRO, "
    cQuery += "   JN9.JN9_VALOR, "
    cQuery += "   JN1.JN1_DESCRI, "
    cQuery += "   SB1SRV.B1_TS AS TES_SRV, "
    cQuery += "   SB1PRD.B1_TS AS TES_PRD, "
    cQuery += "   COALESCE(JNA.JNA_CODIGO, '') JNA_CODIGO, "
    cQuery += "   COALESCE(JNA.JNA_PRODUT, '') JNA_PRODUT, "
    cQuery += "   COALESCE(JNA.JNA_QUANTI, 0) JNA_QUANTI, "
    cQuery += "   COALESCE(JNA.JNA_VALOR, 0) JNA_VALOR "
    cQuery += " FROM " + RetSqlName('JN7') + " JN7 "
    cQuery += "   LEFT JOIN " + RetSqlName('SA1') + " SA1 ON SA1.A1_FILIAL = ? "
    cQuery += "   AND SA1.A1_COD = JN7.JN7_CLIENT "
    cQuery += "   AND SA1.A1_LOJA = JN7.JN7_LOJA "
    cQuery += "   AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('JNB') + " JNB ON JNB.JNB_FILIAL = ? "
    cQuery += "   AND JNB.JNB_CODJN7 = JN7.JN7_CODIGO "
    cQuery += "   AND JNB.D_E_L_E_T_ = ' ' "
    cQuery += "   INNER JOIN " + RetSqlName('JN9') + " JN9 ON JN9.JN9_FILIAL = ? "
    cQuery += "   AND JN9.JN9_CODJN7 = JN7.JN7_CODIGO "
    cQuery += "   AND JN9.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('JN1') + " JN1 ON JN1.JN1_FILIAL = ? "
    cQuery += "   AND JN1.JN1_CODIGO = JN9.JN9_CODJN1 "
    cQuery += "   AND JN1.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('SB1') + " SB1SRV ON SB1SRV.B1_FILIAL = ? "
    cQuery += "   AND SB1SRV.B1_COD = JN9.JN9_CODPRO "
    cQuery += "   AND SB1SRV.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('JNA') + " JNA ON JNA.JNA_FILIAL = ? "
    cQuery += "   AND JNA.JNA_CODJN9 = JN9.JN9_CODIGO "
    cQuery += "   AND JNA.D_E_L_E_T_ = ' ' "
    cQuery += "   LEFT JOIN " + RetSqlName('SB1') + " SB1PRD ON SB1PRD.B1_FILIAL = ? "
    cQuery += "   AND SB1PRD.B1_COD = JNA.JNA_PRODUT "
    cQuery += "   AND SB1PRD.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE "
    cQuery += "   JN7.JN7_FILIAL = ? "
    cQuery += "   AND (JN7.JN7_CODIGO = ?)"
    cQuery += "   AND JN7.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY JN7.JN7_CODIGO, JN9.JN9_CODIGO "

    oQryTmp := FwPreparedStatement():New(cQuery)

    oQryTmp:SetString(1, xFilial("SA1"))
    oQryTmp:SetString(2, xFilial("JNB"))
    oQryTmp:SetString(3, xFilial("JN9"))
    oQryTmp:SetString(4, xFilial("JN1"))
    oQryTmp:SetString(5, xFilial("SB1"))
    oQryTmp:SetString(6, xFilial("JNA"))
    oQryTmp:SetString(7, xFilial("SB1"))
    oQryTmp:SetString(8, xFilial("JN7"))
    oQryTmp:SetString(9, cCodOrc)

    cQuery    := oQryTmp:GetFixQuery()
    cAliasTmp := MpSysOpenQuery(cQuery)

    aAdd(aSC5,{"C5_TIPO","N", Nil})  //Tipo do Pedido = Normal
    aAdd(aSC5,{"C5_CLIENTE", (cAliasTmp)->JN7_CLIENT, Nil})
    aAdd(aSC5,{"C5_LOJACLI", (cAliasTmp)->JN7_LOJA, Nil})
    aAdd(aSC5,{"C5_TIPOCLI",(cAliasTmp)->A1_TIPO, Nil}) 
    aAdd(aSC5,{"C5_CONDPAG", (cAliasTmp)->JNB_CONPAG, Nil})
    aAdd(aSC5,{"C5_ORIGEM","FSMX004", Nil})

    If Alltrim(cMvDupNat) == 'SC5->C5_NATUREZ'

        JNU->(dbSetOrder(1))
        If JNU->(dbSeek(xFilial('JNU')+'NATUREZAFINANC')) .And. !Empty(JNU->JNU_CONTEU)
            aAdd(aSC5,{"C5_NATUREZ", JNU->JNU_CONTEU, Nil})
        Else 
            cMsgRet := "Parâmetro MV_1DUPNAT configurado como 'SC5->C5_NATUREZ', configure o parâmetro do módulo 'NATUREZAFINANC' com uma natureza financeira válida."
            lRet := .F.
        Endif

    Endif 

    If lRet 
        While !(cAliasTmp)->(Eof())

            If !Empty((cAliasTmp)->JN7_PEDIDO) 
                lRet := .F.
                cMsgRet := 'Orçamento ' + (cAliasTmp)->JN7_CODIGO + ' já possui pedido de venda gerado.'
            Endif

            If (cAliasTmp)->JN7_SITUA != '2' //Status da O.S. Encerrada
                lRet := .F.
                cMsgRet := 'Status do orçamento ' + (cAliasTmp)->JN7_CODIGO + ' não permite a geração do pedido de venda'
            Endif
        
            If !lRet 
                DisarmTransaction()
                Exit
            Endif

            nItems++

            If (cCodServ != (cAliasTmp)->JN9_CODIGO)

                aAdd(aItem,{"C6_ITEM", StrZero(nItems,TamSx3("C6_ITEM")[1]), Nil})
                aAdd(aItem,{"C6_PRODUTO", (cAliasTmp)->JN9_CODPRO, Nil})
                aAdd(aItem,{"C6_QTDVEN", 1, Nil})
                aAdd(aItem,{"C6_PRCVEN", (cAliasTmp)->JN9_VALOR, Nil})
                aAdd(aItem,{"C6_QTDLIB", 1, Nil})
                aAdd(aItem,{"C6_TES", (cAliasTmp)->TES_SRV, Nil})
                aAdd(aItem,{"AUTDELETA","N",Nil})

                cCodServ := (cAliasTmp)->JN9_CODIGO

                nItems++

                aAdd(aSC6,aClone(aItem))
                aItem := {}

            Endif

            If !Empty((cAliasTmp)->JNA_PRODUT)

                aAdd(aItem,{"C6_ITEM", StrZero(nItems,TamSx3("C6_ITEM")[1]), Nil})
                aAdd(aItem,{"C6_PRODUTO", (cAliasTmp)->JNA_PRODUT, Nil})
                aAdd(aItem,{"C6_QTDVEN", (cAliasTmp)->JNA_QUANTI, Nil})
                aAdd(aItem,{"C6_PRCVEN", (cAliasTmp)->JNA_VALOR, Nil})
                aAdd(aItem,{"C6_QTDLIB", (cAliasTmp)->JNA_QUANTI, Nil})
                aAdd(aItem,{"C6_TES", (cAliasTmp)->TES_PRD, Nil})
                aAdd(aItem,{"AUTDELETA","N",Nil})

                aAdd(aSC6,aClone(aItem))
                aItem := {}

            Endif

            (cAliasTmp)->(dbSkip())

        EndDo
    Endif

    If lRet 

        If ExistBlock("FS05PEPV")
            aRetPe := ExecBlock("FS05PEPV",.F.,.F.,{aSC5,aSC6})
            If ValType(aRetPe) == "A"
                aSC5 := aClone(aRetPe[1])
                aSC6 := aClone(aRetPe[2])
            EndIf
        EndIf

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

            lRet := UpdNumPed(cCodOrc, cCodRet)

            cMsgRet := "Pedido de venda " + cCodRet + " gerado com sucesso."
        Endif
    Endif

(cAliasTmp)->(dbCloseArea())

End Transaction    

RestArea(aAreaSC5)
RestArea(aAreaSC6)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdNumPed()
Função para atualizar o orçamento com o número do pedido de venda gerado
@author flavio.martins
@since 13/10/2025
@version 1.0
*/
//-------------------------------------------------------------------
Static Function UpdNumPed(cCodOrc, cNumPed)
Local lRet      := .T.
Local aAreaJN7  := JN7->(GetArea())

JN7->(dbSetOrder(1))

If JN7->(dbSeek(xFilial('JN7')+cCodOrc))

    JN7->(RecLock("JN7",.F.))
        JN7->JN7_PEDIDO := cNumPed
    JN7->(MsUnLock())

Endif

RestArea(aAreaJN7)

Return lRet
