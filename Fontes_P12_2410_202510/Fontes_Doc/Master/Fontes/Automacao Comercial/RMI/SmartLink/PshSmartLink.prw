#INCLUDE "PROTHEUS.CH"
#INCLUDE "PSHSMARTLINK.CH"

/*/{Protheus.doc} pshMessageReader
Classe de processamento de mensagens da fila
@type class
@author Everson P.
/*/
Class pshMessageReader from LongNameClass
 
    method New()                                    //Método construtor da classe

    method Read()                                   // Método responsável pela leitura e processamento da mensagem      
    method Grava()                                  // Método para gravar a mensagem após leitura
 
EndClass
 
/*/{Protheus.doc} pshMessageReader::New
construtor
@type method
@author Everson P.
/*/
method New() Class pshMessageReader
 
return self
 
/*/{Protheus.doc} PShMessageReader::Read
Responsável pela leitura e processamento da mensagem.
@type method
@author Everson P.
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, Determina se deve ou não retirar a mensagem da fila.
/*/
method Read( oLinkMessage ) Class pshMessageReader
    Conout("Iniciando: Lendo mensagem da fila SmartLink...")
    self:Grava( oLinkMessage)
    Conout("Finalizando: Lendo mensagem da fila SmartLink...")
return .T.

/*/{Protheus.doc} PShMessageReader::Grava
Responsável por gravar a mensagem lida na tabela correspondente.
@type method
@author Evandro Pattaro
@param cMessage, character, Mensagem a ser gravada.
@return logical, Retorna .T. se a gravação for bem sucedida.
/*/
method Grava(oLinkMessage) Class pshMessageReader

    Local oJson     := Nil
    Local aCampos   := {}
    Local lInclui   := .F.
    Local nCont     := 0
    Local nField    := 0
    Local xValor    := Nil
    Local cTabela   := ""
    Local cChave    := ""
    Local cProcesso := ""
    Local cMessage  := oLinkMessage:RawMessage()
    Local lblob     := .F.
    Local nRecno    := 0
    Local lStruct   := .F. //Indica se a estrutura deve ser validada
    Local cTags     := "|D_E_L_E_T_|R_E_C_N_O_|R_E_C_D_E_L_|S_T_A_M_P_|I_N_S_D_T_|STAMP|processo|tabela|uuid|vldStruct|data|chave"
    //Variáveis para tratamento de erro
    Local bErrorBlock   := Nil
    Local lErrorBlock   := .F.
    Local cErrorBlock   := ""
    Local cUuid         := ""
    Local nIndex        := 1
    Local cCampos       := ""
    Local cIndice       := ""
    Local lBlock        := .F.

    If !Empty(cMessage)
       
        oJson := JsonObject():New()
        oJson:FromJson(cMessage)

        bErrorBlock := ErrorBlock( {|oErro| RmiErroBlock(oErro, @lErrorBlock, @cErrorBlock)} )
       
        Begin Sequence

            Begin Transaction
                If Valtype(oJson["data"]) == "A" .And. len(oJson["data"]) > 0
                    lBlob       := FwSX2Util():GetSX2data(oJson["data"][1]["tabela"], {"X2_CLOB"})[01,02] == '2' //executar uma vez por processo.
                    lStruct     := oJson["vldStruct"] //Indica se a estrutura deve ser validada
                    cTabela     := oJson["data"][1]["tabela"]
                                        
                    
                    While (cIndice:= (cTabela)->(IndexKey(nIndex))) != oJson["indiceCampos"] .And. !Empty(cIndice)
                        nIndex++    
                    EndDo
                    
                    If !Empty((cTabela)->(IndexKey(nIndex)))
                        (cTabela)->( dbSetOrder(nIndex))
                    Else
                        cErrorBlock += " Verifique o seu cadastro de processos ("+oJson["data"][1]["processo"]+") "+" Os campos da chave "+oJson["indiceCampos"]+" não correspondem a nenhum índice da tabela "+oJson["data"][1]["tabela"]
                        lErrorBlock := .T.
                    EndIf
                    
                    If !lErrorBlock
                        //Verifico se é um campo de tabela válido, se não for, gravo o erro e saio do processamento da mensagem
                        //Monto o acampos com estrutura de validação, acampos[1][1] = nome do campo, acampos[1][2] = posição do campo na tabela, acampos[1][3] = tipo do campo
                        aEval(oJson["data"][1]:GetNames(),{|x| IIF( (cTabela)->(FieldPos(x)) == 0 ,{lBlock := !(x $ cTags) .Or. "_" $ x,cCampos := x},aadd(aCampos,{x,(cTabela)->(FieldPos(x)),Valtype((cTabela)->&(x))})) }) //Monta a chave de busca
                        //Valida se todos os campos existem na tabela                    
                        If lBlock
                            cErrorBlock:= "Verifique a integridade da suas bases Retaguarda e Central-PDV o campo "+cCampos+" não existe "
                            LjGrvLog(" pshMessageReader ",cErrorBlock,{"Tabela -"+cTabela,"campo não existe na Central "+cCampos})    
                            //Se lStruct true validar a estrutura se o campo existir na mensagem retorna erro para MHL de base inválida.
                            If lStruct 
                                lErrorBlock := .T.
                            EndIf 
                        EndIf
                    EndIf
                    
                    If lErrorBlock
                        nRecno      := oJson["data"][1]["R_E_C_N_O_"]
                        cUuid       := oJson["data"][1]["uuid"]
                        cProcesso   := oJson["data"][1]["processo"]
                        cChave      := oJson["data"][1]["chave"]
                        DisarmTransaction()
                        Break
                    EndIf
                    
                    For nCont:=1 to len(oJson["data"])
                        cChave := StrTran( oJson["data"][nCont]["chave"], "|", "" )
                        cProcesso := oJson["data"][nCont]["processo"]
                        nRecno    := oJson["data"][nCont]["R_E_C_N_O_"]
                        cUuid     := oJson["data"][nCont]["uuid"]
                        cTabela   := oJson["data"][nCont]["tabela"]
                        


                        if (cTabela)->( dbSeek(cChave) )
                            lInclui := .F.
                        else
                            lInclui := .T.
                        endif

                        LjGrvLog(" pshMessageReader ", I18n(STR0002, {IIF(lInclui,"Incluindo","Alterando"), cTabela, cChave})) // "#1 registro da tabela #2 - chave: #3"
                        
                        
                            recLock(cTabela, lInclui)
                            
                            for nField := 1 to len(aCampos)
                                xValor := ""
                                xValor := oJson["data"][nCont][aCampos[nField][1]]
                                
                                Do Case
                                    Case aCampos[nField][3] == "D"
                                        xValor := sToD(xValor)
                                    Case aCampos[nField][3] == "L"
                                        xValor := (xValor == 'T')
                                    Case aCampos[nField][3] == "M" .AND. lBlob
                                        xValor := Decode64(xValor) 
                                End Case   
                                
                                (cTabela)->( FieldPut(aCampos[nField][2], xValor) )
                                
                            next nField

                            (cTabela)->( msUnLock() )
                        
                    next nCont
                EndIf

                //Caso tenha algum erro capturado pelo ErrorBlock força a saida para o Recover
                If lErrorBlock
                    DisarmTransaction()
                    Break
                EndIf
            End Transaction
        
        End Sequence
        
        If lErrorBlock
            LjxjMsgErr( I18n(STR0003, {AllTrim(cTabela), AllTrim(cChave)} ) + allTrim(cErrorBlock) ) //"pshMessageReader - Erro ao executar a gravação na tabela #1 , registro #2 "
                //Retorna o ultimo erro do sistema grava no ultimo recno do pacote para gerar um acumulado.
                rmiGrvLog(  "3"  , AllTrim(cTabela) ,nRecno , "BAIXA",;
                            allTrim(cErrorBlock), /*lRegNew*/   , /*lTxt*/          , /*cFilStatus*/    ,;
                            .F., /*nIndice*/, IIF(Empty(cChave),oJson["time"],cChave)   , cProcesso   ,;
                            "SMARTLINK" , cUuid)
            //Restaura tratamento de erro anterior
        EndIf
        
        ErrorBlock(bErrorBlock)

    EndIf
    fwFreeArray(aCampos)
    fwFreeObj(oJson)

Return .T.
