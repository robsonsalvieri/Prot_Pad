#include "totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FATSV009
Fonte de menu para chamada dos artefatos do SMartView para 
Faturamento por Cliente X Quantidade de Produtos

@author FAT/CRM
@since 22/09/2023
@version 1.0
*/
//-------------------------------------------------------------------  

Function FATSV009()

//1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
//2º parâmetro = Tipo do relatório ("reports" = relatório comum, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
//3º parâmetro = Tipo do impressão (Arquivo=1, Email=2)
//4º parâmetro = Informações de impressão
//5º parâmetro = Parâmetros do relatório
//6º parâmetro = Indica se executa em job
//7º parâmetro = Indica se exibe os parâmetros para preenchimento
//8º parâmetro = Indica se exibe o wizard de configuração do Smart View
//9º parâmetro = Erro da execução

totvs.framework.treports.callTReports("backoffice.sv.fat.salesstatistics",,,,,.F.)

Return
