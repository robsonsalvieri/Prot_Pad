#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTCDO
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author jose.paulo
@since 13/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTCDO FROM FWModelEvent

    Method new()
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTCDO
Return

Method Destroy()  Class CENEVTCDO
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPos
Metodo de pos validação do modelo.
Model post validation method.
@author jose.paulo
@since 13/04/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class CENEVTCDO
    Local lRet :=preValidaDIOPS(oModel, 'B6XMASTER', 'B6X_CODOPE', 'B6X_CODOBR', 'B6X_CDCOMP', 'B6X_ANOCMP', 'B6X_REFERE', 'B6X_STATUS')

    If  lRet .And. oModel:GetOperation() == 3
        lRet:= QtdRgCDO()
    EndIf

Return lRet