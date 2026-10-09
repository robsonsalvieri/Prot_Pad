#include "totvs.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} FATSV038
Chamada do objeto de negócio Curva ABC por Região(SmartView)

@author FAT/CRM
@since 21/09/2023
@version 1.0
*/
//------------------------------------------------------------------- 
Function FATSV038()

    //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
    //2º parâmetro = Tipo do relatório ("reports" = relatório comum, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
    //3º parâmetro = Tipo do impressão (Arquivo=1, Email=2)
    //4º parâmetro = Informações de impressão
    //5º parâmetro = Parâmetros do relatório
    //6º parâmetro = Indica se executa em job
    //7º parâmetro = Indica se exibe os parâmetros para preenchimento
    //8º parâmetro = Indica se exibe o wizard de configuração do Smart View
    //9º parâmetro = Erro da execução
    totvs.framework.treports.callTReports("backoffice.sv.fat.stockabccurve",,,,,.F.,,,)

return
