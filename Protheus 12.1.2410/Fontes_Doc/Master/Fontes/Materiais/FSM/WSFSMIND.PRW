#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMINDICA
Métodos Rest do FSM X Indicadores (Home/Início)
@author alexandre.takaki
@since 20/05/2025
@version 1.00
/*/
//-------------------------------------------------------------------

WSRESTFUL FSMINDICA DESCRIPTION "WS de Integração - FSM X Indicadores" 

        WSDATA cData             AS STRING
        WSDATA cSituacao         AS STRING
        WSDATA page              AS INTEGER
        WSDATA pageSize          AS INTEGER
        WSDATA cDadosCliente     AS STRING
        WSDATA cCodAtendente     AS STRING
        WSDATA cCodcli           AS STRING       


        WSMETHOD GET ordensServico        DESCRIPTION 'Retorna a quantidade de OS por data'      	   PATH "ordensServico"         PRODUCES APPLICATION_JSON	
        WSMETHOD GET detalhesOS           DESCRIPTION 'Retorna os detalhes da OS por data e situacao'	   PATH "detalhesOS"            PRODUCES APPLICATION_JSON	
        WSMETHOD GET prioridadeOS         DESCRIPTION 'Retorna os detalhes da OS por data e prioridade'	   PATH "prioridadeOS"          PRODUCES APPLICATION_JSON	
        WSMETHOD GET getTiposServicos     DESCRIPTION 'Retorna os detalhes da OS por tipo de serviços'	   PATH "servicosOS"            PRODUCES APPLICATION_JSON	
        WSMETHOD GET getQtdAtendimento    DESCRIPTION 'Retorna a quantidade de atendimentos por atendente' PATH "qtdAtendimentos"       PRODUCES APPLICATION_JSON	
        WSMETHOD GET getOSClientes        DESCRIPTION 'Retorna a contagem de clientes x OS'	           PATH "qtdOSClientes"         PRODUCES APPLICATION_JSON		
        WSMETHOD GET getAgendaAtendentes  DESCRIPTION 'Retorna os Atendentes OS'	                   PATH "agendaAtendentes"      PRODUCES APPLICATION_JSON	
        WSMETHOD GET clientesOS	          DESCRIPTION 'Retorna as OS dos clientes'	                   PATH "clienteOS"             PRODUCES APPLICATION_JSON	
END WSRESTFUL 

//-------------------------------------------------------------------
/*/{Protheus.doc} OrdensServico
Retorna a quantidade de OSs por data.

