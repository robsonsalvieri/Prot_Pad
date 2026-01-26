#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV020
chamada para os relatorios backoffice.sv.com.openquotes
- Relação de Cotações em Aberto
@since 22/09/2023
/*/
//-------------------------------------------------------------------
Function COMSV020() 

   //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
   //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
   //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
   //ljob := .F.	
   totvs.framework.treports.callTReports("backoffice.sv.com.openquotes",,,,,.F.,,,)
    

		
Return

