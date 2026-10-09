#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTCOAS
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 06/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Class CENEVTCOAS FROM FWModelEvent
         
    Method new()
    Method InTTS(oModel, cModelId)
    Method ModelPosVld(oModel, cModelId)

    Method Destroy()
End Class

Method new ()  Class CENEVTCOAS
Return
  
Method Destroy()  Class CENEVTCOAS       
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Antes do fim da transação
@author everton.mateus
@version P12
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class CENEVTCOAS
    Local cSql := ""
    //vou passar todos os registros da tabela para pendent
    cSql := "UPDATE " + RetSqlName("B8I") + " "
    cSql += " SET B8I_STATUS = '1' "
    cSql += " WHERE "
    cSql += " B8I_FILIAL = '" + xFilial("B8I") + "' " 
    cSql += " AND B8I_CODOPE = '" + oModel:getValue('B8IMASTER','B8I_CODOPE') + "' "
    cSql += " AND B8I_CODOBR = '" + oModel:getValue('B8IMASTER','B8I_CODOBR') + "' "
    cSql += " AND B8I_ANOCMP = '" + oModel:getValue('B8IMASTER','B8I_ANOCMP') + "' "
    cSql += " AND B8I_CDCOMP = '" + oModel:getValue('B8IMASTER','B8I_CDCOMP') + "' "
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
Method ModelPosVld(oModel, cModelId) Class CENEVTCOAS
    Local lRet := .T.
    lRet := preValidaDIOPS(oModel, 'B8IMASTER', 'B8I_CODOPE', 'B8I_CODOBR', 'B8I_CDCOMP', 'B8I_ANOCMP', 'B8I_REFERE', 'B8I_STATUS')
Return lRet