#INCLUDE "TOTVS.ch"
#INCLUDE "SVAGDA010.ch"

Function SVAGDA010()

	local oSmartView := NIL

	oSmartView := totvs.framework.smartview.callSmartView():new("agrobusiness.sv.sigaagd.business.default.rep", "report") 
    If !oSmartView:executeSmartView(.T.)
        Help( " ", 1, OemToAnsi("Smart View!"), Nil, OemToAnsi(STR0001), 1, 0, Nil, Nil, Nil, Nil, Nil, { OemToAnsi(STR0002) } ) //#"Não foi possível abrir o Smart View. #"Verifique se o servidor REST está no ar ou contate o administrador do sistema."
    EndIf  

    oSmartView:destroy()

return
