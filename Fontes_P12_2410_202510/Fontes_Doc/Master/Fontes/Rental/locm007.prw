#Include "Protheus.ch"

/*/LOCM007.PRW
ITUP Business - TOTVS RENTAL
author Frank Zwarg Fuga
since 21/03/2023
history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Este fonte era o ponto de entrada MT100LOK
/*/

Function LOCM007(lRet)
Local aArea := GetArea()
//Local nPosProd := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_COD" })
//Local nPosTES  := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="D1_TES" })
//Local cProd    := AllTrim(aCols[n][nPosProd])
//Local cTES 	   := AllTrim(aCols[n][nPosTES])
Default lRet := .T.

    //If !Empty(cProd) 
        //lRet := LOCA022("E",cProd,cTES)
    //Endif

    RestArea(aArea)
Return lRet



