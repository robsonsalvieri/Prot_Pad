#Include 'Protheus.ch'
// #Include 'FWMVCDef.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} CENEVTINV
Classe interna implementando o FWModelEvent
Intern class inherited from FWModelEvent.
@author everton.mateus
@since 06/09/2016
@version 1.0
Função descontinuada
/*/
//-------------------------------------------------------------------
Function CENEVTINV()
    Alert("Função descontinuada")
Return NIL
// Class CENEVTINV FROM FWModelEvent

//     Method new()
//     Method InTTS(oModel, cModelId)
//     Method ModelPosVld(oModel, cModelId)

//     Method Destroy()
// End Class

// Method new ()  Class CENEVTINV
// Return

// Method Destroy()  Class CENEVTINV
// Return
// //-------------------------------------------------------------------
// /*/{Protheus.doc} InTTS
// Antes do fim da transação
// @author everton.mateus
// @version P12
// /*/
// //-------------------------------------------------------------------
// Method InTTS(oModel, cModelId) Class CENEVTINV
//     Local cSql := ""
//     //vou passar todos os registros da tabela para pendent
//     cSql := "UPDATE " + RetSqlName("B8D") + " "
//     cSql += " SET B8D_STATUS = '1' "
//     cSql += " WHERE "
//     cSql += " B8D_FILIAL = '" + xFilial("B8D") + "' "
//     cSql += " AND B8D_CODOPE = '" + oModel:getValue('B8DMASTER','B8D_CODOPE') + "' "
//     cSql += " AND B8D_CODOBR = '" + oModel:getValue('B8DMASTER','B8D_CODOBR') + "' "
//     cSql += " AND B8D_CDCOMP = '" + oModel:getValue('B8DMASTER','B8D_CDCOMP') + "' "
//     cSql += " AND B8D_ANOCMP = '" + oModel:getValue('B8DMASTER','B8D_ANOCMP') + "' "
//     cSql += " AND D_E_L_E_T_ = ' ' "
//     TcSQLExec(cSql)
//     TcSQLExec("COMMIT")
// Return

// //-------------------------------------------------------------------
// /*/{Protheus.doc} ModelPos
// Metodo de pos validação do modelo.
// Model post validation method.
// @author Guilherme Spadaccia
// @since 06/09/2016
// @version 1.0
// /*/
// //-------------------------------------------------------------------
// Method ModelPosVld(oModel, cModelId) Class CENEVTINV
//     Local lRet := .T.
//     lRet := preValidaDIOPS(oModel, 'B8DMASTER', 'B8D_CODOPE', 'B8D_CODOBR', 'B8D_CDCOMP', 'B8D_ANOCMP', 'B8D_REFERE', 'B8D_STATUS')
//     If lRet
//         lRet := CenInvPosGrv(oModel)
//     EndIf
// Return lRet