#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE EM_ATENDIMENTO "01"
#DEFINE EM_ABERTO "02"
#DEFINE EM_PAUSA "03"
#DEFINE ENCERRADO "04"
#DEFINE EM_DESLOCAMENTO "06"
#DEFINE FIM_DESLOCAMENTO "07"
#DEFINE AGUARDANDO_CLIENTE "08"
#DEFINE ATENDIMENTO_IMPRODUTIVO "09"
#DEFINE ATENDIMENTO_PENDENTE "10"


//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMAPP
Métodos Rest do APP
@author alexandre.takaki
@since 10/01/2025
@version 1.00
/*/
//-------------------------------------------------------------------

WSRESTFUL FSMAPP DESCRIPTION "WS de Integração APP" 

        WSDATA cAttendant       AS STRING
        WSDATA cPswd            AS STRING
        WSDATA nPageSize        AS INTEGER
        WSDATA nPage            AS INTEGER     
        WSDATA cDate            AS STRING
        WSDATA cEquipament      AS STRING 
        WSDATA cID              AS STRING
        WSDATA cStartDt         AS STRING
        WSDATA cEndDt           AS STRING
        WSDATA nPerHist         AS INTEGER
        WSDATA cNumOS           AS STRING 
        WSDATA cCodAgenda       AS STRING
        WSDATA recPhoto         AS INTEGER

        WSMETHOD GET atendente                  DESCRIPTION "Retorna os dados do tecnico/atendente"                                             PATH "atendente"                PRODUCES APPLICATION_JSON //"Retorna os dados do tecnico/atendente"
        WSMETHOD GET paginasProdutos            DESCRIPTION "Retorna a quantidade de páginas de produtos"                                       PATH "paginasProdutos"          PRODUCES APPLICATION_JSON //"Retorna a quantidade de páginas de produtos"
        WSMETHOD GET produto                    DESCRIPTION "Retorna uma lista de produtos contendo código e nome do produto"                   PATH "produto"                  PRODUCES APPLICATION_JSON //"Retorna uma lista de produtos contendo código e nome do produto"
        WSMETHOD GET servico                    DESCRIPTION "Retorna uma lista de servicos utilizados no atendimento da ordem de serviço"       PATH "servico"                  PRODUCES APPLICATION_JSON //"Retorna uma lista de servicos utilizados no atendimento da ordem de serviço"
        WSMETHOD GET agendas                    DESCRIPTION "Retorna as agendas do técnico para o dia selecionado"                              PATH "agendas"                  PRODUCES APPLICATION_JSON //"Retorna as agendas do técnico para o dia selecionado"
        WSMETHOD PUT atualizaStatus             DESCRIPTION "Atualização do Status da Ordem de Serviço"                                         PATH "atualizaStatus"           PRODUCES APPLICATION_JSON //"Atualização do Status da Ordem de Serviço"
        WSMETHOD GET historicoAtendimento       DESCRIPTION "Retorna o historico do atendimento"                                                PATH "historicoAtendimento"     PRODUCES APPLICATION_JSON //"Retorna o historico do atendimento"
        WSMETHOD GET detalhesAtendimento        DESCRIPTION "Retorna os detalhes do atendimento para a ordem de serviço selecionada"            PATH "detalhesAtendimento"      PRODUCES APPLICATION_JSON //"Retorna os detalhes do atendimento para a ordem de serviço selecionada"
        WSMETHOD POST arquivo                   DESCRIPTION "Enviar arquivos"                                                                   PATH "arquivo"                  PRODUCES APPLICATION_JSON //"Enviar arquivos"
        WSMETHOD GET pagsFotos                  DESCRIPTION "Retorna o recno de cada arquivo gravado na tabela"                                 PATH "pagsFotos"                PRODUCES APPLICATION_JSON //"Retorna o recno de cada arquivo gravado na tabela"
        WSMETHOD GET fotos                      DESCRIPTION "Retorna os dados da foto solicitada pelo recnoId"                                  PATH "fotos"                    PRODUCES APPLICATION_JSON //"Retorna os dados da foto solicitada pelo recnoId"
        WSMETHOD PUT laudo                      DESCRIPTION "Realiza a alteração do laudo de uma OS"                                            PATH "laudo"                    PRODUCES APPLICATION_JSON //"Realiza a alteração do laudo de uma OS"
        WSMETHOD PUT visitaImprodutiva          DESCRIPTION "Realiza a alteração do status da OS para Visita Improdutiva"                       PATH "visitaImprodutiva"        PRODUCES APPLICATION_JSON //"Realiza a alteração do status da OS para Visita Improdutiva"
        WSMETHOD PUT encerramento               DESCRIPTION "Realiza o encerramento da Ordem de Serviço"                                        PATH "encerramento"             PRODUCES APPLICATION_JSON //"Realiza o encerramento da Ordem de Serviço"
        WSMETHOD GET requisicaoPecas            DESCRIPTION "Retorna o status da requisicao de pecas na ordem de servico"                       PATH "requisicaoPecas"          PRODUCES APPLICATION_JSON //"Retorna o status da requisicao de pecas na ordem de servico"
        
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} atendente
Retorna os dados do atentente.

@author alexandre.takaki
@since 10/01/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET atendente WSRECEIVE cAttendant, cPswd WSREST FSMAPP

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMensagem         := ""
        Local cDescExp          := ""

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cAttendant)
                lRet := .F.
                cMensagem := "Informe o usuário" //"Informe o usuario"
        EndIf

        If lRet .And. Empty(Self:cPswd)
                lRet := .F.
                cMensagem := "Informe a senha para o usuário" //"Informe a senha paara o usuario"
        EndIf

        If lRet

                cQuery := " SELECT  AA1.AA1_CODTEC, AA1.AA1_NOMTEC, AA1.AA1_CODUSR "
                cQuery += " FROM    " + RetSqlName('AA1') + "   AA1 "
                cQuery += " WHERE   AA1.AA1_FILIAL              = ? "
                cQuery += " AND     AA1.AA1_NREDUZ              = ? "
                cQuery += " AND     AA1.AA1_SENHA               = ? "
                cQuery += " AND     AA1.D_E_L_E_T_              = ? "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("AA1"))
                oQuery:SetString(2, Self:cAttendant)
                oQuery:SetString(3, Self:cPswd)
                oQuery:SetString(4, ' ')

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['attendant'] := JsonObject():New()
                        FncCaracEsp(EncodeUTF8((cAlias)->AA1_CODTEC),@cDescExp)
                        oResponse['attendant']['codtec'] := AllTrim(cDescExp)  
                        FncCaracEsp(EncodeUTF8((cAlias)->AA1_NOMTEC),@cDescExp)
                        oResponse['attendant']['nomtec'] := AllTrim(cDescExp)  
                        oResponse['attendant']['codusr'] := AllTrim((cAlias)->AA1_CODUSR)
                        
                Else

                        oResponse['errorCode'] := 400
                        oResponse['errorMessage'] := EncodeUTF8("Usuário ou senha inválidos")
                        
                EndIf

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)

        Else
                
                oResponse['errorCode'] := 400
                oResponse['errorMessage'] := EncodeUTF8(cMensagem)

        EndIf 

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))       

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} paginasProdutos
Retorna a quantidade de páginas de produtos.

@author alexandre.takaki
@since 10/01/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET paginasProdutos WSRECEIVE nPageSize WSREST FSMAPP

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local nPageSize         := 10
        Local nPages            := 0

        If VALTYPE(Self:nPageSize) <> NIL .AND. Self:nPageSize > 10
                nPageSize := Self:nPageSize
        EndIf  

        cQuery := " SELECT  COUNT(1) TOTAL "
        cQuery += " FROM    " + RetSqlName('SB1') + "   SB1 "
        cQuery += " WHERE   SB1.B1_FILIAL               = ? "
        cQuery += " AND     SB1.D_E_L_E_T_              = ? "

        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    

        oQuery:SetString(1, xFilial("SB1"))
        oQuery:SetString(2, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())
                nPages := (cAlias)->TOTAL
                oResponse['pages'] := CEILING(nPages/nPageSize)      
        EndIf

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))  

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} produto
Retorna uma lista de produtos contendo código e nome do produto.

@author alexandre.takaki
@since 10/01/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET produto WSRECEIVE nPageSize, nPage WSREST FSMAPP

        Local lRet              := .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local nPage             := 1
        Local nPageSize         := 10
        Local nQtdRegIni        := 0
        Local nQtdRegFim        := 0
        Local nX                := 0
        Local nQtdReg           := 0
        Local nRecord           := 0
        Local lHasNext          := .F.
        Local cDescExp          := ""

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If VALTYPE(Self:nPageSize) <> NIL .AND. Self:nPageSize > 10
                nPageSize := Self:nPageSize
        EndIf

        If VALTYPE(Self:nPage) <> NIL .AND. Self:nPage > 1
                nPage := Self:nPage
        EndIf

        nQtdRegIni := (nPage-1) * nPageSize
        nQtdRegFim := nPage * nPageSize

        cQuery := " SELECT  SB1.B1_COD, SB1.B1_DESC "
        cQuery += " FROM    " + RetSqlName('SB1') + "   SB1 "
        cQuery += " WHERE   SB1.B1_FILIAL               = ? "
        cQuery += " AND     SB1.D_E_L_E_T_              = ? "

        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    

        oQuery:SetString(1, xFilial("SB1"))
        oQuery:SetString(2, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())

                oResponse['Produto'] := {}

                Do While (cAlias)->(!Eof())
                        nQtdReg++

                        If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
                             
                                nRecord++
                               
                                Aadd(oResponse['Produto'], JsonObject():New())
                                nX++
                                FncCaracEsp(EncodeUTF8((cAlias)->B1_COD),@cDescExp)
                                oResponse['Produto'][nX]['codigo'] := AllTrim(cDescExp)
                                FncCaracEsp(EncodeUTF8((cAlias)->B1_DESC),@cDescExp)
                                oResponse['Produto'][nX]['nome']   := AllTrim(cDescExp)

                        ElseIf  (nQtdReg == nQtdRegFim + 1)
                             
                                lHasNext := .T.
                                Exit   

                        EndIf

                        (cAlias)->(DbSkip())
                EndDo

                oResponse['hasNext'] := JsonObject():New()
                If lHasNext
                        oResponse['hasNext'] := "true"
                Else
                        oResponse['hasNext'] := "false"
                EndIf

                oResponse['count'] := JsonObject():New()
                oResponse['count'] := nRecord

                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))  

        EndIf

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} servico
Retorna uma lista de servicos utilizados no atendimento da ordem de serviço.

@author alexandre.takaki
@since 13/01/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET servico WSREST FSMAPP

        Local lRet              := .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local nX                := 0
        Local nRecord           := 0
        Local cDescExp          := ""

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")
        
        cQuery := " SELECT  JN1.JN1_CODIGO, JN1.JN1_DESCRI "
        cQuery += " FROM    " + RetSqlName('JN1') + "   JN1 "
        cQuery += " WHERE   JN1.JN1_FILIAL              = ? "
        cQuery += " AND     JN1.D_E_L_E_T_              = ? "

        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    

        oQuery:SetString(1, xFilial("JN1"))
        oQuery:SetString(2, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())

                oResponse['Service'] := {}

                Do While (cAlias)->(!Eof())
                                                     
                        nRecord++
                
                        Aadd(oResponse['Service'], JsonObject():New())
                        nX++
                        FncCaracEsp(EncodeUTF8((cAlias)->JN1_CODIGO),@cDescExp)
                        oResponse['Service'][nX]['codigo'] := AllTrim(cDescExp)
                        FncCaracEsp(EncodeUTF8((cAlias)->JN1_DESCRI),@cDescExp)
                        oResponse['Service'][nX]['nome']   := AllTrim(cDescExp)

                        (cAlias)->(DbSkip())
                EndDo

                oResponse['count'] := JsonObject():New()
                oResponse['count'] := nRecord

                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))  

        EndIf

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} agendas
Retorna as agendas do técnico para o dia selecionado.

@author alexandre.takaki
@since 13/01/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET agendas WSRECEIVE cAttendant, cDate WSREST FSMAPP

        Local lRet              := .T.
        Local cMensagem         := "Internal Server Error"
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local nX                := 0
        Local nY                := 0
        Local nRecord           := 0
        Local nW                := 0
        Local aLaudo            := {}
        
        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If Empty(Self:cAttendant)
                lRet := .F.
                cMensagem := "Informe um atendente para consulta"
        EndIf

        If Empty(Self:cDate)
                lRet := .F.
                cMensagem := "Informe uma data para realizar a consulta"
        EndIf

        If lRet

                cQuery := " SELECT	JN6.JN6_CODIGO, "
                cQuery += " 	        JN6.JN6_CODJN3, "
                cQuery += "             JN6.JN6_DTINI, "
                cQuery += "             MIN(JN6.JN6_HRINI) JN6_HRINI, "
                cQuery += "             MAX(JN6.JN6_HRFIM) JN6_HRFIM, "
                cQuery += "             JN6.JN6_SITUAC, "
                cQuery += "             JN3.JN3_NUMSER, "
		cQuery += "     	JN3.JN3_CODPRO, "
		cQuery += "     	SB1.B1_DESC, "
                cQuery += "             JN3.JN3_FILIAL, "
                cQuery += "             JN3.JN3_CLIENT, "
                cQuery += "             JN3.JN3_LOJA, "
                cQuery += "             JN1.JN1_CODIGO, "
                cQuery += "             JN1.JN1_DESCRI, "
                cQuery += "             SA1.A1_NOME, "
                cQuery += "             SA1.A1_END, "
                cQuery += "             SA1.A1_BAIRRO, "
                cQuery += "             SA1.A1_EST, "
                cQuery += "             SA1.A1_CEP, "
                cQuery += "             SA1.A1_MUN, "
                cQuery += "             SA1.A1_DDD, "
                cQuery += "             SA1.A1_TEL, "
                cQuery += "             SA1.A1_CONTATO, "
                cQuery += "             SA1.A1_EMAIL "
                cQuery += " FROM	" + RetSqlName('JN6') + "	JN6, "
                cQuery += "             " + RetSqlName('JN3') + "	JN3, "
                cQuery += "             " + RetSqlName('JN4') + "	JN4, "
                cQuery += "             " + RetSqlName('JN1') + "	JN1, "
                cQuery += "             " + RetSqlName('SA1') + "	SA1, "
                cQuery += "             " + RetSqlName('SB1') + "	SB1 "
                cQuery += " WHERE	JN6.JN6_FILIAL		        = ? "
                cQuery += " AND		JN6.JN6_CODAA1		        = ? "
                cQuery += " AND		JN6.JN6_DTINI		        = ? "
                cQuery += " AND		JN6.JN6_SITUAC		        IN (?,?,?,?,?,?,?,?,?) "
                cQuery += " AND		JN6.D_E_L_E_T_		        = ? "
                cQuery += " AND		JN3.JN3_FILIAL		        = JN6.JN6_FILIAL "
                cQuery += " AND		JN3.JN3_CODIGO		        = JN6.JN6_CODJN3 "
                cQuery += " AND		JN3.D_E_L_E_T_		        = ? "
                cQuery += " AND		JN4.JN4_FILIAL		        = JN6.JN6_FILIAL "
                cQuery += " AND		JN4.JN4_CODIGO		        = JN6.JN6_CODJN4 "
                cQuery += " AND		JN4.D_E_L_E_T_		        = ? "
                cQuery += " AND		JN1.JN1_CODIGO		        = JN4.JN4_CODJN1 "
                cQuery += " AND		JN1.D_E_L_E_T_		        = ? "
                cQuery += " AND		SA1.A1_FILIAL		        = ? "
                cQuery += " AND		SA1.A1_COD			= JN3.JN3_CLIENT "
                cQuery += " AND		SA1.A1_LOJA			= JN3.JN3_LOJA "
                cQuery += " AND		SA1.D_E_L_E_T_		        = ? "
                cQuery += " AND		SUBSTRING(SB1.B1_FILIAL,1,4)	= JN6.JN6_FILIAL "
                cQuery += " AND		SB1.B1_COD			= JN3.JN3_CODPRO "
                cQuery += " AND		SB1.D_E_L_E_T_		        = ? "
                cQuery += " GROUP BY	JN6.JN6_CODIGO, "
                cQuery += "             JN6.JN6_CODJN3, "
		cQuery += " 	        JN6.JN6_DTINI, "
		cQuery += " 	        JN6.JN6_SITUAC, "
                cQuery += "             JN3.JN3_NUMSER, "
		cQuery += "     	JN3.JN3_CODPRO, "
		cQuery += "     	SB1.B1_DESC, "
		cQuery += " 	        JN3.JN3_FILIAL, "
		cQuery += " 	        JN3.JN3_CLIENT, "
		cQuery += " 	        JN3.JN3_LOJA, "
                cQuery += "             JN1.JN1_CODIGO, "
                cQuery += "             JN1.JN1_DESCRI, "
		cQuery += " 	        SA1.A1_NOME, "
		cQuery += " 	        SA1.A1_END, "
		cQuery += " 	        SA1.A1_BAIRRO, "
		cQuery += " 	        SA1.A1_EST, "
		cQuery += " 	        SA1.A1_CEP, "
		cQuery += " 	        SA1.A1_MUN, "
		cQuery += " 	        SA1.A1_DDD, "
		cQuery += " 	        SA1.A1_TEL, "
		cQuery += " 	        SA1.A1_CONTATO, "
		cQuery += " 	        SA1.A1_EMAIL "
                
                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("JN6"))
                oQuery:SetString(2, Self:cAttendant)
                oQuery:SetString(3, Self:cDate)
                oQuery:SetString(4, EM_ATENDIMENTO)
                oQuery:SetString(5, EM_ABERTO)
                oQuery:SetString(6, EM_PAUSA)
                oQuery:SetString(7, ENCERRADO)
                oQuery:SetString(8, EM_DESLOCAMENTO)
                oQuery:SetString(9, FIM_DESLOCAMENTO)
                oQuery:SetString(10, AGUARDANDO_CLIENTE)
                oQuery:SetString(11, ATENDIMENTO_IMPRODUTIVO)
                oQuery:SetString(12, ATENDIMENTO_PENDENTE)
                oQuery:SetString(13, ' ')
                oQuery:SetString(14, ' ')
                oQuery:SetString(15, ' ')
                oQuery:SetString(16, ' ')
                oQuery:SetString(17, xFilial("SA1"))
                oQuery:SetString(18, ' ')
                oQuery:SetString(19, ' ')

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['schedule'] := {}

                        Do While (cAlias)->(!Eof())

                                nY := 0
                                nRecord++

                                Aadd(oResponse['schedule'], JsonObject():New())
                                nX++
                                oResponse['schedule'][nX]['codigoAgenda']       := AllTrim((cAlias)->JN6_CODIGO)
                                oResponse['schedule'][nX]['horaIni']            := AllTrim((cAlias)->JN6_HRINI)
                                oResponse['schedule'][nX]['horaFim']            := AllTrim((cAlias)->JN6_HRFIM)
                                oResponse['schedule'][nX]['numOS']              := AllTrim((cAlias)->JN6_CODJN3)
                                oResponse['schedule'][nX]['filialOS']           := AllTrim((cAlias)->JN3_FILIAL)
                                oResponse['schedule'][nX]['cliente']            := AllTrim((cAlias)->A1_NOME)
                                oResponse['schedule'][nX]['dataAgenda']         := AllTrim((cAlias)->JN6_DTINI)
                                oResponse['schedule'][nX]['codigoServico']      := EncodeUTF8(AllTrim((cAlias)->JN1_CODIGO))
                                oResponse['schedule'][nX]['descricaoServico']   := EncodeUTF8(AllTrim((cAlias)->JN1_DESCRI))
                               
                                oResponse['schedule'][nX]['endereco'] := JsonObject():New()

                                oResponse['schedule'][nX]['endereco']['logradouro']     := EncodeUTF8(AllTrim((cAlias)->A1_END))
                                oResponse['schedule'][nX]['endereco']['bairro']         := EncodeUTF8(AllTrim((cAlias)->A1_BAIRRO))
                                oResponse['schedule'][nX]['endereco']['cidade']         := EncodeUTF8(AllTrim((cAlias)->A1_MUN))
                                oResponse['schedule'][nX]['endereco']['uf']             := EncodeUTF8(AllTrim((cAlias)->A1_EST))
                                oResponse['schedule'][nX]['endereco']['cep']            := EncodeUTF8(AllTrim((cAlias)->A1_CEP))
                                oResponse['schedule'][nX]['endereco']['contato']        := EncodeUTF8(AllTrim((cAlias)->A1_CONTATO))
                                oResponse['schedule'][nX]['endereco']['email']          := EncodeUTF8(AllTrim((cAlias)->A1_EMAIL))
                                oResponse['schedule'][nX]['endereco']['tel']            := EncodeUTF8(Alltrim((cAlias)->A1_DDD + " - " + (cAlias)->A1_TEL))
                                                                
                                oResponse['schedule'][nX]['statusOs']   := Alltrim((cAlias)->JN6_SITUAC)
                                oResponse['schedule'][nX]['enviado']    := "true"
                                oResponse['schedule'][nX]['tipoOs']     := ""
                                oResponse['schedule'][nX]['entida']     := "AB6"
                                oResponse['schedule'][nX]['ab7item']    := ""

                                oResponse['schedule'][nX]['itensOs']    := {}

                                Aadd(oResponse['schedule'][nX]['itensOs'], JsonObject():New())
                                nY++
                                oResponse['schedule'][nX]['itensOs'][nY]['numeroItem']          := ""
                                oResponse['schedule'][nX]['itensOs'][nY]['produto']             := EncodeUTF8(AllTrim((cAlias)->B1_DESC))
                                oResponse['schedule'][nX]['itensOs'][nY]['codProd']             := EncodeUTF8(AllTrim((cAlias)->JN3_CODPRO))
                                oResponse['schedule'][nX]['itensOs'][nY]['ID']                  := EncodeUTF8(AllTrim((cAlias)->JN3_NUMSER))
                                oResponse['schedule'][nX]['itensOs'][nY]['atendido']            := "false"
                                oResponse['schedule'][nX]['itensOs'][nY]['dataAgend']           := AllTrim((cAlias)->JN6_DTINI)
                                oResponse['schedule'][nX]['itensOs'][nY]['solicitaPeca']        := "false"
                                oResponse['schedule'][nX]['itensOs'][nY]['PecaBaixada']         := "false"
                                oResponse['schedule'][nX]['itensOs'][nY]['pecaRecebida']        := "false"
                                oResponse['schedule'][nX]['itensOs'][nY]['detailItem']          := ""
                                oResponse['schedule'][nX]['itensOs'][nY]['fullDetail']          := ""
                                oResponse['schedule'][nX]['itensOs'][nY]['expandItem']          := "0"

                                oResponse['schedule'][nX]['itensOs'][nY]['apontamento'] := JsonObject():New()
                                oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['produtos']     := {}
                                oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['fotos']        := {}
                                oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['requisicao']   := ""
                                
                                oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['laudo'] := {}
                                
                                aLaudo := getLaudo(AllTrim((cAlias)->JN6_CODJN3),AllTrim((cAlias)->JN6_CODIGO))
                                
                                For nW := 1 To Len(aLaudo)
                                        Aadd(oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['laudo'], JsonObject():New())
                                        oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['laudo'][nW]['codigo']          := aLaudo[nW][1]
                                        oResponse['schedule'][nX]['itensOs'][nY]['apontamento']['laudo'][nW]['descricao']       := EncodeUTF8(aLaudo[nW][2])
                                Next nW

                                oResponse['schedule'][nX]['assinatura']         := ""
                                oResponse['schedule'][nX]['responsavel']        := ""
                                oResponse['schedule'][nX]['dtIniVisita']        := ""
                                oResponse['schedule'][nX]['hrIniVisita']        := ""
                                oResponse['schedule'][nX]['dtIniChegada']       := ""
                                oResponse['schedule'][nX]['hrIniChegada']       := ""
                                oResponse['schedule'][nX]['dtIniEncerra']       := ""
                                oResponse['schedule'][nX]['hrIniEncerra']       := ""
                                oResponse['schedule'][nX]['compartilhado']      := ""

                                (cAlias)->(DbSkip())
                        EndDo

                        oResponse['count'] := JsonObject():New()
                        oResponse['count'] := nRecord

                Else

                        oResponse['errorCode'] := 400
                        oResponse['errorMessage'] := EncodeUTF8("Não foram encontrados registros.")        

                EndIf

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)

        Else
                oResponse['errorCode'] := 400
                oResponse['errorMessage'] := EncodeUTF8(cMensagem)
        EndIf

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))  

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} atualizaStatus

Atualização do Status da Ordem de Serviço

@author     Alexandre Takaki
@since      22/01/2025
/*/
//------------------------------------------------------------------------------
WSMETHOD PUT atualizaStatus WSREST FSMAPP

        Local oModel            := Nil
        Local lRet              := .F.
        Local oRequest          := JSonObject():New()
        Local oResponse	        := JsonObject():New()
        Local cBody             := Self:GetContent()
        Local cBaseAtend        := ""
        Local cData             := ""
        Local cHora             := ""
        Local aRet              := {}
        Local cOrigem           := ""
        Local cSituacao         := ""
        Local dData             := CTOD("  /  /  ")

        oRequest:fromJson(cBody)

        If Valtype(oRequest['origem']) == "N"
                cOrigem := cValToChar(oRequest['origem'])
        Else
                cOrigem := oRequest['origem']
        EndIf

        If Valtype(oRequest['situacao']) == "N"
                cSituacao := StrZero(oRequest['situacao'],2)
        Else
                cSituacao := oRequest['situacao']
        EndIf

        JN3->(dbSetOrder(1))
        If JN3->(dbSeek(xFilial('JN3')+oRequest['numOs']))
                cBaseAtend := Alltrim(JN3->JN3_CODPRO)
        EndIf
        JN3->(dbCloseArea())

        If !Empty(oRequest['utc'])
                If cOrigem == "3" //Off-line
                        cData := oRequest['data']
                        cHora := oRequest['hora']
                ElseIf cOrigem == "2" //On-line
                        aRet := GetUTCDateTime(oRequest['utc'])
                        cData := aRet[1]
                        cHora := aRet[2]                      
                EndIf        
        Else                
                If cOrigem == "3"
                        cData := oRequest['data']
                        cHora := oRequest['hora']
                Else
                        cData := DTOS(Date())
                        cHora := Time()
                EndIf
        EndIf

        JN6->(dbSetOrder(1))
        If !(JN6->(dbSeek(xFilial('JN6')+oRequest['codAgenda'])))
                SetRestFault(404, EncodeUtf8("Código da Agenda não encontrada"))
                Return .F.
        Endif

        dData := StoD(cData)
        If Empty(dData)
                SetRestFault(400, EncodeUtf8("Data Inválida"))
                Return .F.
        EndIf

        If !validTime(cHora)
                SetRestFault(400, EncodeUtf8("Hora Inválida"))
                Return .F.
        EndIf

        oModel := FwLoadModel('FSMA011')

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        oModel:SetValue('JN6MASTER', 'JN6_CODIGO', oRequest['codAgenda'])
        oModel:SetValue('JN6MASTER', 'JN6_CODJN3', oRequest['numOs'])
        oModel:SetValue('JN6MASTER', 'JN6_CODAA1', oRequest['codTecnico'])
        oModel:SetValue('JN6MASTER', 'JN6_SITUAC', cSituacao)

        If !(oModel:GetModel('JNJDETAIL'):IsEmpty())
                oModel:GetModel('JNJDETAIL'):AddLine()
        EndIf
        
        oModel:SetValue('JNJDETAIL', 'JNJ_CODJN6', oRequest['codAgenda'])
        oModel:SetValue('JNJDETAIL', 'JNJ_CODATD', oRequest['codTecnico'])
        oModel:SetValue('JNJDETAIL', 'JNJ_DTINI', dData)
        oModel:SetValue('JNJDETAIL', 'JNJ_HRINI', cHora)
        oModel:SetValue('JNJDETAIL', 'JNJ_CODJN3', oRequest['numOs'])
        oModel:SetValue('JNJDETAIL', 'JNJ_BASE', cBaseAtend)
        oModel:SetValue('JNJDETAIL', 'JNJ_ORIGEM', cOrigem)
        oModel:SetValue('JNJDETAIL', 'JNJ_CODUSU', oRequest['codProtheus'])
        oModel:SetValue('JNJDETAIL', 'JNJ_SITUAC', cSituacao)

        If oModel:VldData()
                oModel:CommitData()
                lRet := .T.
                oResponse['sucessCode']         := 200
                oResponse['sucessMessage']      := EncodeUtf8('Ordem de serviço atualizada com sucesso')
                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
        Endif

        oModel:DeActivate()
        oResponse := Nil
        oRequest :=  Nil

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} historicoAtendimento

