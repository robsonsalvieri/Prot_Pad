#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC
#Include 'OGI100.CH'

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} OGI100O
//Adapter Safra
@author bruna.rocio / SIGAAGD
@since 09/03/2020
@version undefined
@param oEAIdef, object, objeto eai
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function OGI100O( oEAIdef, nTypeTrans, cTypeMessage )
	Local aArea		:= GetArea()		//Salva contexto do alias atual  
	Local aAreaNJU	:= NJU->(GetArea())	//Salva contexto do alias nju
	Local aSaveLine	:= FWSaveRows()		//Salva contexto do model ativo

	Local aRet 		  := {}				//Array de retorno da função
	Local lRet 		  := .T.			//Indica o resultado da execução da função	
	Local cError	  := ''				//Mensagem de erro do parse no json recebido como parâmetro
	Local cEvent	  := 'upsert'		//Operação realizada na master e na detail ( upsert ou delete )
	Local cCodSaf	  := ''				//Codigo da safra
	Local cId 		  := ''				//Código InternalId
	Local aMsgErro	  := {}				//Mensagem de erro na gravação do Model				
	Local cLogErro	  := ''				//Log de erro da execução da rotina
	Local cEntity	  := 'AgriculturalYear'
	Local nI          := 0 
	Local nCount	  := 0

	//--- Variaveis do Retorno - Função CFGA070Mnt [http://tdn.totvs.com/pages/viewpage.action?pageId=173083053]
	Local cReferen    := ''				//Referencia. Normalmente a "marca" da mensagem: PROTHEUS / LOGIX / RM / DATASUL, etc.
	Local cAlias	  := 'NJU'			//Alias do de/para (SA1, SA2, etc.)
	Local cField      := "NJU_CODSAF"	//É o campo de referencia do De/para (A1_COD, B1_COD, etc. )
	Local cValExt	  := ''				//Código externo para gravacao - Código InternalId do PIMS
	Local cValInt	  := ''				//Código interno para gravação
	Local lContinua	  := .T.
    
    Local oFwEAIobj  := FwEAIobj():new()
    Local oIntID     := Nil
    Local oMsgError  := Nil

    //novos campos criados para o modulo 54 - SIGAAGD (AgroDistribuidor)
    Local cAnoSaf  := ''
    Local dDtIni   := Ctod('')
    Local dDtFim   := Ctod('')

	Private oModel 	  := Nil 			//Objeto com o model da tabela de preços
	Private oModelNJU := Nil			//Objeto com o model da master apenas

    //--------------------------------------------
    //-- Trata o recebimento de mensagem
    //--------------------------------------------
    If ( nTypeTrans == TRANS_RECEIVE )

        //--------------------------------------------
        //-- Recebimento da Business Message
        //--------------------------------------------
        If ( cTypeMessage == EAI_MESSAGE_BUSINESS )

            // Leitura dos campos via oEAIdef (substitui o XmlParser manual)
            cReferen := oEAIdef:getHeaderValue("ProductName")

            If Empty(cReferen)
                lRet := .F.
                aRet := { lRet, STR0002, cEntity } //'Erro no retorno. A Referencia/Marca é obrigatória!'
                Return aRet
            EndIf

            cEvent  := AllTrim(Upper(oEAIdef:getEvent()))
            cId     := PADR( AllTrim(oEAIdef:getPropValue("InternalId")), TamSx3("NJU_ID")[1],     " " )
            cCodSaf := PADR( AllTrim(oEAIdef:getPropValue("Code")),       TamSx3("NJU_CODSAF")[1], " " )

            cAnoSaf := AllTrim(oEAIdef:getPropValue("AgriculturalYear"))

			If !Empty(oEAIdef:getPropValue("StartDate"))
				dDtIni := StoD(oEAIdef:getPropValue("StartDate"))
			EndIf

			If !Empty(oEAIdef:getPropValue("EndDate"))
				dDtFim := StoD(oEAIdef:getPropValue("EndDate"))
			EndIf

            // Carrega model com estrutura da Tabela de Safra
            oModel    := FwLoadModel( 'OGA100' )
            oModelNJU := oModel:GetModel('NJUUNICO')

            // Posiciona tabela NJU pelo InternalId
            dbSelectArea('NJU')
            NJU->( dbSetOrder(2) ) // Filial + ID
            lRet := NJU->( DbSeek( fwxFilial('NJU') + cId ) )

            If lRet
                cCodSaf := PADR(cCodSaf, TamSX3('NJU_CODSAF')[1], '')
                If cCodSaf != NJU->NJU_CODSAF //Alterou o codigo da Safra
                    NJU->( dbSetOrder(1) )
                    If NJU->( DbSeek( fwxFilial('NJU') + cCodSaf ) )
                        lContinua := .F.
                        oFwEAIobj:Activate()
                        oFwEAIobj:setProp("ReturnContent")
                        oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", EncodeUTF8(STR0009)) // "Já existe um registro integrado com este código."
                        Return { .F., oFwEAIobj, cEntity }
                    EndIf
                EndIf
            EndIf

            If lContinua
                
                //Verifica a operação realizada
                If cEvent == 'UPSERT'
                    If lRet
                        oModel:SetOperation( MODEL_OPERATION_UPDATE )
                    Else
                        lRet := .T.
                        oModel:SetOperation( MODEL_OPERATION_INSERT )
                    EndIf
                ElseIf cEvent == 'DELETE'
                    //Exclusão do registro quando operação for Delete.
				    //Para registro com movimentações o retorno será mensagem do model para o adapter.
                    oModel:SetOperation( MODEL_OPERATION_DELETE )
                    lRet := .T.
                EndIf

                If ( oModel:nOperation == MODEL_OPERATION_UPDATE )
                    
                    //Reposiciona
                    NJU->( dbSetOrder(2) ) //Filial + Safra | NJU_FILIAL + NJU_ID
                    NJU->( DbSeek( fwxFilial('NJU') + cId ) )
                    If cCodSaf != NJU->NJU_CODSAF
                        lRet := .F.
                        oFwEAIobj:Activate()
                        oFwEAIobj:setProp("ReturnContent")
                        oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", EncodeUTF8(STR0010)) //"Não é permitido alterar o código da Safra no Protheus."
                        Return { lRet, oFwEAIobj, cEntity }
                    Else
                        oModel:Activate()
                        oModelNJU:LoadValue('NJU_CODSAF', cCodSaf)
                        oModelNJU:SetValue('NJU_DESCRI', AllTrim(oEAIdef:getPropValue("Description")))
                        oModelNJU:SetValue('NJU_ANOSAF', cAnoSaf)
						oModelNJU:SetValue('NJU_DTINI',  dDtIni)
						oModelNJU:SetValue('NJU_DTFIM',  dDtFim)
                    EndIf

                ElseIf ( oModel:nOperation == MODEL_OPERATION_INSERT )
                    oModel:Activate()
                    oModelNJU:SetValue('NJU_FILIAL', fwxFilial('NJU'))
                    oModelNJU:SetValue('NJU_CODSAF', cCodSaf)
                    oModelNJU:SetValue('NJU_DESCRI', AllTrim(oEAIdef:getPropValue("Description")))
                    oModelNJU:SetValue('NJU_ID',     cId)
                    oModelNJU:SetValue('NJU_ANOSAF', cAnoSaf)
					oModelNJU:SetValue('NJU_DTINI',  dDtIni)
					oModelNJU:SetValue('NJU_DTFIM',  dDtFim)

                ElseIf ( oModel:nOperation == MODEL_OPERATION_DELETE )
                    //Reposiciona
                    NJU->( dbSetOrder(2) ) //Filial + Safra | NJU_FILIAL + NJU_ID
                    NJU->( DbSeek( fwxFilial('NJU') + cId ) )
                    oModel:Activate()
                EndIf

                If lRet
                    If lRet := oModel:VldData()
                        //Grava o model
                        lRet := oModel:CommitData()
                    EndIf

                    If !lRet
                        // Trata erro de gravação do model
                        aMsgErro := oModel:GetErrorMessage()
                        cLogErro := ''
                        For nI := 1 To Len(aMsgErro)
                            If ( ValType( aMsgErro[nI] ) == 'C' )
                                cLogErro += aMsgErro[nI] + '|'
                            EndIf
                        Next nI

                        // Monta oFwEAIobj de Erro de execução da rotina automatica.
                        oFwEAIobj:Activate()
                        oFwEAIobj:setProp("ReturnContent")
                        oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", EncodeUTF8(cLogErro))
                    Else
                        //--------------------------------------------
                        //--- TRATAMENTO DE RETORNO PARA O DE/PARA
                        //--------------------------------------------
                        cValExt := cId
                        cValInt := FWCodEmp() + "|" + FWCodFil() + "|" + oModelNJU:GetValue('NJU_CODSAF')
                        
                        // Se o evento é diferente de DELETE
                        If oModel:nOperation != MODEL_OPERATION_DELETE
                            CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .F.,,, cEntity)
                        Else
                            // Exclui o registro na tabela XXF (de/para)
                            CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .T.,,, cEntity)
                        EndIf

                        // Monta retorno via oFwEAIobj
                        oFwEAIobj:Activate()
                        oFwEAIobj:setProp("ReturnContent")
                        oFwEAIobj:getPropValue("ReturnContent"):setProp("ListOfInternalID", {}, 'InternalId',, .T.)
                        oFwEAIobj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setProp("Name",        cEntity, , .T.)
                        oFwEAIobj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setProp("Origin",      cValExt, , .T.)
                        oFwEAIobj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setProp("Destination", cValInt, , .T.)
                    EndIf
                EndIf

                oModel:Deactivate()
                oModel:Destroy()

            EndIf


			//----------------------------------------------------------------------
			//--- RECEBIMENTO DA RESPONSEMESSAGE 
			//-- QUEM RECEBE É O PIMS - O MESMO É TRATADO PELA EQUIPE DO PIMS
			//-- REALIZADO NO FONTE É PARA TESTE COM INTEGRAÇÃO PROTHEUS X PROTHEUS
			//----------------------------------------------------------------------
        ElseIf ( cTypeMessage == EAI_MESSAGE_RESPONSE )

            lRet := .T.

            If oEAIdef:getPropValue("ProcessingInformation"):getPropValue("Status") != Nil ;
               .And. Upper(oEAIdef:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"

                // Verifica se a marca foi informada
                cReferen := oEAIdef:getHeaderValue("ProductName")
                If Empty(cReferen)
                    lRet := .F.
                    oFwEAIobj:Activate()
                    oFwEAIobj:setProp("ReturnContent")
                    oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", STR0002) ///'Erro no retorno. A Referencia/Marca é obrigatória!'
                    //Carrega array de retorno
                    Return { lRet, oFwEAIobj, cEntity }
                EndIf

                oIntID := oEAIdef:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")

                // Verifica se o código interno foi informado
                If oIntID != Nil .And. Len(oIntID) > 0 .And. ;
                   oIntID[1]:getPropValue("Origin") != Nil .And. !Empty(oIntID[1]:getPropValue("Origin"))
                    cValInt := oIntID[1]:getPropValue("Origin")
                Else
                    lRet := .F.
                    oFwEAIobj:Activate()
                    oFwEAIobj:setProp("ReturnContent")
                    oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", STR0003) //'Erro no retorno. O OriginalInternalId é obrigatório!'
                    //Carrega array de retorno
                    Return { lRet, oFwEAIobj, cEntity }
                EndIf

                // Verifica se o código externo foi informado
                If oIntID[1]:getPropValue("Destination") != Nil .And. !Empty(oIntID[1]:getPropValue("Destination"))
                    cValExt := oIntID[1]:getPropValue("Destination")
                Else
                    lRet := .F.
                    oFwEAIobj:Activate()
                    oFwEAIobj:setProp("ReturnContent")
                    oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", STR0004) //'Erro no retorno. O DestinationInternalId é obrigatório!'
                    //Carrega array de retorno
                    Return { lRet, oFwEAIobj, cEntity }
                EndIf

                // Obtém a mensagem original enviada
                If oEAIdef:getPropValue("ReceivedMessage") != Nil .And. ;
                   oEAIdef:getPropValue("ReceivedMessage"):getPropValue("Event") != Nil .And. ;
                   !Empty(oEAIdef:getPropValue("ReceivedMessage"):getPropValue("Event"))
                    cEvent := AllTrim(Upper(oEAIdef:getPropValue("ReceivedMessage"):getPropValue("Event")))
                Else
                    lRet := .F.
                    oFwEAIobj:Activate()
                    oFwEAIobj:setProp("ReturnContent")
                    oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", STR0005) //'Conteúdo do MessageContent vazio!'
                    //Carrega array de retorno
                    Return { lRet, oFwEAIobj, cEntity }
                EndIf

                // Processa o de/para conforme o evento
                If cEvent == 'UPSERT'
                    // Insere / Atualiza o registro na tabela XXF (de/para)
                    CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .F.,,, cEntity)
                ElseIf cEvent == 'DELETE'
                    // Exclui o registro na tabela XXF (de/para)
                    CFGA070Mnt(cReferen, cAlias, cField, cValExt, cValInt, .T.,,, cEntity)
                Else
                    lRet := .F.
                    oFwEAIobj:Activate()
                    oFwEAIobj:setProp("ReturnContent")
                    oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", STR0006) //'Evento do retorno inválido!'
                EndIf

            Else
                // Percorre o array para obter os erros gerados
                lRet      := .F.
                cError    := ''
                oMsgError := oEAIdef:getPropValue("ProcessingInformation"):getPropValue("ListOfMessages")
                For nCount := 1 To Len(oMsgError)
                    cError += oMsgError[nCount]:getPropValue("Message") + Chr(10)
                Next nCount
                oFwEAIobj:Activate()
                oFwEAIobj:setProp("ReturnContent")
                oFwEAIobj:getPropValue("ReturnContent"):setProp("Error", cError)
            EndIf

			//--------------------------------------------
			//--- RECEBIMENTO DA WHOIS   
			//--------------------------------------------	
        ElseIf ( cTypeMessage == EAI_MESSAGE_WHOIS )
            lRet := .T.
            Return { lRet, "1.000|1.001|1.002", cEntity }
        EndIf

		//--------------------------------------------
		//--- ENVIO PARA INTEGRAÇÃO 
		//--------------------------------------------
    ElseIf ( nTypeTrans == TRANS_SEND )

        lRet      := .T.
        oModel    := FWModelActive()                //Instancia objeto model
        oModelNJU := oModel:GetModel( 'NJUUNICO' )  //Instancia objeto model tabela especifica

        //Verifica se a tabela está sendo excluída
        If ( oModel:nOperation == 5 )
            cEvent := 'delete'
        EndIf
        
        //Monta Business Event
        oFwEAIobj:Activate()
        oFwEAIobj:setHeader("Entity", cEntity)
        oFwEAIobj:setEvent(cEvent)

        // BusinessContent
        oFwEAIobj:setProp("Code",             RTrim(oModelNJU:GetValue('NJU_CODSAF')))
        oFwEAIobj:setProp("InternalId",       FWCodFil() + "|" + RTrim(oModelNJU:GetValue('NJU_CODSAF')))
        oFwEAIobj:setProp("Description",      RTrim(oModelNJU:GetValue('NJU_DESCRI')))
        oFwEAIobj:setProp("AgriculturalYear", RTrim(oModelNJU:GetValue('NJU_ANOSAF')))
		oFwEAIobj:setProp("StartDate",        DtoS(oModelNJU:GetValue('NJU_DTINI')))
		oFwEAIobj:setProp("EndDate",          DtoS(oModelNJU:GetValue('NJU_DTFIM')))

    EndIf

    //-------------------------------------
    //-- Carrega array de retorno - PARA INTEGRAÇÃO
    aRet := { lRet, oFwEAIobj, cEntity }
    //-------------------------------------

    // Restaura ambiente
    FWRestRows( aSaveLine )
    RestArea( aAreaNJU )
    RestArea( aArea )

Return aRet
