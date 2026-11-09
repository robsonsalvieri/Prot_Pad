#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FsmOrdemServicoPostLote()
Função que gera ordem de serviço em lote
@author fernanda.rigolin
@since 06/07/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function FsmGerarOsLote(oRequest, oResponse, cMsgRet)

    Local lRet      := .T.
    Local nItem     := 0
    Local oModel    := Nil
    Local oItem     := Nil
    Local cMsgErro  := ""

    oResponse["status"]  := "success"
    oResponse["message"] := EncodeUtf8("Ordens de serviço geradas com sucesso")
    oResponse["data"]    := {}

    BEGIN TRANSACTION

        For nItem := 1 To Len(oRequest)

            oItem := oRequest[nItem]
            oModel := FWLoadModel("FSMA008")

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate()

            lRet := GrvOrdServLote(oModel, oItem, @cMsgErro)

            If lRet
                AAdd(oResponse["data"], JsonObject():New())

                oResponse["data"][Len(oResponse["data"])]["filial"] := ;
                    oModel:GetValue("JN3MASTER","JN3_FILIAL")

                oResponse["data"][Len(oResponse["data"])]["codigoOrdem"] := ;
                    oModel:GetValue("JN3MASTER","JN3_CODIGO")
                oModel:Deactivate()
            Else
                oModel:Deactivate()
                DisarmTransaction()
                cMsgRet := cMsgErro
                Exit
            Endif

        Next
    END TRANSACTION
Return lRet

Static Function GrvOrdServLote(oModel, oRequest, cMsgError)
    Local nServico  := 0
    Local aAreaJOK  := Nil

    oModel:SetValue("JN3MASTER","JN3_CODIGO",GetSxEnum("JN3","JN3_CODIGO"))
    ConfirmSx8()

    oModel:SetValue("JN3MASTER","JN3_CLIENT" ,oRequest["codigoCliente"])
    oModel:SetValue("JN3MASTER","JN3_LOJA"   ,oRequest["lojaCliente"])
    oModel:SetValue("JN3MASTER","JN3_CODPRO" ,oRequest["codigoProduto"])
    oModel:SetValue("JN3MASTER","JN3_NUMSER" ,oRequest["idUnico"])
    oModel:SetValue("JN3MASTER","JN3_DTPREV" ,StoD(oRequest["dataPrevista"]))

    oModel:SetValue("JN3MASTER","JN3_CODJOK" ,oRequest["tipoOcorrencia"])
    oModel:SetValue("JN3MASTER","JN3_CODJOJ" ,oRequest["tipoAtendimento"])

    oModel:SetValue("JN3MASTER","JN3_PRIORI" ,oRequest["prioridade"])
    oModel:SetValue("JN3MASTER","JN3_CODJOQ" ,oRequest["codigoPlano"])
    oModel:SetValue("JN3MASTER","JN3_CODJOS" ,oRequest["codigoVincPlanoEquip"])
    oModel:SetValue("JN3MASTER","JN3_USUINC" ,oRequest["usuarioInclusao"])
    oModel:SetValue("JN3MASTER","JN3_ATEINT" ,oRequest["atendimentoInterno"])
    


    If Empty(oModel:GetValue("JN3MASTER","JN3_CODJOJ"))

        aAreaJOK := JOK->(GetArea())

        JOK->(dbSetOrder(1))

        If JOK->(dbSeek(xFilial("JOK")+oRequest["tipoOcorrencia"]))
            oModel:SetValue("JN3MASTER","JN3_CODJOJ",JOK->JOK_CODJOJ)
        EndIf

        RestArea(aAreaJOK)

    EndIf

    For nServico := 1 To Len(oRequest["servicosOrdem"])

        If nServico > 1
            oModel:GetModel("JN4DETAIL"):AddLine()
        EndIf

        oModel:SetValue("JN4DETAIL","JN4_CODJN3",oModel:GetValue("JN3MASTER","JN3_CODIGO"))
        oModel:SetValue("JN4DETAIL","JN4_CODJN1",oRequest["servicosOrdem"][nServico]["codigoServico"])
        oModel:SetValue("JN4DETAIL","JN4_CHKOBR",oRequest["servicosOrdem"][nServico]["checklist"])
        oModel:SetValue("JN4DETAIL","JN4_OBSERV",oRequest["servicosOrdem"][nServico]["observacao"])
        oModel:SetValue("JN4DETAIL","JN4_CODJOR",oRequest["servicosOrdem"][nServico]["codigoVincPlanoServ"])

        JN1->(dbSetOrder(1))

        If JN1->(dbSeek(xFilial("JN1")+oModel:GetValue("JN4DETAIL","JN4_CODJN1")))
            oModel:SetValue("JN4DETAIL","JN4_CODPRO",JN1->JN1_CODPRO)
            oModel:SetValue("JN4DETAIL","JN4_VALOR" ,JN1->JN1_VALOR)
        EndIf

        If !oModel:GetModel("JN4DETAIL"):VldLineData()
            cMsgError := oModel:GetErrorMessage()[6]
            Return .F.
        EndIf

    Next

    oModel:SetValue("JN3MASTER","JN3_SITUAC","00")

    If oModel:VldData()
        oModel:CommitData()
    Else
        cMsgError := oModel:GetErrorMessage()[6]
        Return .F.
    EndIf
Return .T.
