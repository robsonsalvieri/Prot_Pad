#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV030 - Invoices x Income Nature
    Relação de Notas Fiscais x Naturezas de Rendimentos
@since 31/01/2024
/*/
//-------------------------------------------------------------------
Function COMSV030()

	//1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
	//2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
	//Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
	//ljob := .F.	

	totvs.framework.treports.callTReports("backoffice.sv.com.invoicesxincomenaturelist",,,,,.F.,,.T.,)

Return 
