#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSV001 - Extrato de Homologacao  
chamada para os relatorios backoffice.sv.gcp.approvalstatement.tlpp
@since 21/09/2023
/*/
//-------------------------------------------------------------------
Function GCPSV001()

   //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
   //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
   //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
 
    totvs.framework.treports.callTReports("backoffice.sv.gcp.approvalstatement",,,,,.F.,,.T.,)

Return

