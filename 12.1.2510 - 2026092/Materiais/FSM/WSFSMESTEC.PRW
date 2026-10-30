#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMESTEC
Métodos Rest do FSM para Estoque do técnico
@author Vitor Kwon
@since 10/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------

WSRESTFUL FSMESTEC DESCRIPTION "WS de Integração Field Services Manager - Estoque do Técnico" 

    WSDATA cEndTec           AS STRING 
    WSDATA cTipo             AS STRING
    WSDATA cProduto          AS STRING
    WSDATA cQtdProduto       AS STRING
    WSDATA cArmazem          AS STRING
    WSDATA cCodTec           AS STRING

    WSMETHOD GET estoqueTec         DESCRIPTION 'Retorna a quantidade de produtos disponiveis para uso'	 PATH "estoqueTec"          PRODUCES APPLICATION_JSON	
    WSMETHOD GET produtosEndereco   DESCRIPTION 'Retorna se o Produto tem a quantidade solicitada'	 PATH "produtosEndereco"    PRODUCES APPLICATION_JSON	
    WSMETHOD GET pecasUtilizadas    DESCRIPTION 'Retorna as peças utilizadas pelo técnico'	         PATH "pecasUtilizadas"     PRODUCES APPLICATION_JSON	
    WSMETHOD GET kitsTecnico        DESCRIPTION 'Retorna as peças do kit em poder do técnico'	         PATH "kitsTecnico"         PRODUCES APPLICATION_JSON	


END WSRESTFUL



//-------------------------------------------------------------------
/*/{Protheus.doc} Técnicos
Retorna os produtos que esta no estoque do técnico

@author Vitor kwon
@since 10/02/2026
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET estoqueTec WSRECEIVE cEndTec WSREST FSMESTEC

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX := 0


        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cEndTec)
                lRet := .F.
                cMensagem := "O técnico não possui endereço no estoque"
        EndIf

        If lRet 

                cQuery := " SELECT BF_PRODUTO PRODUTO , BF_QUANT QUANTIDADE , BF_LOCALIZ ENDERECO , AA1_LOCLZB PECASBOAS, AA1_LOCLZR PECASRUINS , B1_UM UNIDADE "
                cQuery += "  , AA1_LOCAL ARMAZEM , AA1_CODTEC CODTEC"
                cQuery += " FROM " + RetSqlName('AA1') + " AA1  "
                cQuery += " INNER JOIN " + RetSqlName('SBF') + " BF ON BF.BF_LOCALIZ = AA1.AA1_LOCLZB "
                cQuery += " AND BF.BF_LOCAL = AA1.AA1_LOCAL "
                cQuery += " AND BF_FILIAL = ? AND BF.D_E_L_E_T_ = ? "
                cQuery += " AND BF.BF_QUANT > ? "
                cQuery += " INNER JOIN " + RetSqlName('SB1') + " B1 ON B1.B1_COD = BF.BF_PRODUTO AND B1.D_E_L_E_T_ = ? AND B1.B1_FILIAL = ? "
                cQuery += " WHERE AA1.D_E_L_E_T_ = ? "
                cQuery += " AND AA1.AA1_FILIAL = ? "
                cQuery += " AND BF_LOCALIZ = ? "
                cQuery += " ORDER BY BF_LOCALIZ "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("SBF"))
                oQuery:SetString(2, ' ')
                oQuery:SetString(3, '0')
                oQuery:SetString(4, ' ')
                oQuery:SetString(5,  xFilial("SB1"))
                oQuery:SetString(6, ' ')
                oQuery:SetString(7, xFilial("AA1"))
                oQuery:SetString(8, Self:cEndTec)

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['estoque'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['estoque'], JsonObject():New())
                                nX++
                                oResponse['estoque'][nX]["produto"]        := AllTrim((cAlias)->PRODUTO)
                                oResponse['estoque'][nX]["quantidade"]     := (cAlias)->QUANTIDADE
                                oResponse['estoque'][nX]["endereco"]       := AllTrim((cAlias)->ENDERECO)
                                oResponse['estoque'][nX]["pecasBoas"]      := AllTrim((cAlias)->PECASBOAS)
                                oResponse['estoque'][nX]["pecasRuins"]     :=  AllTrim((cAlias)->PECASRUINS)
                                oResponse['estoque'][nX]["armazem"]        := AllTrim((cAlias)->ARMAZEM)
                                oResponse['estoque'][nX]["codTec"]         := AllTrim((cAlias)->CODTEC)
                                oResponse['estoque'][nX]["unidade"]        := AllTrim((cAlias)->UNIDADE)
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Não foram localizados produtos para este técnico")
                        
                EndIf

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)

        Else
                
                oResponse['errorCode']          := 400
                oResponse['errorMessage']       := EncodeUTF8(cMensagem)

        EndIf 

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))       

Return lRet 




//-------------------------------------------------------------------
/*/{Protheus.doc} Técnicos
Verifica se existe a quantidade solicitada no estoque do técnico

