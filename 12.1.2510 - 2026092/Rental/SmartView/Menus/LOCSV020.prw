#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV020
Função utilizada para execução do objeto de negócio Reajustes
@type  Função
@author Leonardo Pacheco Fuga
@since  07/11/2025
/*/
//-------------------------------------------------------------------
Function LOCSV020(cMedicao)
    
local lSuccess as logical
local oSmartView as object
Local oMedicao as object
Local lRet as Logical

	lRet := .F.

	If !findClass("totvs.protheus.rental.manutencao.integratedprovider.imprimemedicao") .or. file("\SYSTEM\LOCSV020.TXT")
		Return .F.
	EndIf

	oMedicao := totvs.protheus.rental.manutencao.integratedprovider.imprimemedicao():new()	
	
	lRet := (oMedicao:printMedicao(cMedicao))
	
	FreeObj(oMedicao)
    
    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.Imprimemedicao",,,,,.F.,,.T.,)
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)
    
        oSmartView:destroy()

    EndIf

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} sigaloc.sv.loc.Imprimemedicao.tlpp
    Funçao para passar no ADVPR 
    @author Leonardo Pacheco Fuga
    @since 07/11/2025
    @version 25.10
    */
//-------------------------------------------------------------------
Function LOCSV020A()
	
Return .T.
