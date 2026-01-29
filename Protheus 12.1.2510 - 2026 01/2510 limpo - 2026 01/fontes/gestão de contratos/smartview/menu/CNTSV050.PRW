#include "protheus.ch"
#INCLUDE 'FWLIBVERSION.CH'

/*/{Protheus.doc} CNTSV050
backoffice.sv.gct.InvoicingPerMeasurement - SmartView
@type function
@version 12.1.2210  
@author marcelo.hruschka
@since 11/03/2024
/*/ 
Function CNTSV050()
    Local lSuccess as logical
    Local lDelete as logical
    Local lHasParams as logical
    Local oSmartView as object
    Local oProfile as object
    Local oPergSx1	as object
    Local aProfile as array
    Local aSx1 as array
    Local nX as numeric
    Local cRelease as character
  

    //Inicialização das variáveis
    oSmartView := Nil
    oPergSx1   := Nil
    oProfile   := Nil
    aProfile   := {}   
    aSx1       := {}
    lDelete    := .F.
    lHasParams := .F.
    nX         := 0
    cRelease   := GetRpoRelease()
  
 
    If cRelease >= "12.1.2310"
        oProfile   := FWPROFILE():New()       
        oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.gct.InvoicingPerMeasurement")
        oSmartView:setShowWizard(.T.)

        If (cRelease >= "12.1.2610" .Or. FWLibVersion() >= "20251117") 
            lHasParams := oSmartView:loadParamsProfile("custom.gestaodecontratos.invoicingpermeasurement.integratedprovider.invoicingpermeasurementtreportsbusinessobject",@oProfile)
        EndIf
        
        If lHasParams

            oPergSx1   := FWSX1Util():New()
            oPergSx1:AddGroup("CNTSV050")
            oPergSx1:SearchGroup()
            aSx1      := oPergSx1:GetGroup("CNTSV050")
            aProfile  := oProfile:Load()
 
            For nX := 1 to Len(aSx1[2])
                If ValType(aProfile[2][nX]) != (aSx1[2][nX]:CX1_TIPO)
                    lDelete := .T.
                    Exit
                Endif
            Next

            If lDelete
                oProfile:Delete()
            Endif
            
        Endif
      
        lSuccess := oSmartView:executeSmartView(.T.)
        IIf(!lSuccess,FwLogMsg( 'INFO', ' ', 'INFO', FunName(), '', '01', oSmartView:getError(), 0, 0, { } ),"")
        oSmartView:destroy()        
        oProfile:destroy()
 
        freeObj(oSmartView)
        freeObj(oProfile)
        freeObj(oPergSx1)
        FwFreeArray(aProfile)
        FwFreeArray(aSx1)
    EndIf
    
Return Nil
