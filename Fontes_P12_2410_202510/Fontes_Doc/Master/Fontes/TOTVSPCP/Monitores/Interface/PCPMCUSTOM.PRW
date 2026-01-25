#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"


/*/{Protheus.doc} PCPMCUSTOM
Fonte chamador da tela de Monitores Exclusivos do PCP em Po UI
@type Function
@author renan.roeder
@since 05/12/2023
@version P12.1.2410
@return Nil
/*/
Function PCPMCUSTOM()
    Local lAtual := .F.

    If AliasInDic("HZE")
        DbSelectArea("HZE")
        If HZE->(FieldPos("HZE_USUAR")) > 0
            lAtual := .T.
            If PCPVldApp(.T.)
                FwCallApp("totvs-supply-monitor-custom")
            EndIf
        EndIf
    EndIf
    If !lAtual
        Help(,,"Help",,STR0232,1,0) //"Dicionário de dados não atualizado com as tabelas do programa!"
    EndIf
Return