@author alexandre.takaki
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET ordensServico WSRECEIVE cData,cDadosCliente WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Informe a Data para calcular a quantidade de Ordens de Serviço"
        EndIf

        If lRet

                cQuery := " SELECT	JN3_SITUAC		AS SITUACAO, "
                cQuery += "             CASE JN3_SITUAC "
                cQuery += "                     WHEN '00' THEN 'Sem alocacao' "
                cQuery += "                     WHEN '01' THEN 'Em Atendimento' "
                cQuery += "                     WHEN '02' THEN 'Em Aberto' "
                cQuery += "                     WHEN '03' THEN 'Em Pausa' "
                cQuery += "                     WHEN '04' THEN 'Encerrada' "
                cQuery += "                     WHEN '05' THEN 'Cancelada' "
                cQuery += "             END			AS DESCRICAO, "
                cQuery += "             COUNT(*)		AS QUANTIDADE "
                cQuery += " FROM	" + RetSqlName('JN3') + " "
                cQuery += " WHERE	JN3_FILIAL		= ? "
                cQuery += " AND		JN3_DTINCL		= ? "
                cQuery += " AND		D_E_L_E_T_		= ? "

                if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                Endif
                cQuery += " GROUP BY	JN3_SITUAC "
                cQuery += " ORDER BY	JN3_SITUAC "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("JN3"))
                oQuery:SetString(2, Self:cData)
                oQuery:SetString(3, ' ')

                if !Empty(Self:cDadosCliente)
                         oQuery:SetString(4,cCodCli) 
                         oQuery:SetString(5,cLoja)   
                Endif

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['ordemServico'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['ordemServico'], JsonObject():New())
                                nX++
                                oResponse['ordemServico'][nX]["situacao"]   := AllTrim((cAlias)->SITUACAO)
                                oResponse['ordemServico'][nX]["descricao"]  := AllTrim((cAlias)->DESCRICAO)
                                oResponse['ordemServico'][nX]["quantidade"] := (cAlias)->QUANTIDADE
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Orden(s) de Serviço não encontrada(s)")
                        
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
/*/{Protheus.doc} DetalhesOS
Retorna os detalhes da OS por data e situacao.

@author alexandre.takaki
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET detalhesOS WSRECEIVE cData,cDadosCliente, cSituacao, page, pageSize WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''
        
        Default Self:page       := 1
        Default Self:pageSize   := 10

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Informe a Data para calcular a quantidade de Ordens de Serviço"
        EndIf

        If lRet

                cQuery := " SELECT      JN3.JN3_FILIAL, JN3.JN3_DESCRI,  "
                cQuery += "             JN3.JN3_CODIGO, "
                cQuery += "             JN3.JN3_CLIENT, "
                cQuery += "             SA1.A1_NOME, "
                cQuery += "             TB_AA1.JN6_CODAA1, "
                cQuery += "             TB_AA1.AA1_NOMTEC "
                cQuery += " FROM	" + RetSqlName('JN3') + "       JN3 "
                cQuery += "             LEFT JOIN "
                cQuery += "             ( "
                cQuery += "                     SELECT	JN6.JN6_FILIAL, JN6.JN6_CODJN3, JN6.JN6_CODAA1, "
                cQuery += "                             AA1.AA1_NOMTEC "
                cQuery += "                     FROM	" + RetSqlName('JN6') + "       JN6, "
                cQuery += "                             " + RetSqlName('AA1') + "	AA1 "
                cQuery += "                     WHERE	JN6.JN6_FILIAL	                = ? "
                cQuery += "                     AND	JN6.D_E_L_E_T_	                = ? "
                cQuery += "                     AND	AA1.AA1_FILIAL	                = JN6.JN6_FILIAL "
                cQuery += "                     AND	AA1.AA1_CODTEC	                = JN6.JN6_CODAA1 "
                cQuery += "                     AND	AA1.D_E_L_E_T_	                = ? "
                cQuery += "             ) TB_AA1 "
                cQuery += "             ON TB_AA1.JN6_FILIAL = JN3.JN3_FILIAL AND TB_AA1.JN6_CODJN3 = JN3.JN3_CODIGO, "
                cQuery += "             SA1T10				SA1 "
                cQuery += " WHERE	JN3.JN3_FILIAL		        = ? "
                cQuery += " AND	        JN3.JN3_DTINCL	                = ? "
                cQuery += " AND	        JN3.JN3_SITUAC	                = ? "
                cQuery += " AND	        JN3.D_E_L_E_T_		        = ? "
                cQuery += " AND	        SA1.A1_FILIAL	                = JN3.JN3_FILIAL "
                cQuery += " AND	        SA1.A1_COD	                = JN3.JN3_CLIENT "
                cQuery += " AND	        SA1.A1_LOJA	                = JN3.JN3_LOJA "
                cQuery += " AND	        SA1.D_E_L_E_T_	                = ? "

                if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                Endif

                cQuery += " ORDER BY JN3.JN3_CODIGO "
                cQuery += " OFFSET ? ROWS "
                cQuery += " FETCH NEXT ? ROWS ONLY "
                
                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("JN6"))
                oQuery:SetString(2, ' ')
                oQuery:SetString(3, ' ')
                oQuery:SetString(4, xFilial("JN3"))
                oQuery:SetString(5, Self:cData)
                oQuery:SetString(6, Self:cSituacao)
                oQuery:SetString(7, ' ')
                oQuery:SetString(8, ' ')

                if !Empty(Self:cDadosCliente)
                        oQuery:SetString(9,cCodCli) 
                        oQuery:SetString(10,cLoja)   
                        oQuery:SetNumeric(11, (Self:page -1) * Self:pageSize)
                        oQuery:SetNumeric(12, Self:pageSize)
                Else     
                        oQuery:SetNumeric(9, (Self:page -1) * Self:pageSize)
                        oQuery:SetNumeric(10, Self:pageSize)   

                Endif

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['detalhesOS'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['detalhesOS'], JsonObject():New())
                                nX++
                                oResponse['detalhesOS'][nX]["numeroOS"]         := AllTrim((cAlias)->JN3_CODIGO) + " - " + AllTrim((cAlias)->JN3_DESCRI) 
                                oResponse['detalhesOS'][nX]["codCliente"]       := AllTrim((cAlias)->JN3_CLIENT) + " - " + AllTrim((cAlias)->A1_NOME) 
                                oResponse['detalhesOS'][nX]["nomeCliente"]      := AllTrim((cAlias)->A1_NOME) 
                                oResponse['detalhesOS'][nX]["atendente"]        := AllTrim((cAlias)->JN6_CODAA1) + " - " + AllTrim((cAlias)->AA1_NOMTEC) 
                                oResponse['detalhesOS'][nX]["nomeAtendente"]    := AllTrim((cAlias)->AA1_NOMTEC) 
                                oResponse['detalhesOS'][nX]["dataInicio"]       := AllTrim(SubStr(Self:cData,7,2) + "/" + SubStr(Self:cData,5,2) + "/" + SubStr(Self:cData,1,4))
                                (cAlias)->(DbSkip())
                        EndDo

                        oResponse['hasNext'] := (nX >= Self:pageSize)
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Detalhes Orden(s) de Serviço não encontrada(s)")
                        
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
/*/{Protheus.doc} Prioridades
Retorna as prioridades das OS do dia

