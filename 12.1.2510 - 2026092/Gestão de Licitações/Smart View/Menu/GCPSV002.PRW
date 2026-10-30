#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSV002 - Quadro do Edital   
chamada para os relatorios backoffice.sv.gcp.announcementtable.batch.tlpp - GCPSV002
                           backoffice.sv.gcp.announcementtable.item.tlpp - GCPSV002
- Ficha cadastral de fornecedores
@since 22/09/2023
/*/
//-------------------------------------------------------------------
Function GCPSV002() 

   //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
   //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
   //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`

   totvs.framework.treports.callTReports("backoffice.sv.gcp.announcementtable",,,,,.F.,,,)

		
Return