Retorna o historico do atendimento

@author     Alexandre Takaki
@since      07/02/2025
/*/
//------------------------------------------------------------------------------
WSMETHOD GET historicoAtendimento WSRECEIVE cEquipament, cID, cStartDt, cEndDt, nPerHist WSREST FSMAPP

        Local lRet              := .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cMessage          := "Internal Server Error"
        Local cDtIni            := ''
        Local cDtFim            := ''
        Local nPeriodo          := 60
        Local nRecord           := 0
        Local nX                := 0
        
        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        If !Empty(Self:nPerHist)
                nPeriodo := Self:nPerHist
        EndIf

        If Empty(Self:cStartDt)
                cDtIni := DTOS(dDataBase - nPeriodo)
        Else
                cDtIni := Self:cStartDt
        EndIf

        If Empty(Self:cEndDt)
                cDtFim := DTOS(dDataBase)
        Else
                cDtFim := Self:cEndDt
        EndIf

        If Empty(Self:cEquipament)
                lRet            := .F.
                nStatusCode     := 400
                cMessage        := "Informe um equipamento para a consulta"
        EndIf

        If Empty(Self:cID)
                lRet            := .F.
                nStatusCode     := 400
                cMessage        := "Informe o Id Unico do equipamento para a consulta"
        EndIf

        If lRet
                
                cQuery := " SELECT      JN3.JN3_DTINCL, "
                cQuery += "             JN3.JN3_SITUAC, "
                cQuery += "             JN3.JN3_CODIGO, "
                cQuery += "             JN3.JN3_CODPRO, "
                cQuery += "             JN3.JN3_NUMSER, "
                cQuery += "             TB_JN6.JN6_CODIGO "
                cQuery += " FROM        " + RetSqlName('JN3') + "	JN3 "
                cQuery += "             LEFT JOIN "
                cQuery += "             ( "
                cQuery += "                     SELECT	JN6_FILIAL, JN6_CODIGO, JN6_CODJN3 "
                cQuery += "                     FROM	" + RetSqlName('JN6') + " "
                cQuery += "                     WHERE	JN6_FILIAL	= ? "
                cQuery += "                     AND	D_E_L_E_T_	= ? "
                cQuery += "             ) TB_JN6 "
                cQuery += "             ON TB_JN6.JN6_FILIAL = JN3.JN3_FILIAL AND TB_JN6.JN6_CODJN3 = JN3.JN3_CODIGO, "
                cQuery += "             " + RetSqlName('JN4') + "       JN4 "
                cQuery += " WHERE	JN3.JN3_FILIAL	                = ? "
                cQuery += " AND	        TRIM(JN3.JN3_CODPRO)            = ? "
                cQuery += " AND	        JN3.JN3_DTINCL BETWEEN ? AND ? "
                cQuery += " AND	        TRIM(JN3.JN3_NUMSER)            = ? "
                cQuery += " AND	        JN3.D_E_L_E_T_	                = ? "
                cQuery += " AND	        JN4.JN4_FILIAL	                = JN3.JN3_FILIAL "
                cQuery += " AND	        JN4.JN4_CODJN3	                = JN3.JN3_CODIGO "
                cQuery += " AND	        JN4.D_E_L_E_T_	                = ? "

                cQuery  := ChangeQuery(cQuery)
                oQuery  := FWPreparedStatement():New(cQuery)    

                oQuery:SetString(1, xFilial("JN6"))
                oQuery:SetString(2, ' ')
                oQuery:SetString(3, xFilial("JN3"))
                oQuery:SetString(4, Alltrim(Self:cEquipament))
                oQuery:SetString(5, cDtIni)
                oQuery:SetString(6, cDtFim)
                oQuery:SetString(7, Alltrim(Self:cID))
                oQuery:SetString(8, ' ')
                oQuery:SetString(9, ' ')

                cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

                If (cAlias)->(!Eof())

                        oResponse['Historic'] := {}

                        Do While (cAlias)->(!Eof())

                                nRecord++

                                Aadd(oResponse['Historic'], JsonObject():New())
                                nX++
                                oResponse['Historic'][nX]['dataAbertura']       := AllTrim((cAlias)->JN3_DTINCL)
                                oResponse['Historic'][nX]['statusOs']           := Alltrim((cAlias)->JN3_SITUAC)
                                oResponse['Historic'][nX]['numOs']              := AllTrim((cAlias)->JN3_CODIGO)
                                oResponse['Historic'][nX]['codAgenda']          := Alltrim((cAlias)->JN6_CODIGO)
                                oResponse['Historic'][nX]['equipamento']        := AllTrim((cAlias)->JN3_CODPRO)
                                oResponse['Historic'][nX]['nomeEquipamento']    := StrTran(EncodeUTF8(Alltrim( Posicione("SB1",1,xFilial("SB1")+(cAlias)->JN3_CODPRO,"B1_DESC") )),'\','\\')
                                oResponse['Historic'][nX]['idUnico']            := AllTrim((cAlias)->JN3_NUMSER)
                                oResponse['Historic'][nX]['ocorrencia']         := ""
                               
                                (cAlias)->(DbSkip())
                        EndDo

                        oResponse['count'] := JsonObject():New()
                        oResponse['count'] := cBIStr( nRecord )

                Else

                        oResponse['errorCode'] := 400
                        oResponse['errorMessage'] := EncodeUTF8("Não foram encontrados registros.")        

                EndIf

                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

                (cAlias)->(dbCloseArea())
                oQuery:Destroy()
                FreeObj(oQuery)

        Else        

                SetRestFault( nStatusCode, EncodeUTF8(cMessage) )

        EndIf

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} detalhesAtendimento

Retorna os detalhes do atendimento para a ordem de serviço selecionada

@author     Alexandre Takaki
@since      07/02/2025
/*/
//------------------------------------------------------------------------------
WSMETHOD GET detalhesAtendimento WSRECEIVE cNumOS, cCodAgenda WSREST FSMAPP

        Local lRet              := .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local aItens            := {}
        Local nRecord           := 0
        Local nX                := 0
        Local nY                := 0
        Local nW                := 0

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")

        cQuery := " SELECT	JN3.JN3_FILIAL, "
	cQuery += " 	        JN3.JN3_CODIGO, "
	cQuery += " 	        JN3.JN3_DESCRI, "
	cQuery += " 	        JN3.JN3_CLIENT, "
	cQuery += " 	        JN3.JN3_LOJA, "
	cQuery += " 	        TB_JN6.JN6_CODIGO, "
	cQuery += " 	        TB_JN6.JN6_CODAA1, "
	cQuery += " 	        TB_JN6.JN6_DTINI, "
	cQuery += " 	        TB_JN6.JN6_HRINI, "
	cQuery += " 	        TB_JN6.JN6_DTFIM, "
	cQuery += " 	        TB_JN6.JN6_HRFIM, "
	cQuery += " 	        TB_JN6.JNY_DESCRI "
        cQuery += " FROM	" + RetSqlName('JN3') + "	JN3 "
        cQuery += "             LEFT JOIN "
        cQuery += "             ( "
        cQuery += "                     SELECT	JN6.JN6_FILIAL, JN6.JN6_CODIGO, JN6.JN6_CODJN3, JN6.JN6_CODAA1, JN6.JN6_DTINI, JN6.JN6_HRINI, JN6.JN6_DTFIM, JN6.JN6_HRFIM, "
        cQuery += "                             TB_JNY.JNY_DESCRI "
        cQuery += "                     FROM	" + RetSqlName('JN6') + "       JN6 "
        cQuery += "                             LEFT JOIN "
        cQuery += "                             ( "
        cQuery += "                                     SELECT	JNY_FILIAL, JNY_DESCRI, JNY_CODJN6, JNY_CODAA1 "
        cQuery += "                                     FROM	" + RetSqlName('JNY') + " "
        cQuery += "                                     WHERE	JNY_FILIAL	= ? "
        cQuery += "                                     AND	D_E_L_E_T_	= ? "
        cQuery += "                             ) TB_JNY "
        cQuery += "                             ON TB_JNY.JNY_FILIAL = JN6.JN6_FILIAL AND TB_JNY.JNY_CODJN6 = JN6.JN6_CODIGO AND TB_JNY.JNY_CODAA1 = JN6.JN6_CODAA1 "
        cQuery += "                     WHERE	JN6.JN6_FILIAL	= ? "
        cQuery += "                     AND	JN6.JN6_CODIGO	= ? "
        cQuery += "                     AND	JN6.D_E_L_E_T_	= ? "
        cQuery += "             ) TB_JN6 "
        cQuery += "             ON TB_JN6.JN6_FILIAL = JN3.JN3_FILIAL AND TB_JN6.JN6_CODJN3 = JN3.JN3_CODIGO "
        cQuery += " WHERE	JN3.JN3_FILIAL	= ? "
        cQuery += " AND		JN3.JN3_CODIGO	= ? "
        cQuery += " AND		JN3.D_E_L_E_T_	= ? "

        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    

        oQuery:SetString(1, xFilial("JNY"))
        oQuery:SetString(2, ' ')
        oQuery:SetString(3, xFilial("JN6"))
        oQuery:SetString(4, Self:cCodAgenda)
        oQuery:SetString(5, ' ')
        oQuery:SetString(6, xFilial("JN3"))
        oQuery:SetString(7, Self:cNumOS)
        oQuery:SetString(8, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())
        
                oResponse['Detail'] := {}

                Do While (cAlias)->(!Eof())

                        nRecord++

                        aItens := {}
                        aItens := OsAponta((cAlias)->JN3_CODIGO,(cAlias)->JN6_CODAA1,(cAlias)->JN6_CODIGO)

                        Aadd(oResponse['Detail'], JsonObject():New())
                        nX++
                        
                        If Len(aItens) > 0
                                oResponse['Detail'][nX]['atendente']   := EncodeUTF8(Alltrim(Posicione("AA1",1,xFilial("AA1")+(cAlias)->JN6_CODAA1,"AA1_NOMTEC")))
                                oResponse['Detail'][nX]['dtInicio']    := AllTrim((cAlias)->JN6_DTINI)
                                oResponse['Detail'][nX]['hrInicio']    := AllTrim((cAlias)->JN6_HRINI)
                                oResponse['Detail'][nX]['dtFim']       := AllTrim((cAlias)->JN6_DTFIM)
                                oResponse['Detail'][nX]['hrFim']       := AllTrim((cAlias)->JN6_HRFIM)
                                oResponse['Detail'][nX]['laudo']       := EncodeUTF8(Alltrim((cAlias)->JNY_DESCRI))
                        Else
                                nRecord := 0

                                oResponse['Detail'][nX]['atendente']   := ""
                                oResponse['Detail'][nX]['dtInicio']    := ""
                                oResponse['Detail'][nX]['hrInicio']    := ""
                                oResponse['Detail'][nX]['dtFim']       := ""
                                oResponse['Detail'][nX]['hrFim']       := ""
                                oResponse['Detail'][nX]['laudo']       := ""
                        EndIf        

                        oResponse['Detail'][nX]['itensApontados']    := {}

                        Aadd(oResponse['Detail'][nX]['itensApontados'], JsonObject():New())
                        
                        If Len(aItens) > 0
                                For nY := 1 To Len(aItens)
                                        nW++
                                        oResponse['Detail'][nW]['itensApontados'][nY]['produto']                := EncodeUtf8(Alltrim(aItens[nY][1]))
                                        oResponse['Detail'][nW]['itensApontados'][nY]['nomeProduto']            := EncodeUtf8(Alltrim(aItens[nY][2]))
                                        oResponse['Detail'][nW]['itensApontados'][nY]['id']                     := Alltrim(aItens[nY][3])
                                        oResponse['Detail'][nW]['itensApontados'][nY]['quantidade']             := Alltrim(AllToChar(aItens[nY][4]))
                                        oResponse['Detail'][nW]['itensApontados'][nY]['houveTroca']             := Alltrim(aItens[nY][6])
                                        oResponse['Detail'][nW]['itensApontados'][nY]['produtoTroca']           := EncodeUtf8(Alltrim(aItens[nY][7]))
                                        oResponse['Detail'][nW]['itensApontados'][nY]['nomeProdutoTroca']       := EncodeUTF8(Alltrim( Posicione("SB1",1,xFilial("SB1")+aItens[nY][7],"B1_DESC") ))
                                        oResponse['Detail'][nW]['itensApontados'][nY]['IdTroca']                := Alltrim(aItens[nY][8])
                                        oResponse['Detail'][nW]['itensApontados'][nY]['servico']                := EncodeUtf8(AllTrim(Posicione("AA5",1,xFilial("AA5")+aItens[nY][5],"AA5_DESCRI")))
                                Next nY
                        Else
                                oResponse['Detail'][nX]['itensApontados'][1]['produto']                := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['nomeProduto']            := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['id']                     := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['quantidade']             := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['houveTroca']             := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['produtoTroca']           := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['nomeProdutoTroca']       := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['IdTroca']                := ""
                                oResponse['Detail'][nX]['itensApontados'][1]['servico']                := ""
                        EndIf        

                        oResponse['Detail'][nX]['ocorrencia'] := ""

                        (cAlias)->(DbSkip())
                EndDo

                oResponse['count'] := JsonObject():New()
                oResponse['count'] := cBIStr( nRecord )

        Else

                oResponse['errorCode'] := 400
                oResponse['errorMessage'] := EncodeUTF8("Não foram encontrados registros.")     
        
        EndIf

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} arquivo

