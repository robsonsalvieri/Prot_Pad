user function SPCOBREC()
/*
    Paramixb[1] => Tipo GNRE
    Paramixb[2] => ESTADO da GNRE
*/
 
    Local cTipoImp := Paramixb[1] // Tipo de Imposto (3 - ICMS ST ou B - Difal e Fecp de Difal)
    Local cEstado := Paramixb[2] // Estado da GNRE
    Local cCod := "" // Codigo a ser gravado no campo F6_COBREC
 
    If cTipoImp == "B"
        cCod := "000"
    Else
        cCod := "999"
    EndIf
 
 
Return cCod
