#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTCOPE
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.

@since 15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class PLSEVTFUCO FROM FWModelEvent
         
    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class PLSEVTFUCO
Return
  
Method Destroy()  Class PLSEVTFUCO       
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPos
Metodo de pos validação do modelo.
Model post validation method.

@since 15/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class PLSEVTFUCO
    Local lRet := .T.
   
    lRet := preValidaDIOPS(oModel, 'B6RMASTER', 'B6R_CODOPE', 'B6R_CODOBR', 'B6R_CDCOMP', 'B6R_ANOCMP', 'B6R_REFERE', 'B6R_STATUS')

    If  lRet
        lRet:= LibQuaVal('19', B3D->B3D_CODOPE, B3D->B3D_ANO, B3DRefere() , oModel)
    EndIf
    
Return lRet