Upload de arquivos

@author     Alexandre Takaki
@since      24/02/2025
/*/
//------------------------------------------------------------------------------
WSMETHOD POST arquivo WSREST FSMAPP
        
        Local lRet              := .F.
        Local oRequest          := JSonObject():New()
        Local oResponse	        := JsonObject():New()
        Local cBody             := Self:GetContent()
        Local cDescriFix        := ""
        Local cDescExp          := ""
        Local cBase64           := ""
        Local nPos              := 0
        
        oRequest:fromJson(cBody)

        IF FncCaracEsp(DecodeUtf8(oRequest['cDescri']), @cDescExp)
                cDescriFix = cDescExp
        ELSE
                cDescriFix = DecodeUtf8(oRequest['cDescri'])
        EndIf

        If SubStr(oRequest['cBase64'],1,4) == "data"
                nPos := At(",",oRequest['cBase64'])
                If nPos > 0
                       cBase64 := SubStr(oRequest['cBase64'],nPos+1,Len(oRequest['cBase64'])) 
                EndIf
        Else
                cBase64 := oRequest['cBase64']
        EndIf        

        lRet := incFoto("JN6",oRequest['cNumAgenda'],cBase64,oRequest['cFileType'],cDescriFix)
        
        If lRet
                oResponse['sucessCode']         := 200
                oResponse['sucessMessage']      := EncodeUtf8('Foto incluida com sucesso')
                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
        EndIf
        
        oResponse := Nil
        oRequest :=  Nil
        
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} pagsFotos
Retorna o recno de cada arquivo gravado na tabela.

@author alexandre.takaki
@since 25/02/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET pagsFotos WSRECEIVE cCodAgenda WSREST FSMAPP

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")
        
        cQuery := " SELECT  R_E_C_N_O_                  REC "
        cQuery += " FROM    " + RetSqlName('JO0') + "   JO0 "
        cQuery += " WHERE   JO0.JO0_FILIAL              = ? "
        cQuery += " AND     JO0.JO0_ALIAS               = ? "
        cQuery += " AND     JO0.JO0_CODORI              = ? "
        cQuery += " AND     JO0.D_E_L_E_T_              = ? "

        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    

        oQuery:SetString(1, xFilial("JO0"))
        oQuery:SetString(2, 'JN6')
        oQuery:SetString(3, Self:cCodAgenda)
        oQuery:SetString(4, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())

                oResponse['registers'] := {}
                
                Do While (cAlias)->(!Eof())

                        aAdd(oResponse['registers'], (cAlias)->REC)

                        (cAlias)->(DbSkip())
                EndDo
                
        EndIf

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))  

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} fotos
Retorna os dados da foto solicitada pelo recnoId

@author alexandre.takaki
@since 25/02/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET fotos WSRECEIVE recPhoto WSREST FSMAPP

        Local lRet      	:= .T.
        Local oResponse		:= JsonObject():New()
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local cPath             := '\FSM\IMAGES\ATENDIMENTO\' 
        Local cString64         := ""
        Local cArquivo          := ""

        // define o tipo de retorno do método
        ::SetContentType("application/json;charset=UTF-8")
        
        cQuery := " SELECT  JO0.JO0_CODIGO, JO0.JO0_CODORI, CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),JO0.JO0_MIDIA)) JO0_MIDIA, JO0.JO0_NOMARQ, JO0.JO0_EXTARQ, JO0.JO0_DESCRI "
        cQuery += " FROM    " + RetSqlName('JO0') + "   JO0 "
        cQuery += " WHERE   JO0.JO0_FILIAL              = ? "
        cQuery += " AND     JO0.R_E_C_N_O_              = ? "
        cQuery += " AND     JO0.D_E_L_E_T_              = ? "

        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    

        oQuery:SetString(1, xFilial("JO0"))
        oQuery:SetString(2, cValToChar(Self:recPhoto))
        oQuery:SetString(3, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())

                cArquivo        := (cAlias)->JO0_NOMARQ
                cString64       := FncArqB64(cPath + cArquivo)

                oResponse['foto'] := JsonObject():New()
                oResponse['foto']['numAgenda']          := AllTrim((cAlias)->JO0_CODORI)  
                oResponse['foto']['itemOs']             := "01"
                oResponse['foto']['itemFoto']           := "01"
                oResponse['foto']['nomeArq']            := AllTrim((cAlias)->JO0_NOMARQ)
                oResponse['foto']['base64']             := cString64
                oResponse['foto']['description']        := AllTrim(EncodeUtf8((cAlias)->JO0_DESCRI))
                      
        EndIf

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))  

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} laudo
Realiza a alteração do laudo de uma OS.

@author alexandre.takaki
@since 17/03/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD PUT laudo WSREST FSMAPP

        Local oModel            := Nil
        Local lRet              := .F.
        Local oRequest          := JSonObject():New()
        Local oResponse	        := JsonObject():New()
        Local cBody             := Self:GetContent()
        Local cDescExp          := ""

        oRequest:fromJson(cBody)

        JNY->(dbSetOrder(1))
        
        If oRequest['cCodigo'] == Nil
                SetRestFault(404, EncodeUtf8("Código do Laudo é obrigatorio"))
                Return .F.                
        ElseIf Empty(oRequest['cCodigo'])
                SetRestFault(404, EncodeUtf8("Código do Laudo não pode ser vazio"))
                Return .F.                
        ElseIf !(JNY->(dbSeek(xFilial('JNY')+oRequest['cCodigo'])))
                SetRestFault(404, EncodeUtf8("Código do Laudo não encontrado"))
                Return .F.
        Endif

        If oRequest['cNewLaudo'] == Nil
                SetRestFault(404, EncodeUtf8("Descrição do Laudo é obrigatorio"))
                Return .F.                
        ElseIf Empty(oRequest['cNewLaudo'])
                SetRestFault(404, EncodeUtf8("Descrição do Laudo não pode ser vazio"))
                Return .F.      
        Endif

        FncCaracEsp(oRequest['cNewLaudo'],@cDescExp)

        oModel := FwLoadModel('FSMA025')

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        oModel:SetValue('JNYMASTER', 'JNY_CODIGO', oRequest['cCodigo'])
        oModel:SetValue('JNYMASTER', 'JNY_DESCRI', Alltrim(DecodeUTF8(cDescExp)))
        oModel:SetValue('JNYMASTER', 'JNY_DTINCL', dDataBase)
        
        If oModel:VldData()
                oModel:CommitData()
                lRet := .T.
                oResponse['sucessCode']         := 200
                oResponse['sucessMessage']      := EncodeUtf8('Laudo atualizado com sucesso')
                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
        Endif

        oModel:DeActivate()
        oResponse := Nil
        oRequest :=  Nil

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} visitaImprodutiva
Realiza a alteração do status da OS para Visita Improdutiva.

@author alexandre.takaki
@since 25/03/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD PUT visitaImprodutiva WSREST FSMAPP

        Local oModel            := Nil
        Local lRet              := .F.
        Local oRequest          := JSonObject():New()
        Local oResponse	        := JsonObject():New()
        Local cBody             := Self:GetContent()
        Local cBaseAtend        := ""
        Local cData             := ""
        Local cHora             := ""
        Local aRet              := {}
        Local cStatus           := ""
        Local dData             := CTOD("  /  /  ")
        Local cOrigem           := "1"
        Local cDescExp          := ""
        Local nX, nY            := 0
        Local cBase64           := ""
        Local nPos              := 0
        Local aFotos            := {}

        oRequest:fromJson(cBody)

        JN3->(dbSetOrder(1))
        
        If oRequest['numOS'] == Nil
                SetRestFault(404, EncodeUtf8("Número da OS é obrigatorio"))
                Return .F.  
        ElseIf Empty(oRequest['numOS'])
                SetRestFault(404, EncodeUtf8("Número da OS não pode ser vazio"))
                Return .F.  
        Else
                If JN3->(dbSeek(xFilial('JN3')+oRequest['numOS']))
                        cBaseAtend := Alltrim(JN3->JN3_CODPRO)
                Else
                        SetRestFault(404, EncodeUtf8("Número da OS não encontrado"))
                        Return .F.                
                EndIf
        EndIf

        JN6->(dbSetOrder(1))
        If JN6->(dbSeek(xFilial('JN6')+PadR(oRequest['codAgenda'],TamSx3("JN6_CODIGO")[1])))
                If JN6->JN6_SITUAC <> "06"  
                        SetRestFault(404, EncodeUtf8("Status da Agenda precisa estar 'Em deslocamento'"))
                        Return .F.
                EndIf      
        Else
                SetRestFault(404, EncodeUtf8("Código da Agenda não encontrada"))
                Return .F.
        Endif

        If Valtype(oRequest['statusOs']) == "N"
                cStatus := StrZero(oRequest['statusOs'],2)
        Else
                cStatus := StrZero(Val(oRequest['statusOs']),2)
        EndIf

        If !Empty(oRequest['utc'])
                aRet := GetUTCDateTime(oRequest['utc'])
                cData := aRet[1]
                cHora := aRet[2]
        Else                
                cData := DTOS(Date())
                cHora := Time()
        EndIf

        dData := StoD(cData)

        For nX := 1 To Len(oRequest['itensOs'])
                FncCaracEsp(oRequest['itensOs'][nX]['apontamento']['laudo'],@cDescExp)

                For nY := 1 To Len(oRequest['itensOs'][nX]['apontamento']['fotos'])
                        aAdd(aFotos,{;
                                oRequest['itensOs'][nX]['apontamento']['fotos'][nY]['base64'],;
                                oRequest['itensOs'][nX]['apontamento']['fotos'][nY]['description'],;
                                oRequest['itensOs'][nX]['apontamento']['fotos'][nY]['cFileType'];
                        })
                Next nY

        Next nX
        
        oModel := FwLoadModel('FSMA011')

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        oModel:SetValue('JN6MASTER', 'JN6_CODIGO', oRequest['codAgenda'])
        oModel:SetValue('JN6MASTER', 'JN6_CODJN3', oRequest['numOS'])
        oModel:SetValue('JN6MASTER', 'JN6_CODAA1', oRequest['CodTec'])
        oModel:SetValue('JN6MASTER', 'JN6_SITUAC', cStatus)

        If !(oModel:GetModel('JNJDETAIL'):IsEmpty())
                oModel:GetModel('JNJDETAIL'):AddLine()
        EndIf
        
        oModel:SetValue('JNJDETAIL', 'JNJ_CODJN6', oRequest['codAgenda'])
        oModel:SetValue('JNJDETAIL', 'JNJ_CODATD', oRequest['CodTec'])
        oModel:SetValue('JNJDETAIL', 'JNJ_DTINI', dData)
        oModel:SetValue('JNJDETAIL', 'JNJ_HRINI', cHora)
        oModel:SetValue('JNJDETAIL', 'JNJ_CODJN3', oRequest['numOS'])
        oModel:SetValue('JNJDETAIL', 'JNJ_BASE', cBaseAtend)
        oModel:SetValue('JNJDETAIL', 'JNJ_ORIGEM', cOrigem)
        oModel:SetValue('JNJDETAIL', 'JNJ_CODUSU', oRequest['codProtheus'])
        oModel:SetValue('JNJDETAIL', 'JNJ_SITUAC', cStatus)

        If !Empty(cDescExp)
                incLaudo(oRequest['numOS'],oRequest['codAgenda'],oRequest['CodTec'],Alltrim(DecodeUTF8(cDescExp)),oRequest['codProtheus'])
        EndIf        

        If Len(aFotos) > 0
                For nX := 1 To Len(aFotos)

                        If SubStr(aFotos[nX][1],1,4) == "data"
                                nPos := At(",",aFotos[nX][1])
                                If nPos > 0
                                cBase64 := SubStr(aFotos[nX][1],nPos+1,Len(aFotos[nX][1])) 
                                EndIf
                        Else
                                cBase64 := aFotos[nX][1]
                        EndIf

                        incFoto("JN6",oRequest['codAgenda'],cBase64,aFotos[nX][3],aFotos[nX][2])

                Next nX                
        EndIf        
        
        If oModel:VldData()
                oModel:CommitData()
                lRet := .T.
                oResponse['sucessCode']         := 200
                oResponse['sucessMessage']      := EncodeUtf8('Visita improdutiva atualizada com sucesso')
                Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
        Endif

        oModel:DeActivate()
        oResponse := Nil
        oRequest :=  Nil

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} encerramento
Realiza o encerramento da Ordem de Serviço.

@author alexandre.takaki
@since 28/03/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD PUT encerramento WSREST FSMAPP

Local aAreaReq          := GetArea()
Local oModel            := Nil
Local nProduto          := 0
Local nHora             := 0
Local lRet              := .F.
Local oRequest          := JSonObject():New()
Local oResponse	        := JsonObject():New()
Local cBody             := Self:GetContent()
Local cMsgError         := ""
Local nX                := 0
Local lProcessa         := oRequest <> Nil 
Local lContinua         := .T.
Local cCodJN4           := ''
Local oModelJO3         := Nil
Local aProdutos         := {}

BEGIN TRANSACTION
        if lProcessa .And. !Empty(cBody)
                oRequest:fromJson(cBody)

                // SOLICITAÇÃO DE PEÇAS
                For nX := 1 To Len(oRequest['itensOs'])
                        cCodJN4 := Alltrim(Posicione('JN6', 1, xFilial('JN6')+oRequest["codAgenda"],'JN6_CODJN4'))
                        If oRequest['itensOs'][nX]['solicitaPeca'] == 'true'   .And. !Empty(cCodJN4)        
                                aProdutos := oRequest['itensOs'][nX]['apontamento']['requisicao']['produtos']
                                For nProduto := 1 To Len(aProdutos)
                                        oModelJO3 := FwLoadModel('FSMA030')
                                        oModelJO3:SetOperation(MODEL_OPERATION_INSERT)
                                        oModelJO3:Activate()

                                        oModelJO3:SetValue('JO3MASTER', 'JO3_ITEM'  , StrZero(nProduto,2))
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_EMISSA', dDataBase)
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_LOCAL' , '01')
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_CODPRO', aProdutos[nProduto]["produto"])
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_QUANTI', Val(aProdutos[nProduto]["quantidade"]))
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_CODUSR', __cUserId)
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_CODAA1', oRequest['CodTec'])
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_CODJN4', cCodJN4)
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_ORIGEM', '1')
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_ALIAS', 'JN3')
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_CODORI', oRequest['numOS'])
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_STATUS', '01')
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_UNIMED', 'UN')
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_SEGUM' , 'CX')
                                        oModelJO3:SetValue('JO3MASTER', 'JO3_QTDSUM' , 1)

                                        If oModelJO3:VldData()            
                                                oModelJO3:CommitData()           
                                        Else
                                                lContinua := .F.
                                        Endif        
                                        
                                        oModelJO3:DeActivate()
                                Next nProduto

                        EndIf 
                Next nX                 
       

                //APONTAMENTO DE PRODUTOS
                if lContinua
                        For nX := 1 To Len(oRequest['itensOs'])
                                If Len(oRequest['itensOs'][nX]['apontamento']['produtos']) > 0    
                                        For nProduto := 1 To Len(oRequest['itensOs'][nX]['apontamento']['produtos'])
                                                IF JN3->(MsSeek(xFilial("JN3")+oRequest['numOS']))
                                        
                                                        oModel := FwLoadModel('FSMA008')
                                                        oModel:SetOperation(MODEL_OPERATION_UPDATE)
                                                        oModel:Activate()

                                                        oModel:GetModel('JN5DETAIL'):AddLine()
                                                        oModel:SetValue('JN5DETAIL', 'JN5_CODJN4', cCodJN4)
                                                        oModel:SetValue('JN5DETAIL', 'JN5_CODPRO', oRequest["itensOs"][1]["apontamento"]["produtos"][nProduto]["produto"])
                                                        oModel:SetValue('JN5DETAIL', 'JN5_QTDPRO', Val(oRequest["itensOs"][1]["apontamento"]["produtos"][nProduto]["quantidade"]))
                                                        oModel:SetValue('JN5DETAIL', 'JN5_ORIGEM', "3")
                                                        oModel:SetValue('JN5DETAIL', 'JN5_CODAA1', oRequest['CodTec'])
                                                        oModel:SetValue('JN5DETAIL', 'JN5_DTREQU', dDataBase)
                                                        oModel:SetValue('JN5DETAIL', 'JN5_REQUIS', '1')

                                                
                                                        oModel:GetModel('JO4DETAIL'):AddLine()
                                                        oModel:SetValue('JO4DETAIL', 'JO4_CODJN4', cCodJN4)
                                                        oModel:SetValue('JO4DETAIL', 'JO4_TPAPON', '00')
                                                        oModel:SetValue('JO4DETAIL', 'JO4_CODPRO', oRequest["itensOs"][1]["apontamento"]["produtos"][nProduto]["produto"])
                                                        oModel:SetValue('JO4DETAIL', 'JO4_QTDPRO', Val(oRequest["itensOs"][1]["apontamento"]["produtos"][nProduto]["quantidade"]))
                                                        oModel:SetValue('JO4DETAIL', 'JO4_STATUS', "2")
                                                        oModel:SetValue('JO4DETAIL', 'JO4_LIBEST', '6')
                                                        oModel:SetValue('JO4DETAIL', 'JO4_CODJN5', oModel:getModel("JN5DETAIL"):getValue("JN5_CODIGO"))

                                                        If oModel:VldData()            
                                                                oModel:CommitData()  
                                                        Else
                                                                lContinua := .F.
                                                        Endif
                                                        
                                                        oModel:DeActivate()
                                                EndIF        
                                        Next nProduto
                                        RestArea(aAreaReq)
                                EndIf 
                        Next nX
                Endif

                // APONTAMENTO DE HORAS
                If lContinua
                        For nX := 1 To Len(oRequest['itensOs'])
                                If Len(oRequest['itensOs'][nX]['apontamento']['apontamentoHoras']) > 0    
                                        If JN3->(MsSeek(xFilial("JN3") + oRequest['numOS']))
                                                For nHora := 1 To Len(oRequest['itensOs'][nX]['apontamento']['apontamentoHoras'])
                                                        oModel := FwLoadModel('FSMA024')
                                                        oModel:SetOperation(MODEL_OPERATION_INSERT)
                                                        oModel:Activate()

                                                        oModel:SetValue('JNVMASTER', 'JNV_CODAA1', oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["codTecnico"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_CODJN3', oRequest["numOS"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_CODJN6', oRequest["codAgenda"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_HRINI',  oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["horaIni"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_HRFIM',  oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["horaFim"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_DESCRI', oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["descricao"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_USUINC', __cUserId)
                                                        oModel:SetValue('JNVMASTER', 'JNV_DTINCL', oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["dataIncl"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_TMPATD', oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["totalHoras"])
                                                        oModel:SetValue('JNVMASTER', 'JNV_TIPSER', oRequest["itensOs"][nX]["apontamento"]["apontamentoHoras"][nHora]["codServico"])

                                                        If oModel:VldData()
                                                                oModel:CommitData()  
                                                        Else
                                                                lContinua := .F.
                                                        EndIf
                                                        
                                                        oModel:DeActivate()
                                                Next nHora
                                        EndIf        
                                EndIf 
                        Next nX
                EndIf

                RestArea(aAreaReq)
 

                if lContinua
                        lRet := EncerraOS(oRequest,@cMsgError)
                        If lRet 
                                oResponse['sucessCode']         := 200
                                oResponse['sucessMessage']      := EncodeUtf8(cMsgError)                        
                        Else
                                SetRestFault(404, (@cMsgError)) 
                                DisarmTransaction()
                                lRet := .F.
                        EndIf

                        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
                        oResponse := Nil
                        oRequest :=  Nil
                Else
                        DisarmTransaction()
                        SetRestFault(404, (@cMsgError)) 
                        lRet := .F.
                Endif        

         Endif        

End Transaction        

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} requisicaoPecas
Retorna o status da requisicao de pecas na ordem de servico.

@author alexandre.takaki
@since 28/04/2025
@version 1.00
*/
//-------------------------------------------------------------------
WSMETHOD GET requisicaoPecas WSRECEIVE cNumOS, cAttendant, cCodAgenda WSREST FSMAPP

        Local lRet      	:= .T.
        Local oQuery
        Local cQuery            := ""
        Local cAlias		:= GetNextAlias()
        Local oResponse		:= JsonObject():New()
        Local nQtde 		:= 0

        cQuery := " SELECT	JN6.JN6_CODIGO, JN6.JN6_CODJN3, "
        cQuery += "     	JO3.JO3_CODIGO, JO3.JO3_NUMSCP, JO3.JO3_ITSCP, JO3.JO3_QUANTI, JO3.JO3_STATUS STAJO3, "
        cQuery += "             CASE "
        cQuery += "                     WHEN JO3.JO3_STATUS = '01' THEN 'EM ABERTO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '02' THEN 'ANALISE' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '03' THEN 'APROVADO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '04' THEN 'REPROVADO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '05' THEN 'CORRECAO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '06' THEN 'ARQUIVADO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '07' THEN 'AUTOMATICO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '08' THEN 'ISENTO' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '09' THEN 'ANALISE' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '10' THEN 'PARCIAL' "
        cQuery += "                     WHEN JO3.JO3_STATUS = '11' THEN 'TOTAL' "
        cQuery += "             END JO3_STATUS, "
        cQuery += "             JO3.JO3_CODAA1, JO3.JO3_CODJN1, JO3.JO3_CODJN4, JO3.JO3_CODJN5, "
        cQuery += "             CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),JO3.JO3_MOTREP)) JO3_MOTREP, "
        cQuery += "             CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),JO3.JO3_MOTREJ)) JO3_MOTREJ 
        cQuery += " FROM	" + RetSqlName('JN6') + "       JN6, "
        cQuery += "             " + RetSqlName('JO3') + "	JO3 "
        cQuery += " WHERE	JN6.JN6_FILIAL	                = ? " 
        cQuery += " AND	        JN6.JN6_CODIGO	                = ? " 
        cQuery += " AND	        JN6.JN6_CODJN3	                = ? " 
        cQuery += " AND	        JN6.D_E_L_E_T_	                = ? " 
        cQuery += " AND	        JO3.JO3_FILIAL	                = ? " 
        cQuery += " AND	        JO3.JO3_ALIAS	                = ? " 
        cQuery += " AND	        JO3.JO3_CODAA1	                = ? " 
        cQuery += " AND	        JO3.JO3_CODORI	                = JN6.JN6_CODJN3 "
        cQuery += " AND	        JO3.JO3_CODJN4	                = JN6.JN6_CODJN4 "
        cQuery += " AND	        JO3.D_E_L_E_T_	                = ? " 
        
        cQuery  := ChangeQuery(cQuery)
        oQuery  := FWPreparedStatement():New(cQuery)    


        oQuery:SetString(1, xFilial("JN6"))
        oQuery:SetString(2, Self:cCodAgenda)
        oQuery:SetString(3, Self:cNumOS)
        oQuery:SetString(4, ' ')
        oQuery:SetString(5, xFilial("JO3"))
        oQuery:SetString(6, 'JN3')
        oQuery:SetString(7, Self:cAttendant)
        oQuery:SetString(8, ' ')

        cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

        If (cAlias)->(!Eof())
                oResponse['codAgenda']          := AllTrim((cAlias)->JN6_CODIGO)
                oResponse['ordemServico']       := AllTrim((cAlias)->JN6_CODJN3)
                oResponse['produtos']           := {}
                Do While (cAlias)->(!Eof())
                        nQtde++
                        Aadd(oResponse['produtos'], JsonObject():New())
                        oResponse['produtos'][nQtde]['codigo']          := AllTrim((cAlias)->JO3_CODIGO)
                        oResponse['produtos'][nQtde]['numSCP']          := AllTrim((cAlias)->JO3_NUMSCP)
                        oResponse['produtos'][nQtde]['itemSCP']         := AllTrim((cAlias)->JO3_ITSCP)
                        oResponse['produtos'][nQtde]['desStatus']       := AllTrim((cAlias)->JO3_STATUS)
                        oResponse['produtos'][nQtde]['quantidade']      := (cAlias)->JO3_QUANTI
                        oResponse['produtos'][nQtde]['status']          := AllTrim((cAlias)->STAJO3)
                        oResponse['produtos'][nQtde]['motReprova']      := AllTrim((cAlias)->JO3_MOTREP)
                        oResponse['produtos'][nQtde]['motRejeita']      := AllTrim((cAlias)->JO3_MOTREJ)

                        (cAlias)->(DbSkip())
                EndDo
        EndIf

        Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

        (cAlias)->(dbCloseArea())
        oQuery:Destroy()
        FreeObj(oQuery)                

Return lRet 
