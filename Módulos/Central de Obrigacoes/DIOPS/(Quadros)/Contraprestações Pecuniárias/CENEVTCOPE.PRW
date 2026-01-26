#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTCOPE
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTCOPE FROM FWModelEvent
         
    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTCOPE
Return
  
Method Destroy()  Class CENEVTCOPE       
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPos
Metodo de pos validação do modelo.
Model post validation method.
@author Guilherme Spadaccia
@since 06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class CENEVTCOPE
    Local lRet := .T.
   
    lRet := preValidaDIOPS(oModel, 'B37MASTER', 'B37_CODOPE', 'B37_CODOBR', 'B37_CDCOMP', 'B37_ANOCMP', 'B37_REFERE', 'B37_STATUS')

    If  lRet
        lRet:= LibQuaVal('23', B3D->B3D_CODOPE, B3D->B3D_ANO, B3DRefere() , oModel)
    EndIf
    
Return lRet