@author alexandre.takaki
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET prioridadeOS WSRECEIVE cData,cDadosCliente WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Informe a Data para calcular as prioridades das Ordens de serviços"
        EndIf
       If lRet

                cQuery := " SELECT	JN3_PRIORI		AS PRIORIDADE, "
                cQuery += "             CASE JN3_PRIORI "
                cQuery += "                     WHEN '1' THEN 'Baixa' "
                cQuery += "                     WHEN '2' THEN 'Media' "
                cQuery += "                     WHEN '3' THEN 'Alta' "
                cQuery += "                     WHEN '4' THEN 'Critica' "
                cQuery += "             END			AS DESCRICAO, "
                cQuery += "             COUNT(*)		AS QUANTIDADE "
                cQuery += " FROM	" + RetSqlName('JN3') + " "
                cQuery += " WHERE	JN3_FILIAL		= ? "
                cQuery += " AND		JN3_DTINCL		= ? "
                cQuery += " AND		D_E_L_E_T_		= ? "

                if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                Endif

                cQuery += " GROUP BY	JN3_PRIORI "
                cQuery += " ORDER BY	JN3_PRIORI "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("JN3"))
                oQuery:SetString(2, Self:cData)
                oQuery:SetString(3, ' ')

                if !Empty(Self:cDadosCliente)
                         oQuery:SetString(4,cCodCli) 
                         oQuery:SetString(5,cLoja)   
                Endif

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['ordemServico'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['ordemServico'], JsonObject():New())
                                nX++
                                oResponse['ordemServico'][nX]["prioridade"]   := AllTrim((cAlias)->PRIORIDADE)
                                oResponse['ordemServico'][nX]["descricao"]  := AllTrim((cAlias)->DESCRICAO)
                                oResponse['ordemServico'][nX]["quantidade"] := (cAlias)->QUANTIDADE
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Orden(s) de Serviço não encontrada(s)")
                        
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
/*/{Protheus.doc} Tipos de serviços
Retorna a quantidade serviços do dia

@author Vitor kwon 24/06/2025
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET getTiposServicos WSRECEIVE cData,cDadosCliente WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Informe a Data para calcular a quantidade de serviços nas Ordens de Serviço"
        EndIf

        If lRet

                    cQuery := "SELECT  JN4_CODJN1 SERVICO,COUNT(*) AS QUANTIDADE , JN1_DESCRI DESCRICAO"
                    cQuery += " FROM	" + RetSqlName('JN3') + " JN3 "
                    cQuery += " INNER JOIN "+ RetSqlName('JN4') + " JN4 ON JN4_CODJN3 = JN3_CODIGO "
                    cQuery += " AND JN4.D_E_L_E_T_ = ? "
                    cQuery += " AND JN4_FILIAL = ? " 
                    cQuery += " INNER JOIN "+ RetSqlName('JN1') + " JN1  ON JN1_CODIGO = JN4_CODJN1 "
                    cQuery += " AND JN1.D_E_L_E_T_ = ? "
                    cQuery += " AND JN1_FILIAL = ? " 
                    cQuery += " WHERE	JN3_FILIAL		= ? "
                    cQuery += " AND		JN3_DTINCL		= ? "
                    cQuery += " AND		JN3.D_E_L_E_T_		= ? "
                    if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                    Endif
                    cQuery += " GROUP BY	JN4_CODJN1,JN1_DESCRI "
                    cQuery += " ORDER BY	JN4_CODJN1,JN1_DESCRI "

                    cQuery  := ChangeQuery(cQuery)
                    oQuery  := FWPreparedStatement():New(cQuery)    

                    oQuery:SetString(1," ")
                    oQuery:SetString(2,  xFilial("JN4"))
                    oQuery:SetString(3, ' ')
                    oQuery:SetString(4, XfILIAL("JN1"))
                    oQuery:SetString(5, XfILIAL("JN3"))
                    oQuery:SetString(6, Self:cData)
                    oQuery:SetString(7, ' ')

                    if !Empty(Self:cDadosCliente)
                         oQuery:SetString(8,cCodCli) 
                         oQuery:SetString(9,cLoja)   
                    Endif

                    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                    If (cAlias)->(!Eof())

                            oResponse['ordemServico'] := {}

                            Do While (cAlias)->(!Eof())
                                    Aadd(oResponse['ordemServico'], JsonObject():New())
                                    nX++
                                    oResponse['ordemServico'][nX]["descricao"]  := AllTrim((cAlias)->DESCRICAO)
                                    oResponse['ordemServico'][nX]["quantidade"] := (cAlias)->QUANTIDADE
                                    (cAlias)->(DbSkip())
                            EndDo
                            
                    Else

                            oResponse['errorCode']          := 400
                            oResponse['errorMessage']       := EncodeUTF8("Nao localizado serviços para esta data")
                            
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
/*/{Protheus.doc} Atendimento
Retorna a quantidade de atendimentos do dia

