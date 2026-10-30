#include 'ubaw19.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

WSRESTFUL UBAW19 DESCRIPTION "Blocos"

WSMETHOD POST   block DESCRIPTION "Blocos"  PATH "/v1/block" PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD POST block WSREST UBAW19

    Local oRequest    := JsonObject():New()
    Local lPost       := .T.
    Local cSafra      := "" // safra
    Local cBloco      := "" // bloco
    Local cLote       := "" // lote
    Local cLtPrdAcb   := "" // loteProdutoAcabado
    Local cDatEmb     := "" // dataEmblocamento
    Local cHraEmb     := "" // horaEmblocamento
    Local cQtdMax     := "" // quantidadeMaxima
    Local cClasVis    := "" // classificacaoVisual
    Local cAction     := "" // operacao

    // define o tipo de retorno do m‚todo
    ::SetContentType("application/json")

    oRequest:fromJson(::GetContent())

    cSafra    := oRequest["safra"]
    cBloco    := oRequest["numeroBloco"]
    cLote     := oRequest["lote"]
    cLtPrdAcb := oRequest["loteProdutoAcabado"]
    cDatEmb   := StoD(StrTran(substr(oRequest['dataEmblocamento'],1,10),"-",""))
    cHraEmb   := oRequest["horaEmblocamento"]
    cQtdMax   := oRequest["quantidadeMaxima"]
    cClasVis  := oRequest["classificacaoVisual"]
    cAction   := UPPER(oRequest["operacao"])

    cSafra    := Padr(cSafra, TamSX3("DXD_SAFRA")[1])
    cBloco    := Padr(cBloco, TamSX3("DXD_CODIGO")[1])
    cLote     := Padr(cLote,  TamSX3("DXI_ETIQ")[1])

    BEGIN TRANSACTION

        dbSelectArea("DXD") //Blocos
        DXD->(dbSetOrder( 1 )) //DXD_FILIAL+DXD_SAFRA+DXD_CODIGO
        If !DXD->(dbSeek(FWxFilial("DXD") + cSafra + cBloco ))
            RecLock("DXD", .T.)
            DXD->DXD_FILIAL  := xFilial("DXD")
            DXD->DXD_SAFRA   := cSafra
            DXD->DXD_CODIGO  := cBloco
            DXD->DXD_DATAEM  := cDatEmb
            DXD->DXD_CLACOM  := cClasVis
            DXD->DXD_QTDMAX  := val(cQtdMax)
        Else
            RecLock("DXD", .F.)
            DXD->DXD_CLACOM := cClasVis
            DXD->DXD_QTDMAX := val(cQtdMax)
        EndIf

        If !Empty(cLote)
            dbSelectArea("DXI") //Fardos
            DXI->(dbSetOrder( 1 )) //DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
            If DXI->(dbSeek(FWxFilial("DXI") + cSafra + cLote))

                If cAction = "DELETE"
                    If val(DXI->DXI_STATUS) > 40
                        lPost := .F.
                        SetRestFault(400, EncodeUTF8(STR0002 + Alltrim(cSafra) + "/" + cLote + "-" + FWGetSX5("KE", DXI->DXI_STATUS)[1][4]) ) //Lote nÆo pode ser retirado do bloco devido ao seu status
                        DisarmTransaction()
                        break
                    EndIf

                    RecLock("DXI", .F.)
                    DXI->DXI_BLOCO  := ""
                    DXI->DXI_DATATU := Nil
                    DXI->DXI_HORATU := Nil
                    DXI->DXI_STATUS := "20" //CLASSIFICADO
                Else
                    If  !Empty(DXD->DXD_CLACOM) .And. DXD->DXD_CLACOM <> DXI->DXI_CLAVIS
                        lPost := .F.
                        SetRestFault(400, EncodeUTF8(STR0004) + DXI->DXI_CLAVIS) //Classifica‡Æo visual do Lote diferente do bloco
                        DisarmTransaction()
                        break
                    Elseif !Empty(DXI->DXI_BLOCO) .And. DXI->DXI_BLOCO <> cBloco
                        lPost := .F.
                        SetRestFault(400, EncodeUTF8(STR0005) + cLote + "-" + DXI->DXI_BLOCO) //Lote informado j  est  vinculado ao bloco
                        DisarmTransaction()
                        break
                    Endif

                    RecLock("DXI", .F.)
                    DXI->DXI_BLOCO  := cBloco
                    DXI->DXI_DATATU := dDatabase
                    DXI->DXI_HORATU := Time()
                    DXI->DXI_STATUS := "30" //EMBLOCADO
                    If Empty(DXI->DXI_CODPRO)
                        DXI->DXI_CODPRO := cLtPrdAcb
                    Endif
                EndIf

                DXI->(MsUnlock())
            Else
                lPost := .F.
                SetRestFault(400, EncodeUTF8(STR0001 + Alltrim(cSafra) + "/" + cLote))  //Safra/Lote nÆo encontrado na DXI
                DisarmTransaction()
                break
            Endif

            DXI->(dbCloseArea())
        EndIf
 
        DXD->DXD_QTDVNC := UBAW19QTDFRDBLK()

        If DXD->DXD_QTDVNC == 0
            DXD->DXD_STATUS  := "1"  //Vazio
        ElseIf DXD->DXD_QTDVNC < DXD->DXD_QTDMAX
            DXD->DXD_STATUS  := "2"  //Iniciado
        ElseIf DXD->DXD_QTDVNC == DXD->DXD_QTDMAX
            DXD->DXD_STATUS  := "3"  //Finalizado
        Else
            lPost := .F.
            SetRestFault(400, EncodeUTF8(STR0003 + " " + Alltrim(cSafra) + "/" + cLote))  //Quantidade de lotes alocados ‚ superior a quantidade maxima permitida para o bloco
            DisarmTransaction()
            break
        Endif

        DXD->(MsUnlock())

        DXD->(dbCloseArea())
    
    END TRANSACTION

Return lPost

/**---------------------------------------------------------------------
{Protheus.doc} UBAW19QTDFRDBLK
Retorna a quantidade de fardos pertencentes ao bloco

@param: Nil
@author: Gilson Venturi
@since: 23/04/2024
@return: Qtde Fardos Alocados
---------------------------------------------------------------------**/
Function UBAW19QTDFRDBLK()
    Local cAliasQry := GetNextAlias()
    Local cQry      := ""
    Local nRet      := 0
    Local aArea     := GetArea()

    cQry := "SELECT COUNT(DISTINCT DXI_ETIQ) TOTAL "
    cQry += "FROM " + RetSqlName("DXI") + " DXI "
    cQry += "WHERE DXI.DXI_FILIAL = '"+xFilial("DXI")+"' "
    cQry += "AND DXI.DXI_SAFRA = '"+DXD->DXD_SAFRA+"' "
    cQry += "AND DXI.DXI_BLOCO = '"+DXD->DXD_CODIGO+"' "
    If !Empty(DXD->DXD_CODUNB)
        cQry += "AND DXI.DXI_CODUNB = '"+DXD->DXD_CODUNB+"' "
    Endif
    cQry += "AND DXI.D_E_L_E_T_ = ''"

    cQry := ChangeQuery( cQry )

    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

    nRet:= (cAliasQry)->TOTAL

    (cAliasQry)->(DbCloseArea())

    RestArea(aArea)
Return(nRet)
