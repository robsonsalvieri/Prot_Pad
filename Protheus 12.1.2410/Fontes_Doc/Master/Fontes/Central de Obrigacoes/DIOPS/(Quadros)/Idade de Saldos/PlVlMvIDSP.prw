#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVlMvIDSP

Validação do MILE de Idade de Saldos a Receber

@author Roger C
@since 16/04/2018
/*/
//--------------------------------------------------------------------------------------------------

Function PlVlMvIDSP()
Local lRet	:= .F.

MsgAlert('estou aqui no PlVlMvIDSP')
If oModel == NIL
	oModel:= FWModelActive() 
EndIf

lRet := preValidaDIOPS( oModel, 'B8GMASTER', 'B8G_CODOPE', 'B8G_CODOBR', 'B8G_CDCOMP', 'B8G_ANOCMP', 'B8G_REFERE', 'B8G_STATUS')

Return(lRet)

