#Include "PROTHEUS.CH"
#Include "PARMTYPE.CH"

Static __cProgram := "RU06D06"

Static Function ViewDef()

    Local oView 	as Object

    oView  := FWLoadView(__cProgram)

Return oView

Static Function ModelDef()

    Local oModel As Object
    
    oModel := FWLoadModel(__cProgram)

Return oModel                   
//Merge Russia R14 
                   
