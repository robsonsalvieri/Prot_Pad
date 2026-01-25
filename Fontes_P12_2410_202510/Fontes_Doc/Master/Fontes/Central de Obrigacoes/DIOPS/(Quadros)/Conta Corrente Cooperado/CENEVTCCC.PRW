#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTCCC
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author jose.paulo
@since 31/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTCCC FROM FWModelEvent
         
    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTCCC
Return
  
Method Destroy()  Class CENEVTCCC       
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
Method ModelPosVld(oModel, cModelId) Class CENEVTCCC
    Local lRet := .T.
   
    lRet := preValidaDIOPS(oModel, 'BUWMASTER', 'BUW_CODOPE', 'BUW_CODOBR', 'BUW_CDCOMP', 'BUW_ANOCMP', 'BUW_REFERE', 'BUW_STATUS')

    If  lRet
        lRet:= LibQuaVal('14', B3D->B3D_CODOPE, B3D->B3D_ANO, B3DRefere() , oModel)
    EndIf
    
Return lRet