#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV027 -  Listagem de Cotações em Aberto
Chamada para os relatorios backoffice.sv.com.listofopenquotes

@since 08/11/2023
/*/
//-------------------------------------------------------------------
Function COMSV027()

    //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
    //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
    //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
    //ljob := .F.	
    totvs.framework.treports.callTReports("backoffice.sv.com.listofopenquotes",,,,,.F.,,.T.,)

Return

