#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV028
Função utilizada para execução do objeto de negócio Demanda
@type  Função
@author Leonardo Pacheco Fuga
@since  15/05/2026
/*/
//-------------------------------------------------------------------
Function LOCSV028(cDemanda)
    
local lSuccess as logical
local oSmartView as object
Local oDemanda as object
Local lRet as Logical

	lRet := .F.

	If !findClass("totvs.protheus.rental.manutencao.integratedprovider.demanda") .or. file("\SYSTEM\LOCSV028.TXT")
		Return .F.
	EndIf

	oDemanda := totvs.protheus.rental.manutencao.integratedprovider.demanda():new()	
	
	lRet := (oDemanda:printDemanda(cDemanda))
	
	FreeObj(oDemanda)
Return lRet
    

//-------------------------------------------------------------------
    /*/{Protheus.doc} sigaloc.sv.loc.demanda.tlpp
    Funçao para passar no ADVPR 
    @author Leonardo Pacheco Fuga
    @since 15/05/2026
    @version 25.10
    */
//-------------------------------------------------------------------
Function LOCSV028A()
	
Return .T.
