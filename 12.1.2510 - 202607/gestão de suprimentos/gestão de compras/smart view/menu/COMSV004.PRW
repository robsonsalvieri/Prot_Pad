#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV004 - Mapa de Contratos 
chamada para os relatorios backoffice.sv.com.mapofcontracts.tlpp
@since 21/09/2023
/*/
//-------------------------------------------------------------------
Function COMSV004()
Local lSuccess As Logical

   //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
   //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
   //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
   //ljob := .F.	

    lSuccess := totvs.framework.treports.callTReports("backoffice.sv.com.mapofcontracts",,,,,.F.,,.T.,)

Return lSuccess

