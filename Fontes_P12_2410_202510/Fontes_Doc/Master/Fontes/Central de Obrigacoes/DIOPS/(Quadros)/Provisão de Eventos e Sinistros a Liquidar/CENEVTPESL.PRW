#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTPESL
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTPESL FROM FWModelEvent
         
    Method new()
    Method InTTS(oModel, cModelId)
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTPESL
Return
  
Method Destroy()  Class CENEVTPESL       
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Antes do fim da transação
@author everton.mateus
@version P12
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class CENEVTPESL
    Local cSql := ""
    //vou passar todos os registros da tabela para pendent
    cSql := "UPDATE " + RetSqlName("B8J") + " "
    cSql += " SET B8J_STATUS = '1' "
    cSql += " WHERE "
    cSql += " B8J_FILIAL = '" + xFilial("B8J") + "' " 
    cSql += " AND B8J_CODOPE = '" + oModel:getValue('B8JMASTER','B8J_CODOPE') + "' "
    cSql += " AND B8J_CODOBR = '" + oModel:getValue('B8JMASTER','B8J_CODOBR') + "' "
    cSql += " AND B8J_ANOCMP = '" + oModel:getValue('B8JMASTER','B8J_ANOCMP') + "' "
    cSql += " AND B8J_CDCOMP = '" + oModel:getValue('B8JMASTER','B8J_CDCOMP') + "' "
    cSql += " AND D_E_L_E_T_ = ' ' "
    TcSQLExec(cSql)
    TcSQLExec("COMMIT")
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
Method ModelPosVld(oModel, cModelId) Class CENEVTPESL
    Local lRet := .T.
    lRet := preValidaDIOPS(oModel, 'B8JMASTER', 'B8J_CODOPE', 'B8J_CODOBR', 'B8J_CDCOMP', 'B8J_ANOCMP', 'B8J_REFERE', 'B8J_STATUS')
  
    If  lRet
        lRet:= LibQuaVal('13', B3D->B3D_CODOPE, B3D->B3D_ANO, B3DRefere() , oModel)
    EndIf
 
Return lRet