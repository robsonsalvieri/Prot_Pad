#include 'protheus.ch'
#include 'fwmvcdef.ch'
#INCLUDE "COMSV031.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV031 - Input and Output Types
    Tipos de Entrada e Saída
@since 31/01/2024
/*/
//-------------------------------------------------------------------
Function COMSV031()

    If cPaisLoc == "BRA"

    //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
    //2º parâmetro = Tipo do relatório ("reports" = relatório comum, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
    //3º parâmetro = Tipo do impressão (Arquivo=1, Email=2)
    //4º parâmetro = Informações de impressão
    //5º parâmetro = Parâmetros do relatório
    //6º parâmetro = Indica se executa em job
    //7º parâmetro = Indica se exibe os parâmetros para preenchimento
    //8º parâmetro = Indica se exibe o wizard de configuração do Smart View
    //9º parâmetro = Erro da execução
        totvs.framework.treports.callTReports('backoffice.sv.com.inputoutputtypes',,,,,.F.,,,)
    Else
        Help(" ", 1, STR0001, , STR0002, 1, 1) //"Aviso" |"Esta Rotina está disponível somente para ambiente Brasil"
    EndIf

return
