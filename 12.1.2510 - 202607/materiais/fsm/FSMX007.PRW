#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

Function FsmPedGrp(cOrdemServ, nGrupoId, nValorTotal, nQtdGrupos, aItens, cMsgRet, cCodRet)

    Local lRet          := .T.
    Local cAliasTmp     := ""
    Local cQuery        := ""
    Local oQryTmp       := Nil
    Local aSC5          := {}
    Local aSC6          := {}
    Local aItem         := {}
    Local nItem         := 1
    Local nX            := 0
    Local oItem         := Nil
    Local cProduto      := ""
    Local cTes          := ""
    Local nValorItem    := 0
    Local cFileLog      := ""
    Local cPath         := "\"
    Local cCondPag      := '000'
    Local nQtddGrp      := 0

    DEFAULT cOrdemServ   := ''
    DEFAULT nGrupoId := 0
    DEFAULT cCodProduto   := ''
    DEFAULT cArmazem := ''
    DEFAULT cNumOs :=  ''    
    DEFAULT codSolici	 := ''
    DEFAULT nQtdSolicitado	 := 0
    DEFAULT nQtdEntregue	 := 0
    DEFAULT cStatus	 := ''
    DEFAULT cPreRequsitado := ''

    Private lMsErroAuto := .F.

    Begin Transaction

        If ExiPedGrp(cOrdemServ, nGrupoId)
            cMsgRet := 'Já existe pedido gerado para este grupo.'
            lRet := .F.
        Else

            cQuery := ""
            cQuery += " SELECT "
            cQuery += "   JN3.JN3_CODIGO, "
            cQuery += "   JN3.JN3_CLIENT, "
            cQuery += "   JN3.JN3_LOJA, "
            cQuery += "   JN3.JN3_CONPAG, "
            cQuery += "   JN3.JN3_SITUAC, "
            cQuery += "   SA1.A1_TIPO "
            cQuery += " FROM " + RetSqlName("JN3") + " JN3 "
            cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = ? "
            cQuery += "    AND SA1.A1_COD = JN3.JN3_CLIENT "
            cQuery += "    AND SA1.A1_LOJA = JN3.JN3_LOJA "
            cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "
            cQuery += " WHERE JN3.JN3_FILIAL = ? "
            cQuery += "   AND JN3.JN3_CODIGO = ? "
            cQuery += "   AND JN3.D_E_L_E_T_ = ' ' "

            oQryTmp := FwPreparedStatement():New(cQuery)
            oQryTmp:SetString(1, xFilial("SA1"))
            oQryTmp:SetString(2, xFilial("JN3"))
            oQryTmp:SetString(3, cOrdemServ)

            cQuery := oQryTmp:GetFixQuery()
            cAliasTmp := MpSysOpenQuery(cQuery)

            If (cAliasTmp)->(Eof())
                cMsgRet := 'Ordem de serviço não encontrada.'
                lRet := .F.
            Else

                If Empty((cAliasTmp)->JN3_SITUAC)
                    cMsgRet := 'A ordem de serviço foi encontrada, mas está sem status.'
                    lRet := .F.
                EndIf

                If (cAliasTmp)->JN3_SITUAC != '04'
                    cMsgRet := 'Status da O.S. não permite gerar pedido.'
                    lRet := .F.
                Endif    

                cCondPag := AllTrim((cAliasTmp)->JN3_CONPAG)

            EndIf
                
        Endif    

        If lRet

            aAdd(aSC5, {"C5_TIPO"   , "N", Nil})
            aAdd(aSC5, {"C5_CLIENTE", (cAliasTmp)->JN3_CLIENT, Nil})
            aAdd(aSC5, {"C5_LOJA"   , (cAliasTmp)->JN3_LOJA, Nil})
            aAdd(aSC5, {"C5_TIPOCLI", (cAliasTmp)->A1_TIPO, Nil})
            aAdd(aSC5, {"C5_CONDPAG", cCondPag, Nil})
            aAdd(aSC5, {"C5_ORIGEM" , "FSMGRP", Nil})

            For nX := 1 To Len(aItens)

                oItem := aItens[nX]

                cProduto   := oItem["codigoProduto"]
                cTes       := oItem["tes"]
                nValorItem := oItem["valor"]

                If Empty(cProduto) .And. Empty(cTes) .And. nValorItem <= 0
                        cMsgRet := "Existem inconsistencias no item " + cValToChar(nX) + "."
                        lRet := .F.
                    Exit
                EndIf

                aItem := {} 

                aAdd(aItem, {"C6_ITEM"   , StrZero(nItem, TamSx3("C6_ITEM")[1]), Nil})
                aAdd(aItem, {"C6_PRODUTO", cProduto, Nil})
                aAdd(aItem, {"C6_QTDVEN" , 1, Nil})
                aAdd(aItem, {"C6_PRCVEN" , nValorItem, Nil})
                aAdd(aItem, {"C6_QTDLIB" , 1, Nil})
                aAdd(aItem, {"C6_TES"    , cTes, Nil})
                aAdd(aItem, {"AUTDELETA" , "N", Nil})

                aAdd(aSC6, aClone(aItem))

                nItem++

            Next

            MsExecAuto({|x,y,z| MATA410(x,y,z)}, aSC5, aSC6, 3)

            If lMsErroAuto
                cFileLog := NomeAutoLog()
                If !Empty(cFileLog)
                    cMsgRet := MostraErro(cPath, cFileLog)
                EndIf
                lRet := .F.
                DisarmTransaction()
            Else
                cCodRet := SC5->C5_NUM
                GrvPedGrp(cOrdemServ, nGrupoId, cCodRet, nValorTotal)
                AtuSitOs(cOrdemServ)

                cMsgRet := 'Pedido gerado com sucesso.'
        
            EndIf
                
            (cAliasTmp)->(DbCloseArea())

        Else
            DisarmTransaction()
        EndIf   

    End Transaction

