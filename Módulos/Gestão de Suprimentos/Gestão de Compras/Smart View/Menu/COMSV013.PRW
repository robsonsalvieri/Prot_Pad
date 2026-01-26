#include "protheus.ch"
#include "fwmvcdef.ch"
#INCLUDE "COMSV013.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV013 -  Nota Fiscal de Devolução
chamada para os relatorios backoffice.sv.com.returninvoices 
@since 21/09/2023
/*/
//-------------------------------------------------------------------
Function COMSV013()

    If cPaisLoc == "BRA"

        //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)`
        //2º parâmetro = Tipo do relatório ("reports" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)`
        //Como não foi mandado o 6º parâmetro como .F. o relatório será gerado em job, caso esse parâmetro seja enviado será aberta a tela de opções`
        //ljob := .F.	

        totvs.framework.treports.callTReports("backoffice.sv.com.returninvoices",,,,,.F.,,.T.,)
    Else
        Help(" ", 1, STR0001, , STR0002, 1, 1) //"Aviso" |"Esta Rotina está disponível somente para ambiente Brasil"
    EndIf

Return

