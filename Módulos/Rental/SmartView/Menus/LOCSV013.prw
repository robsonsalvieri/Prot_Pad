#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV013
Função utilizada para execução do objeto de negócio Reajustes
@type  Função
@author Leonardo Pacheco Fuga
@since  11/07/2025
/*/
//-------------------------------------------------------------------
Function LOCSV013(cRomaneio)
    
local lSuccess as logical
local oSmartView as object
Local oRomaneio as object
Local lRet as Logical

	lRet := .F.

	If !findClass("totvs.protheus.rental.manutencao.integratedprovider.gestaoexpedicao") .or. file("\SYSTEM\LOCSV013.TXT")
		Return .F.
	EndIf

	oRomaneio := totvs.protheus.rental.manutencao.integratedprovider.gestaoexpedicao():new()	
	
	lRet := (oRomaneio:printRomaneio(cRomaneio))
	
	FreeObj(oRomaneio)
    Return lRet
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.gestaoexpedicao",,,,,.F.,,.T.,)
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
    
        oSmartView:destroy()

    EndIf

Return

//-------------------------------------------------------------------
    /*/{Protheus.doc} sigaloc.sv.loc.gestaoexpedicao.tlpp
    Funçao para passar no ADVPR 
    @author Leonardo Pacheco Fuga
    @since 01/09/2025
    @version 25.10
    */
//-------------------------------------------------------------------
Function LOCSV013A()
	
Return .T.
