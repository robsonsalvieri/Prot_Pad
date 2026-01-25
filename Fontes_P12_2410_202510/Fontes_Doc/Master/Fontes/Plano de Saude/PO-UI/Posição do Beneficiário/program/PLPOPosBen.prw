#include "protheus.ch"

/*/{Protheus.doc} PLPOPosBen
Tela da posição do beneficiário (PO UI)

@type function
@author Robson Nayland
@since 16/12/2022
@version Protheus 12
/*/
Function PLPOPosBen()
    
    If ReqMinimos()
        FWCallApp("PLPOPosBen")
    Else 
        FWAlertWarning(DecodeUtf8("Ambiente desatualizado, verifique os requisitos mínimos na documentação da Posição do Beneficiário (PO UI)"), DecodeUtf8("Posição do Beneficiário"))
    EndIf
    
Return

/*/{Protheus.doc} ReqMinimos
Requisitos minimos para acessar Tela da posição do beneficiário (PO UI)

@type function
@author Robson Nayland
@since 16/12/2022
@version Protheus 12
/*/
Static Function ReqMinimos()

    Local lValid := .F.

    lValid := FindFunction("AmIOnRestEnv") .And. AmIOnRestEnv()

Return lValid

/*/{Protheus.doc} JsToAdvpl
Configuração do preLoad do sistema para enviar para o frontEnd (PO Ui)

@type function
@author Robson Nayland
@since 16/12/2022
@version Protheus 12
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
Return
