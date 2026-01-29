#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV010 - ficha cadastral (clientes)
chamada para os relatorios backoffice.sv.com.customerregistrationform.tlpp - COMSV010
@since 21/09/2023
/*/
//-------------------------------------------------------------------
Function COMSV010()
Local lSuccess As Logical

   //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
   //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
   //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
   //ljob := .F.	

    lSuccess := totvs.framework.treports.callTReports("backoffice.sv.com.customerregistrationform",,,,,.F.,,.T.,)

Return lSuccess

