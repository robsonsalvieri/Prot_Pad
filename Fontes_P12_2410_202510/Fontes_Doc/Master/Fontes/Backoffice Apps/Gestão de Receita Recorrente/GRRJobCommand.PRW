#INCLUDE "protheus.ch"
#INCLUDE "GRRJobCommand.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRJobCommand
Função chamada pelo Schedule para execução das rotinas de sincronismo entre o Protheus
e a plataforma GRR

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada por
User Function

@author  Marcia Junko
@since   19/04/2022
/*/
//-------------------------------------------------------------------
Function GRRJobCommand( aParam, cFil )
    // Local cLock         := "GRRJobCommand"
    Local lJob := .F.
     
    Default aParam := nil 
    Default cFil := NIL
    
    lJob := GRRProcJob( aParam, cFil )

    If GRRIsActive()           

        //--------------------------------------------------------------
        // Se for conciliação, troca o nome para não travar as execuções do JOB Command.
        //--------------------------------------------------------------
        // If lConciliation
        //     cLock := "GRRJobBank"   
        // EndIf

        //--------------------------------------------------------------
        // OBS: As travas de execução das rotinas estão concentradas nas
        // funções GRRSyncExec e GRRSyncTime que devem ser chamadas para
        // controlar todos os fluxos de sincronismo. Sendo assim, não é
        // necessário realizar o controle do LockbyName diretamente pelo
        // jobCommand.
        //--------------------------------------------------------------

        //--------------------------------------------------------------
        // Sincroniza os produtos selecionados com a plataforma e considera
        // o conteúdo do campo S_T_A_M_P_
        //--------------------------------------------------------------     
        GRRI020( NIL, NIL, NIL, .T. )

        //--------------------------------------------------------------
        // Sincroniza os planos e itens da plataforma com o Protheus
        //--------------------------------------------------------------     
        GRRI030()
        
        //--------------------------------------------------------------
        // Libera os pedidos pagos no GRR
        //--------------------------------------------------------------   
        GRRI060()
        
        //--------------------------------------------------------------
        // Movimenta os títulos financeiros
        //--------------------------------------------------------------     
        //// GRRI070()
        GRRI070A()

        //--------------------------------------------------------------
        // Gera os pedidos de venda baseado nas faturas da plataforma
        //--------------------------------------------------------------     
        GRRI080()

        
        //--------------------------------------------------------------
        // Envia os documentos para a plataforma do Provider Protheus
        //--------------------------------------------------------------     
        GRRI090()

        //--------------------------------------------------------------
        // Busca titulos pagos no protheus para envio da plataforma.
        //--------------------------------------------------------------     
        GRRI100()

        //--------------------------------------------------------------
        // Integração com o SIGAFIN
        //--------------------------------------------------------------
        if VldGRRI110()
            GRRI110()
        endIf

    EndIf  

    If lJob  
        RPCClearEnv()        
    EndIF
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGRRI110
Valida se pode executar a integração da carteira (GRRI110)
@author  Claudio Yoshio Muramatsu
@since   08/09/2025
/*/
//-------------------------------------------------------------------
static function VldGRRI110()

    if GetRpoRelease() <= "12.1.2510" .and.;
       ( !FindFunction("GRRI110") .or. !findClass("totvs.protheus.backoffice.apps.grr.integration.financial.Validations") .or. !findClass("totvs.protheus.backoffice.apps.grr.general.FlowControl") )
        FwLogMsg("INFO", , "GRRJobCommand", "", "", "GRRJobCommand", "", , , {{"function","GRRJobCommand"}, {"error", STR0001}}) //"Pacote de expedição contínua do Gestão de Contratos desatualizado. Atualize para a versão compatível antes de executar o GRRI110."
        return .F.
    endif

    if !totvs.protheus.backoffice.apps.grr.integration.financial.Validations():hasWalletRepositoryRequirements()
        totvs.protheus.backoffice.apps.grr.general.FlowControl():logMessage({{"function","GRRJobCommand"}, {"error", STR0002 }}) //"Versão do FINA040 desatualizada. Atualize para a versão compatível antes de executar o GRRI110."
        return .F.
    endif

return .T.
