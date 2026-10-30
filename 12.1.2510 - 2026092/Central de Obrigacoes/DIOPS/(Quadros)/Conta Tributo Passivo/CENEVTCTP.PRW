#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTCTP
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTCTP FROM FWModelEvent
         
    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTCTP
Return
  
Method Destroy()  Class CENEVTCTP       
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
Method ModelPosVld(oModel, cModelId) Class CENEVTCTP
    Local lRet := .T.
    
    If oModel:GetOperation() <> MODEL_OPERATION_DELETE
        PLSNUMCTP(oModel)
    EndIf    

    lRet := preValidaDIOPS(oModel, 'BUYMASTER', 'BUY_CODOPE', 'BUY_CODOBR', 'BUY_CDCOMP', 'BUY_ANOCMP', 'BUY_REFERE', 'BUY_STATUS')

    If  lRet
        lRet:= LibQuaVal('15', B3D->B3D_CODOPE, B3D->B3D_ANO, B3DRefere() , oModel)
    EndIf
    
Return lRet