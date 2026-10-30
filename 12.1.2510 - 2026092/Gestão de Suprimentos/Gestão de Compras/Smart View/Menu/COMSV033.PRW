#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV027 -  Relatório de Saving por Proposta na Cotação
Chamada para o relatorios backoffice.sv.com.listofsavingsbyquotation.bra

@author Thiago Rodrigues
@since 13/03/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function COMSV033()
    Local lSuccess As logical

    lSuccess := totvs.framework.treports.callTReports("backoffice.sv.com.listofsavingsbyquotation",,,,,.F.,,.T.)

Return lSuccess