@author Vitor kwon 24/06/2025
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET getQtdAtendimento WSRECEIVE cData,cDadosCliente WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Informe a Data para calcular a quantidade de serviços nas Ordens de Serviço"
        EndIf

        If lRet

                    cQuery := "SELECT  AA1_NOMTEC ATENDENTE, AA1_CODTEC CODATENDENTE,COUNT(*) AS QUANTIDADE "
                    cQuery += " FROM	" + RetSqlName('JN6') + " JN6 "
                    cQuery += " INNER JOIN "+ RetSqlName('AA1') + " AA1 ON AA1_CODTEC = JN6_CODAA1 "
                    cQuery += " AND AA1.D_E_L_E_T_ = ? "
                    cQuery += " AND AA1_FILIAL = ? " 
                    cQuery += " INNER JOIN "+ RetSqlName('JN3') + " JN3 ON JN3_CODIGO = JN6_CODJN3 "
                    cQuery += " AND JN3.D_E_L_E_T_ = ? "
                    cQuery += " AND JN3_FILIAL = ? " 
                    cQuery += " WHERE	JN6_FILIAL		= ? "
                    cQuery += " AND		JN6_DTINI		= ? "
                    cQuery += " AND		JN6.D_E_L_E_T_		= ? "
                    if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                    Endif
                    cQuery += " GROUP BY	AA1_NOMTEC, AA1_CODTEC"
                    cQuery += " ORDER BY	AA1_NOMTEC, AA1_CODTEC"

                    cQuery  := ChangeQuery(cQuery)
                    oQuery  := FWPreparedStatement():New(cQuery)    

                    oQuery:SetString(1," ")
                    oQuery:SetString(2,  xFilial("AA1"))
                    oQuery:SetString(3," ")
                    oQuery:SetString(4,  xFilial("JN3"))
                    oQuery:SetString(5,  xFilial("JN6"))
                    oQuery:SetString(6,  Self:cData)
                    oQuery:SetString(7, ' ')

                    if !Empty(Self:cDadosCliente)
                         oQuery:SetString(8,cCodCli) 
                         oQuery:SetString(9,cLoja)   
                    Endif

                    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                    If (cAlias)->(!Eof())

                            oResponse['atendimento'] := {}

                            Do While (cAlias)->(!Eof())
                                    Aadd(oResponse['atendimento'], JsonObject():New())
                                    nX++
                                    oResponse['atendimento'][nX]["codigoAtendente"]  := AllTrim((cAlias)->CODATENDENTE)
                                    oResponse['atendimento'][nX]["nomeAtendente"]  := AllTrim((cAlias)->ATENDENTE)
                                    oResponse['atendimento'][nX]["quantidade"] := (cAlias)->QUANTIDADE
                                    (cAlias)->(DbSkip())
                            EndDo
                            
                    Else

                            oResponse['errorCode']          := 400
                            oResponse['errorMessage']       := EncodeUTF8("Nao localizado atendimentos para esta data")
                            
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
/*/{Protheus.doc} Clientes
Retorna a quantidade de OS do dia

@author Vitor kwon 24/06/2025
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET getOSClientes WSRECEIVE cData,cDadosCliente WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Não localizado "
        EndIf

        If lRet

                    cQuery := " SELECT A1.A1_COD CODCLI,  A1.A1_LOJA LOJACLI, A1.A1_NOME AS NOME ,COUNT(*) AS QUANTIDADE "
                    cQuery += " FROM	" + RetSqlName('JN3') + " JN3 "
                    cQuery += " INNER JOIN "+ RetSqlName('SA1') + " A1 ON A1.A1_COD = JN3.JN3_CLIENT AND A1.A1_LOJA = JN3.JN3_LOJA  "
                    cQuery += " WHERE JN3.D_E_L_E_T_ = ? "
                    cQuery += " AND A1.D_E_L_E_T_  = ? " 
                    cQuery += " AND A1_FILIAL = ? "
                    cQuery += " AND JN3_FILIAL = ? "
                    cQuery += " AND JN3_DTINCL = ? "
                    if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                    Endif
                    cQuery += " GROUP BY  JN3.JN3_CLIENT, JN3.JN3_LOJA, A1.A1_NOME,A1.A1_COD ,A1.A1_LOJA "
                    cQuery += " ORDER BY  JN3.JN3_CLIENT ,  JN3.JN3_LOJA ,A1.A1_COD ,A1.A1_LOJA "



                    cQuery  := ChangeQuery(cQuery)
                    oQuery  := FWPreparedStatement():New(cQuery)    

                    oQuery:SetString(1," ")
                    oQuery:SetString(2," ")
                    oQuery:SetString(3,  xFilial("SA1"))
                    oQuery:SetString(4,  xFilial("JN3"))
                    oQuery:SetString(5,  Self:cData)

                   if !Empty(Self:cDadosCliente)
                         oQuery:SetString(6,cCodCli) 
                         oQuery:SetString(7,cLoja)   
                    Endif

                    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                    If (cAlias)->(!Eof())

                            oResponse['clientes'] := {}

                            Do While (cAlias)->(!Eof())
                                    Aadd(oResponse['clientes'], JsonObject():New())
                                    nX++
                                    oResponse['clientes'][nX]["codigoCliente"]  := AllTrim((cAlias)->CODCLI+(cAlias)->LOJACLI)
                                    oResponse['clientes'][nX]["nomeCliente"]  := AllTrim((cAlias)->NOME)
                                    oResponse['clientes'][nX]["quantidade"] := (cAlias)->QUANTIDADE
                                    (cAlias)->(DbSkip())
                            EndDo
                            
                    Else

                            oResponse['errorCode']          := 400
                            oResponse['errorMessage']       := EncodeUTF8("Nao localizado atendimentos para esta data")
                            
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
/*/{Protheus.doc} Atendentes
Retorna a quantidade de atendimentos por dia

