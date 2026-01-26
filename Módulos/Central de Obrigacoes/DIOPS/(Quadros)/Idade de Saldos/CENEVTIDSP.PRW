#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTIDSP
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 31/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTIDSP FROM FWModelEvent
         
    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTIDSP
Return
  
Method Destroy()  Class CENEVTIDSP       
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPos
Metodo de pos validação do modelo.
Model post validation method.
@author everton.mateus
@since 31/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class CENEVTIDSP
    Local lRet := preValidaDIOPS(oModel, 'B8GMASTER', 'B8G_CODOPE', 'B8G_CODOBR', 'B8G_CDCOMP', 'B8G_ANOCMP', 'B8G_REFERE', 'B8G_STATUS')
    If lRet
		lRet := LibQuaVal('5', B3D->B3D_CODOPE, B3D->B3D_ANO, B3DRefere() , oModel)
    EndIf
Return lRet