@author Vitor kwon
@since 11/02/2026
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET produtosEndereco WSRECEIVE cEndTec,cProduto,cQtdProduto WSREST FSMESTEC

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        local nX                := 0


        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cEndTec)
                lRet := .F.
                cMensagem := "O técnico não possui endereço no estoque"
        EndIf

        If lRet

                cQuery := " SELECT BF_PRODUTO PRODUTO , BF_QUANT QUANTIDADE , BF_LOCALIZ ENDERECO "
                cQuery += " FROM " + RetSqlName('SBF') + " BF  "
                cQuery += " WHERE BF.D_E_L_E_T_ = ? "
                cQuery += " AND BF_PRODUTO  = ? "
                cQuery += " AND BF_LOCALIZ = ? "
                cQuery += " AND BF_FILIAL  = ? "
                cQuery += " ORDER BY BF_LOCALIZ "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, ' ')
                oQuery:SetString(2, Self:cProduto)
                oQuery:SetString(3, Self:cEndTec)
                oQuery:SetString(4, xFilial("SBF"))
   

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['estoque'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['estoque'], JsonObject():New())
                                nX++
                                oResponse['estoque'][nX]["produto"]        := AllTrim((cAlias)->PRODUTO)
                                oResponse['estoque'][nX]["quantidade"]     := (cAlias)->QUANTIDADE
                                oResponse['estoque'][nX]["endereco"]       := AllTrim((cAlias)->ENDERECO)
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Não foram localizados produtos para este técnico")
                        
                EndIf

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)

        Else
                
                oResponse['errorCode']          := 400
                oResponse['errorMessage']       := EncodeUTF8(cMensagem)

        EndIf 

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))       

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} Técnicos
Verifica se existe a quantidade solicitada no estoque do técnico

@author Vitor kwon
@since 11/02/2026
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET pecasUtilizadas WSRECEIVE cCodTec,cTipo WSREST FSMESTEC

