#INCLUDE "PROTHEUS.CH"

Function PCOQtdEntd(cAlias as Character)
Local nQtd := 5
Local nQtPco as Numeric
Local nQtdEntid as Numeric
Local nQtdTotal := 4
Default cAlias := 'AK2'
nQtdEntid := If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4)

If cPaisLoc == 'RUS'
     nQtdTotal := 5
     nQtd := 6
EndIf

If nQtdEntid > 4
     nQtPco := 0
     While nQtd <= nQtdEntid
          If (cAlias)->(FieldPos("AK2_ENT"+STRZERO(nQtd,2))) > 0
               nQtPco++
               nQtd++
          Else
               Exit
          Endif
     EndDo
     nQtdEntid := nQtdTotal + nQtPco
Endif

Return nQtdEntid

/*/{Protheus.doc} RU57XFUN01_PCOFillFld(cFieldName)
     This function change field values according their size in SX3.
     This function calls from PCOXINC.PRW, for cPaisLoc eqals "RUS"

     @type Function
     @param cFieldName, type Character, fieldName from SX3
     @return xVal

     @author dborisov
     @since 2023/08/01
     @example RU57XFUN01_PCOFillFld(cFieldName)
*/
Function RU57XFUN01_PCOFillFld(cFieldName)
    Local xVal
    If TamSx3(cFieldName)[3] == "C"
         xVal := PadR(FieldGet(FieldPos(cFieldName)),TamSx3(cFieldName)[1])
    Else
         xVal := FieldGet(FieldPos(cFieldName))
    EndIf

Return xVal
                   
//Merge Russia R14 

