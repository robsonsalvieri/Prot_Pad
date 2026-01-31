#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEXFUNH.CH"
//------------------------------------------------------------------------------------------------
/* Funções de utilidade de pré-validação                          								*/
//------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEPreVld
Função de Pré-Validação de dados importação

@author Daniel Leme
@since 09/11/2022
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEPreVld(cAcao,oJsonPre,oJsonCGC)
    Local lRet      := .T.
    Local aAreas    := {GU3->(GetArea()),;
                        GU7->(GetArea()),;
                        GetArea()}
    Local aCposGU3  := {}
    Local nCnt      := 0

    If cAcao == "NFS" .Or. cAcao == "NFE"
        //-- Validação GU3
        aCposGU3 := {"GW1_CDREM","GW1_EMISDC","GW1_CDDEST"}
        oJsonPre["MSGERR"] := ""

        For nCnt := 1 To Len(aCposGU3)
            If lRet
                If Empty(oJsonPre[aCposGU3[nCnt] ])
                    oJsonPre["MSGERR"] += Trim(FWX3Titulo(aCposGU3[nCnt])) + " " + STR0001 + " - CGC: " + oJsonCGC[aCposGU3[nCnt]] //--"não preenchido"
                    lRet := .F.
                Else
                    GU3->(DbSetOrder(1)) 
                    If !GU3->(DbSeek(xFilial("GU3")+oJsonPre[aCposGU3[nCnt]]))
                        oJsonPre["MSGERR"] += Trim(FWX3Titulo(aCposGU3[nCnt])) + " " + STR0002 + " - " + oJsonPre[aCposGU3[nCnt]]  + " - CGC: " + oJsonCGC[aCposGU3[nCnt]] //--"não encontrado"
                        lRet := .F.
                    ElseIf GU3->GU3_SIT == "2"
                        oJsonPre["MSGERR"] += Trim(FWX3Titulo(aCposGU3[nCnt])) + " " + STR0003 + " - Emitente: " + oJsonPre[aCposGU3[nCnt]] //--"não está ativo no cadastro de emitentes"
                        lRet := .F.
                    EndIf

                    //-- Valida o campo NRCID do registro na GU3
                    If GU3->(Found())
                        oJsonPre["GU3_NRCID"] := GU3->GU3_NRCID
                        lRet := lRet .And. JSonVldGU7(@oJsonPre,"GU3_NRCID",oJsonPre[aCposGU3[nCnt]],.T.)
                    EndIf
                EndIf
            EndIf
        Next nCnt

        If lRet
            //-- Validação GU7
            lRet := lRet .And. JSonVldGU7(@oJsonPre,"GW1_ENTNRC","",.F.)
        EndIf
    ElseIf cAcao == "GU3"
        oJsonPre["MSGERR"] := ""
        //-- Validação GU7
        lRet := lRet .And. JSonVldGU7(@oJsonPre,"GU3_NRCID","",.T.)
    EndIf

    aEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
    FwFreeArray(aAreas)
    FwFreeArray(aCposGU3)
Return lRet

/*/{Protheus.doc} JSonVldGU7
Função de Pré-Validação na tabela GU7 para o JSon

@author Daniel Leme
@since 09/11/2022
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function JSonVldGU7(oJsonPre,cCampo,cMsgCompl,lVldEmpty)
    Local lRet := .T.

    If lVldEmpty .And. Empty(oJsonPre[cCampo])
        oJsonPre["MSGERR"] += Trim(FWX3Titulo(cCampo)) + " " + STR0001 + " - Emitente: " + cMsgCompl //--"não preenchido"
        lRet := .F.
    ElseIf !Empty(oJsonPre[cCampo])
        GU7->(DbSetOrder(1)) 
        If !GU7->(DbSeek(xFilial("GU7")+oJsonPre[cCampo]))
            oJsonPre["MSGERR"] += Trim(FWX3Titulo(cCampo)) + " " + STR0002 + " - Cidade: " + oJsonPre[cCampo] + " - Emitente: " + cMsgCompl //--"não encontrado"
            lRet := .F.
        ElseIf GU7->GU7_SIT == "2"
            oJsonPre["MSGERR"] += Trim(FWX3Titulo(cCampo)) + " " + STR0004 + " - Cidade: " + oJsonPre[cCampo] + " - Emitente: " + cMsgCompl //--"não está ativo no cadastro de cidades"
            lRet := .F.
        EndIf
    EndIf
Return lRet