Local lRet      	:= .T.
Local oResponse		:= JsonObject():New()
Local oQuery
Local cQuery            := ""
Local cAlias		:= GetNextAlias()
Local cMensagem         := ""
local nX                := 0


        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cCodTec)
                lRet := .F.
                cMensagem := "O técnico não foi localizado na Base de dados"
        EndIf

        If lRet

                cQuery := " SELECT JO4_CODPRO PRODUTO , JO4_QTDPRO QUANTIDADE, JO4_CODJN6 AGENDA , JO4_CODAA3 BASE , JO4_NUMSER IDUNICO  "
                cQuery += " , JO4_DTINST INSTALACAO, JO4_CODORI CODORIGEM, JO4_DTAPON DTAPONTAMENTO , JO4_CODJN3 ORDEM "
                cQuery += " FROM " + RetSqlName('JO4') + " JO4  "
                cQuery += " WHERE JO4.D_E_L_E_T_ = ? "
                cQuery += " AND JO4_FILIAL  = ? "
                cQuery += " AND JO4_CODAA1  = ? "
                cQuery += " AND JO4_STATUS  = ? "
                cQuery += " AND JO4_DTAPON  <> ? "


                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, ' ')
                oQuery:SetString(2, xFilial("JO4"))
                oQuery:SetString(3, Self:cCodTec)
                if Self:cTipo == '1'
                        oQuery:SetString(4,'3')
                Else
                        oQuery:SetString(4,'2')
                Endif
                oQuery:SetString(5, ' ')

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['estoque'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['estoque'], JsonObject():New())
                                nX++
                                oResponse['estoque'][nX]["produto"]        := AllTrim((cAlias)->PRODUTO)
                                oResponse['estoque'][nX]["quantidade"]     := (cAlias)->QUANTIDADE
                                oResponse['estoque'][nX]["base"]           := (cAlias)->BASE
                                oResponse['estoque'][nX]["idunico"]        := (cAlias)->IDUNICO
                                oResponse['estoque'][nX]["instalacao"]     := (cAlias)->INSTALACAO
                                oResponse['estoque'][nX]["codorigem"]      := (cAlias)->CODORIGEM
                                oResponse['estoque'][nX]["dtapontamento"]  := (cAlias)->DTAPONTAMENTO
                                oResponse['estoque'][nX]["ordemServico"]   := (cAlias)->ORDEM
                                oResponse['estoque'][nX]["agenda"]         := (cAlias)->AGENDA
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Não foram localizados produtos para este técnico")
                        
                EndIf

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)

        Else
                
                oResponse['errorCode']          := 400
                oResponse['errorMessage']       := EncodeUTF8(cMensagem)

        EndIf 

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))       

Return lRet 



//-------------------------------------------------------------------
/*/{Protheus.doc} Técnicos
Verifica se existe a quantidade solicitada no estoque do técnico

@author Vitor kwon
@since 11/02/2026
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET kitsTecnico WSRECEIVE cCodTec WSREST FSMESTEC

Local lRet      	:= .T.
Local oResponse		:= JsonObject():New()
Local oQuery
Local cQuery            := ""
Local cAlias		:= GetNextAlias()
local nX                := 0


                ::SetContentType("application/json;charset=UTF-8")

                cQuery := " SELECT JOB_CODPRO PRODUTO , JOB_QUANTI QUANTIDADE , B1_UM UNIDADE , JOC_DTENTR ENTREGA"
                cQuery += " FROM " + RetSqlName('JOC') + " JOC  "
                cQuery += " INNER JOIN "+RetSqlName("JOB")+" JOB  ON JOB.JOB_CODJOA = JOC.JOC_CODJOA "
                cQuery += " AND  JOC.D_E_L_E_T_ = ? "
                cQuery += " AND  JOC.JOC_FILIAL = ?"
                cQuery += " INNER JOIN " + RetSqlName('SB1') + " B1 ON B1.B1_COD = JOB.JOB_CODPRO  AND B1.D_E_L_E_T_ = ? AND B1.B1_FILIAL = ? "
                cQuery += " WHERE JOB.D_E_L_E_T_ = ? "
                cQuery += " AND JOC_CODAA1 = ? "
                cQuery += " AND JOC_FILIAL  = ? "
                cQuery += " AND JOC_STATUS  = ? "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, ' ')
                oQuery:SetString(2, xFilial("JOC"))
                oQuery:SetString(3, ' ')
                oQuery:SetString(4,  xFilial("SB1"))
                oQuery:SetString(5, ' ')
                oQuery:SetString(6, Self:cCodTec)
                oQuery:SetString(7, xFilial("JOB"))
                oQuery:SetString(8, '02')

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['estoque'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['estoque'], JsonObject():New())
                                nX++
                                oResponse['estoque'][nX]["produto"]        := AllTrim((cAlias)->PRODUTO)
                                oResponse['estoque'][nX]["quantidade"]     := (cAlias)->QUANTIDADE
                                oResponse['estoque'][nX]["unidade"]      := AllTrim((cAlias)->UNIDADE)
                                oResponse['estoque'][nX]["entrega"]      := AllTrim((cAlias)->ENTREGA)
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Não foram localizados produtos para este técnico")
                        
                EndIf

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)


        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))       

Return lRet 





