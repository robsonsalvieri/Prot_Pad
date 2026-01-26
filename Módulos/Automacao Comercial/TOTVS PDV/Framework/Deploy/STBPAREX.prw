#Include 'Protheus.ch'

Function STBPAREX()

Local aParDefault := {} // Array com Parâmetros default que não serão atualizados
Local aPtParam := {} // Array com parâmetros definidos via ponto de entrada
Local nX := 0

Aadd(aParDefault, "MV_LJAMBIE")
   
Aadd(aParDefault, "MV_LJILLIP")
   
Aadd(aParDefault, "MV_LJILLPO")
   
Aadd(aParDefault, "MV_LJILLEN")
  
Aadd(aParDefault, "MV_LJILLCO")
   
Aadd(aParDefault, "MV_LJILLBR")
   
Aadd(aParDefault, "MV_LJILLIM")
   
Aadd(aParDefault, "MV_LJILLDO")
   
Aadd(aParDefault, "MV_LJILLAC")
   
Aadd(aParDefault, "MV_LJILLKT")
   
If ExistBlock("STParamDeploy")
     aPtParam := ExecBlock("STParamDeploy")
EndIf
   
If Len(aPtParam) > 0
   For nX := 1 To Len(aPtParam)
       Aadd(aParDefault, aPtParam[nX])           
   Next nX
EndIf
   
Return aParDefault





    