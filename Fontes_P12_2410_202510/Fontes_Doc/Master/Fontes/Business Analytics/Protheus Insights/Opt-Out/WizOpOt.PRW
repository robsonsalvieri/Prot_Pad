#INCLUDE "TOTVS.CH"
#INCLUDE "wizardopt.ch"

//https://tdn.totvs.com/pages/releaseview.action?pageId=6814850
//https://www.blogadvpl.com/glossario/pswadmin/#page-content
//https://tdn.totvs.com/display/public/framework/FWWizardStep

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Wizard Opt-Out
Função de criação do Wizard Opt-Out SmartLink

@author  DANILO SANTOS
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Main Function WizardOpt()
    //RpcSetEnv("T1", "D MG 01", "admin","1234")
    MsApp():New( 'SIGAFIN' )
    oApp:cInternet  := Nil
    __cInterNet := NIL
    oApp:bMainInit  := { || ( oApp:lFlat := .F. , OptOutWiz(), Final( STR0001 , "" )  ) }  //"Encerramento Normal"
    oApp:CreateEnv()
    OpenSM0()   

    PtSetTheme( "TEMAP10" )
    SetFunName( "UPDDISTR" )
    oApp:lMessageBar := .T.

    oApp:Activate()

RETURN 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OptOutWiz 
Função de criação do Wizard do GRR

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Static Function OptOutWiz()
    Local oComponent
    Local aWelcome := {}
    Local cText := STR0002 + CRLF + CRLF + STR0003
 
    aWelcome := { cText }

    oComponent := WizardOutPut():New( )
    oComponent:SetWelcome( aWelcome )
    oComponent:SetFinish( { || .T. } )
    oComponent:CreateWizOpt( oApp )
    oComponent:Destroy()
    FreeObj( oComponent )
Return 

