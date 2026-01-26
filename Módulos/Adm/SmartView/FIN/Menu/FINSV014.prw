#Include 'totvs.ch'
#include 'fwlibversion.ch'


/*/{Protheus.doc} FINSV014
    Chamada do Smart View no menu - Bank Statement - Extrato Bancário

    @author guilhermed.santos@totvs.com.br
    @since 21/09/2023
    @version 12.1.2310
*/

Function FINSV014()

    Local lSuccess As Logical
    Local cError as Character
    local jParams as Json 
    local oSmartView as object
    local lLibVersion := FwLibVersion() < "20240226" As Logical 
    local lExclusiveShare :=  FWModeAccess("SA6", 1) + FWModeAccess("SA6", 2) + FWModeAccess("SA6", 3) == "EEE" as Logical 
    
    If GetRpoRelease() > '12.1.2210' 
        If lLibVersion 
            lSuccess := totvs.framework.treports.callTReports("backoffice.sv.fin.bankstatement",,,,,.F.,,.T., @cError)
            If !lSuccess
                Conout(cError)
            EndIf
        Else              
            oSmartView := totvs.framework.smartview.callSmartView():new("backoffice.sv.fin.bankstatement")

            if lExclusiveShare 
                jParams := JsonObject():new()
                jParams["parameters"] := Array(1)
                jParams["force"] := .T. //Indica se força o valor
                jParams["parameters"][1] := JsonObject():New()
                jParams["parameters"][1]["name"] := "SV_MULTBRANCH"
                jParams["parameters"][1]["value"] := FWxFilial("SA6")
                jParams["parameters"][1]["visibility"] := "Disabled"

                oSmartView:setParameters(jParams)
                oSmartView:setForceParams(.T.)
            EndIf

            lSuccess := oSmartView:executeSmartView()

            If !lSuccess
                cMsg := oSmartView:getError()
            EndIf 

            oSmartView:Destroy()
        EndIf
    Else
        Conout("rotina não disponivel")
    EndIf

Return
