#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMSV002
Fonte de menu para chamada dos artefatos do SmartView para 
listagem de processos de venda.

@author FAT/CRM
@since 21/09/2023
@version 1.0
*/
//-------------------------------------------------------------------  
Function CRMSV002()

//1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
//2º parâmetro = Tipo do relatório ("reports" = relatório comum, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
//3º parâmetro = Tipo do impressão (Arquivo=1, Email=2)
//4º parâmetro = Informações de impressão
//5º parâmetro = Parâmetros do relatório
//6º parâmetro = Indica se executa em job
//7º parâmetro = Indica se exibe os parâmetros para preenchimento
//8º parâmetro = Indica se exibe o wizard de configuração do Smart View
//9º parâmetro = Erro da execução

totvs.framework.treports.callTReports("backoffice.sv.crm.listofsalesprocesses",,,,,.F.)


Return
