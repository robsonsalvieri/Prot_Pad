#Include "protheus.ch"
#INCLUDE "AGDI095.CH"

/*/{Protheus.doc} AGDI095
Função chamada pelo nfesefaz
@type function
@version 12
@author jean.schulze/carlos.augusto/joao.vtargino
@since 10/10/2025
@param cInfoCPL, character, Informacoes complementares da nf (infCPL)
/*/
Function AGDI095(nRecnoSF2)
	Local aAreaSF2 := SF2->(GetArea())
    Local aAreaSD2 := SD2->(GetArea())
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSF4 := SF4->(GetArea())
    Local aArea    := GetArea()
    Local cInfoCPL := ""
    
    If SUPERGETMV("MV_SIGAAGD", .F., .F.)
        cInfoCPL += AGDI095RCT(nRecnoSF2)
        cInfoCPL += AGDI095EMB(nRecnoSF2)
    Endif

    RestArea(aArea)
    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aAreaSC5)
    RestArea(aAreaSF4)
Return cInfoCPL


/*/{Protheus.doc} AGDI095RCT
Gera informacoes do numeros de receituario agronomico
@type function
@version 12
@author carlos.augusto
@since 10/10/2025
@param cInfoCPL, character, receituarios cadastrados para a NF
/*/
Function AGDI095RCT(nRecnoSF2)
    Local cReceiAgro := ""

    SF2->(DbGoTo(nRecnoSF2))
    If TableInDic('NES')
        NES->(DbSetOrder(1))
        If NES->(DBSeek(FwxFilial('NES') + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
            While NES->(!EoF()) .And. FwxFilial('NES') == NES->NES_FILIAL .And. NES->NES_DOC == SF2->F2_DOC .And. ;
                NES->NES_SERIE == SF2->F2_SERIE .And. NES->NES_CLIENT == SF2->F2_CLIENTE .And. NES->NES_LOJA == SF2->F2_LOJA
                If Empty(cReceiAgro)
                    cReceiAgro += STR0001 + AllTrim(NES->NES_NUMREC) //"Número Receituário Agronômico: "
                Else
                    cReceiAgro += ',' + AllTrim(NES->NES_NUMREC)
                EndIf
                NES->(DbSkip())
            End
            cReceiAgro += '. '
        EndIf
    EndIf

Return cReceiAgro


/*/{Protheus.doc} AGDI095EMB

@type function
@version 12
@author joao.vtargino
@since 10/10/2025
@param cInfoCPL, character, Informacoes complementares da nf (infCPL)
/*/
Function AGDI095EMB(nRecnoSF2)
    Local cDescEmb := "" 

    SF2->(DbGoTo(nRecnoSF2))
    SD2->(DbSetOrder(3))
    If SD2->(DBSeek(FwxFilial('SD2') + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
        If TableInDic('NEQ')
            NEQ->(DbSetOrder(1))
            If NEQ->(DBSeek(FwxFilial('NEQ') + SD2->D2_PEDIDO))
                If TableInDic('NEO')
                    NEO->(DbSetOrder(1))
                    If NEO->(DBSeek(FwxFilial('NEO') + NEQ->NEQ_CODDES))
                    
                        cDescEmb += STR0002 + AllTrim(NEO->NEO_NOME) +", " + AllTrim(NEO->NEO_ENDERE)+", " + AllTrim(NEO->NEO_NUMERO) + ", "+;       //"Local de descarte de embalagens vazias:"
                        AllTrim(NEO->NEO_BAIRRO) + ", " + AllTrim(NEO->NEO_DDD) + AllTrim(NEO->NEO_TEL) + ", " +;
                        AllTrim(POSICIONE("CC2", 1, XFILIAL("CC2")+NEO->NEO_EST+NEO->NEO_CODMUN, "CC2_MUN")) + "/" + AllTrim(NEO->NEO_EST)//"Complemento de info na NF"
    
                    EndIf
                EndIf
            Endif
        Endif
    Endif
Return cDescEmb
