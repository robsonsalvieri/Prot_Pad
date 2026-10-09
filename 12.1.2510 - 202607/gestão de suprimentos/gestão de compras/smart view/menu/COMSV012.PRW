#include "protheus.ch"
#include "fwmvcdef.ch"
#INCLUDE "COMSV012.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV012 -  Relação de Notas Fiscais
chamada para os relatorios backoffice.sv.com.invoicelist 
@since 21/09/2023
/*/
//-------------------------------------------------------------------
Function COMSV012()

    If cPaisLoc == "BRA"

        //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
        //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
        //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
        //ljob := .F.	

        totvs.framework.treports.callTReports("backoffice.sv.com.invoicelist",,,,,.F.,,.T.,)
    Else
        Help(" ", 1, STR0001, , STR0002, 1, 1) //"Aviso" |"Esta Rotina está disponível somente para ambiente Brasil"
    EndIf

Return 
