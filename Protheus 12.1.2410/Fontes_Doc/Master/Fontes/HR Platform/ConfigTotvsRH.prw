#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} function ConfigTotvsRH
Configurador para comunicação com as integrações do HR Platform.
@author  Hugo de Oliveira
@since   28/08/2024
@version 1.0
/*/
MAIN Function ConfigTotvsRH()
    MsApp():New("SIGAGPE")
    oApp:cInternet  := Nil
    __cInterNet     := NIL
    oApp:bMainInit  := { || ( oApp:lFlat := .F., fOpenConfig(), Final( "Encerramento Normal", ""))}
    oApp:CreateEnv()
    OpenSM0()
    PtSetTheme("TEMAP10")
    SetFunName("UPDDISTR")
    oApp:lMessageBar := .T.
    oApp:Activate()
Return


/*/{Protheus.doc} function fOpenConfig
Inicia o processamento do configurador.
@author  Flavio Correa
@since   28/08/2024
@version 1.0
/*/
Static Function fOpenConfig()
    Local oWizard       As Object
    Local bConstruction As CodeBlock
    Local bNextAction   As CodeBlock
    Local bPrevWhen     As CodeBlock
    Local bCancelWhen   As CodeBlock
    Local aParam        As Array
    Local cReqDes       As Character
    Local cReqCont      As Character
    Local bReqVld       As CodeBlock
    Local cReqMsg       As Character

    oWizard := FWCarolWizard():New()
    bConstruction := { || }
    bNextAction   := { || .T.}
    bPrevWhen     := { || .F. }
    bCancelWhen   := { || .T. }

    cReqDes  := "Release do RPO"
    cReqCont := GetRpoRelease()
    bReqVld  := { || GetRpoRelease() >= "12.1.023" }
    cReqMsg  := "Versão de RPO deve ser no mínimo 12.1.23"

    oWizard:SetWelcomeMessage("Bem vindo ao assistente de configuração do Totvs RH com o Smartlink!"+chr(10)+chr(10)+"Ao final da configuração seu ERP estará pronto para enviar dados para os Aplicativos TOTVS.")
    oWizard:AddRequirement(cReqDes, cReqCont, bReqVld, cReqMsg)
    oWizard:UsePlatformAccess(.T.) // Valor .F. não recupera credenciais das Integrações.

    oWizard:Activate()
Return
