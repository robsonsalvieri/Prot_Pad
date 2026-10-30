#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTIDSA
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 31/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTIDSA FROM FWModelEvent
         
    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTIDSA
Return
  
Method Destroy()  Class CENEVTIDSA       
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
Method ModelPosVld(oModel, cModelId) Class CENEVTIDSA
    Local lRet := preValidaDIOPS(oModel, 'B8FMASTER', 'B8F_CODOPE', 'B8F_CODOBR', 'B8F_CDCOMP', 'B8F_ANOCMP', 'B8F_REFERE', 'B8F_STATUS')
Return lRet