Return lRet

Static Function ExiPedGrp(cOrdemServ, nGrupoId)

    Local lExiste   := .F.
    Local aAreaJOO  := JOO->(GetArea())

    JOO->(dbSetOrder(1)) // FILIAL + CODJN3 + GRUPO

    If JOO->(dbSeek(xFilial("JOO") + cOrdemServ + StrZero(nGrupoId, 6)))
        lExiste := .T.
    EndIf

    RestArea(aAreaJOO)

Return lExiste

Static Function GrvPedGrp(cOrdemServ, nGrupoId, cNumPed, nValorTotal)

    Local lRet      := .T.
    Local aAreaJOO  := JOO->(GetArea())
    Local cGrupo    := StrZero(nGrupoId, 6)
    Local cCodJOO   := ""

    cCodJOO := GetSxEnum('JOO','JOO_CODIGO')
     
    JOO->(RecLock("JOO", .T.))
        JOO->JOO_FILIAL := xFilial("JOO")
        JOO->JOO_CODJN3 := cOrdemServ
        JOO->JOO_CODIGO := cCodJOO
        JOO->JOO_GRUPO  := cGrupo
        JOO->JOO_PEDIDO := cNumPed
        JOO->JOO_TOTAL  := nValorTotal
        JOO->JOO_STATUS := "1"
    JOO->(MsUnlock())

    ConfirmSX8() 
    
    RestArea(aAreaJOO)

Return lRet

Static Function AtuSitOs(cOrdemServ)

    Local lRet      := .F.
    Local aAreaJN3  := JN3->(GetArea())

    JN3->(dbSetOrder(1))

    If JN3->(dbSeek(xFilial("JN3") + cOrdemServ))
        JN3->(RecLock("JN3", .F.))
            JN3->JN3_SITUAC := "06"
        JN3->(MsUnlock())
        lRet      := .T.
    EndIf

    RestArea(aAreaJN3)

Return lRet