@author Vitor kwon 24/06/2025
@since 20/05/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET getAgendaAtendentes WSRECEIVE cData,cDadosCliente,cCodAtendente WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Não localizado atendimentos para esta data"
        EndIf

        If lRet

                    cQuery := " SELECT  JN6.JN6_CODIGO CODAGENDA , JN6.JN6_CODJN3 ORDEM , JN6.JN6_CODAA1 ATENDENTE, JN3.JN3_DESCRI DESCRICAO"
                    cQuery += " FROM	" + RetSqlName('JN6') + " JN6 "
                    cQuery += " INNER JOIN "+ RetSqlName('JN3') + " JN3 ON  JN3.JN3_CODIGO  = JN6.JN6_CODJN3  "
                    cQuery += " WHERE JN6.D_E_L_E_T_ = ? "
                    cQuery += " AND JN3.D_E_L_E_T_  = ? " 
                    cQuery += " AND JN6_FILIAL = ? "
                    cQuery += " AND JN3_FILIAL = ? "
                    cQuery += " AND JN3_DTINCL = ? "
                    cQuery += " AND JN6_CODAA1 = ? "

                   if !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                    Endif

                    cQuery += " ORDER BY  JN6.JN6_CODJN3"



                    cQuery  := ChangeQuery(cQuery)
                    oQuery  := FWPreparedStatement():New(cQuery)    

                    oQuery:SetString(1," ")
                    oQuery:SetString(2," ")
                    oQuery:SetString(3,  xFilial("JN6"))
                    oQuery:SetString(4,  xFilial("JN3"))
                    oQuery:SetString(5,  Self:cData)
                    oQuery:SetString(6,  Self:cCodAtendente)

                   if !Empty(Self:cDadosCliente)
                         oQuery:SetString(7,cCodCli) 
                         oQuery:SetString(8,cLoja)   
                    Endif

                    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                    If (cAlias)->(!Eof())

                            oResponse['agendas'] := {}

                            Do While (cAlias)->(!Eof())
                                    Aadd(oResponse['agendas'], JsonObject():New())
                                    nX++
                                    oResponse['agendas'][nX]["ordemServico"]  := AllTrim((cAlias)->ORDEM)
                                    oResponse['agendas'][nX]["atendente"] := (cAlias)->ATENDENTE
                                    oResponse['agendas'][nX]["descricao"] := (cAlias)->DESCRICAO
                                    oResponse['agendas'][nX]["codigoAgenda"] := (cAlias)->CODAGENDA
                                    (cAlias)->(DbSkip())
                            EndDo
                            
                    Else

                            oResponse['errorCode']          := 400
                            oResponse['errorMessage']       := EncodeUTF8("Nao localizado atendimentos para esta data")
                            
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
/*/{Protheus.doc} Clientes
Retorna a quantidade de clientes x OS do dia

@author Vitor kwon
@since 26/06/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET clientesOS WSRECEIVE cData,cDadosCliente, cCodcli WSREST FSMINDICA

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local nX                := 0
        Local cCodCli           := ''
        Local cLoja             := ''

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cData)
                lRet := .F.
                cMensagem := "Informe a Data para calcular os clientes das Ordens de Serviço"
        EndIf
       If lRet

                cQuery := " SELECT	JN3_CODIGO CODIGO, JN3_DESCRI DESCRICAO "
                cQuery += " FROM	" + RetSqlName('JN3') + " "
                cQuery += " WHERE	JN3_FILIAL		= ? "
                cQuery += " AND		JN3_DTINCL		= ? "
                cQuery += " AND		D_E_L_E_T_		= ? "

                if !Empty(Self:cCodcli) 
                        cCodCli := Substring(Self:cCodcli,1,6)
                        cLoja   := Substring(Self:cCodcli,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                ElseIF !Empty(Self:cDadosCliente)
                        cCodCli := Substring(Self:cDadosCliente,1,6)
                        cLoja   := Substring(Self:cDadosCliente,7,2)
                                cQuery += " AND JN3_CLIENT = ? "
                                cQuery += " AND JN3_LOJA   = ? "
                Endif

                cQuery += " ORDER BY	JN3_CODIGO "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("JN3"))
                oQuery:SetString(2, Self:cData)
                oQuery:SetString(3, ' ')

                if !Empty(Self:cDadosCliente)
                        oQuery:SetString(4, Substring(Self:cDadosCliente,1,6))
                        oQuery:SetString(5, Substring(Self:cDadosCliente,7,2))
                Endif

                if !Empty(Self:cCodcli)
                         oQuery:SetString(4, Substring(Self:cCodcli,1,6)) 
                         oQuery:SetString(5,Substring(Self:cCodcli,7,2))   
                Endif

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['ordemServico'] := {}

                        Do While (cAlias)->(!Eof())
                                Aadd(oResponse['ordemServico'], JsonObject():New())
                                nX++
                                oResponse['ordemServico'][nX]["codigo"]     := AllTrim((cAlias)->CODIGO)
                                oResponse['ordemServico'][nX]["descricao"]  := AllTrim((cAlias)->DESCRICAO)
                                (cAlias)->(DbSkip())
                        EndDo
                        
                Else

                        oResponse['errorCode']          := 400
                        oResponse['errorMessage']       := EncodeUTF8("Cliente não localizado")
                        
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
