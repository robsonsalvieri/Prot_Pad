#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA390.CH"

CLASS OFIA390EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD VldActivate()

ENDCLASS


METHOD New() CLASS OFIA390EVDEF
RETURN .T.


// Validação antes da Abertura da Tela //
METHOD VldActivate(oModel, cModelId) CLASS OFIA390EVDEF

	Local lRet := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If OA3900011_GrupoUsado(VPW->VPW_CODGRU)
			Help("",1,"DELETE_VPW",,STR0009,1,0) // Grupo de Serviço Especializado já utilizado. Impossível excluir.
			lRet := .f.
		EndIf
	Endif

RETURN lRet