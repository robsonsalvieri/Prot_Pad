#include "protheus.ch"

/*/{Protheus.doc} PLSA777
Tela de Cadastro de Alertas (PO UI)

@type function
@author Nicole Luna
@since 25/07/2024
@version Protheus 12
/*/
Function PLSA777()
    
    If ReqMinimos()
        FWCallApp("plsa777")
    Else 
        FWAlertWarning("Ambiente desatualizado, verifique os requisitos mínimos na documentação do Cadastro de Alertas (PO UI)", "Cadastro de Alertas")
    EndIf
    
Return

Static Function ReqMinimos()

    Local lValid := .F.

    lValid := FindFunction("AmIOnRestEnv") .And. AmIOnRestEnv()

Return lValid

Static Function JsToAdvpl(oWebChannel, cType, cContent)
Return
