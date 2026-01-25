#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Chamada de build .app para mesa PO UI

@author     Maratona Serviços - Mesa Operacional PO UI
@since      06/09/2023
/*/
//------------------------------------------------------------------------------

Function TECM190()

FWCallApp( "mesaoperacional", , , , , "TECM190" )

Return
