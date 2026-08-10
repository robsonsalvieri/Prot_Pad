#INCLUDE "PROTHEUS.CH"

Static lStRmixFil   := existFunc("rmixFilial")      //Verifica se existe a função que vai retornar as filiais

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiBusPdvSyncObj
Classe responsável pela busca de dados no PdvSync
    
/*/
//-------------------------------------------------------------------
Class RmiBusPdvSyncObj From RmiBuscaObj

    Method New()	                    //Metodo construtor da Classe

    Method SetaProcesso(cProcesso)      //Metodo responsavel por carregar as informações referente ao processo que será recebido

    Method SetArrayFil()                //Carrega a propriedade aArrayFil com o conteudo do campo MHP_FILPRO

    Method PreExecucao()                //Metodo com as regras para efetuar conexão com o sistema de destino

    Method Busca()                      //Metodo responsavel por buscar as informações no Assinante

    Method Confirma()                   //Metodo para confirmar a publicação de venda

    Method TrataRetorno()               //Metodo para buscar/Get as publicações no PdvSync como Exemplo: Vendas ou Clientes.
    
    Method LayEstAuto(cCmpRet)          //Metodo especifico para enviar dados ao Metodo generico GetLayEst

    Method AuxTrataTag(cTag, xConteudo, nItem)      //Metodo para efetuar o tratamento das Tags que serão gravadas na publicação

    Method IgnoraPub()                              //Metodo que define se ignora uma publicação

    Method setEvento()                              //Metodo que define o evento a ser gravado na MHQ

    Method AddConfirma()                            //Metodo que carrega os registros que serão confirmados
    
    Method GetReserva(nItem)                        //Retorna o numero da reserva para grava na SL2

    Method Grava()                                  //Metodo que efetua a gravação da publicação
    Method setStatusSync()                          //Atualizar o Status da venda no PdvSync
    Method setDtEnvio()                             //Atualiza a data de envio na tabela MIP

    Data oXmlSefaz      as Object                   //Objeto com o XML da SEFAZ - TAG VendaCustodiaXml
    Data nCustodia      as Integer                  //Posição da TAG VendaCustodiaXml
    Data oConteudo      as Object                   //Objeto json com a taga conteudo
    Data aConfirma      as Array                    //Array de objetos json com as confirmações
    Data oPdvSync       as Object                   //Objeto PdvSync
    Data cNumRes        as Character                //Acumula numero da reservada.
    Data dDtDado        as Date                     //Data do dado, será gravada na tabela MIP
    Data nValor         as Date                     //Valor do dado, será gravada na tabela MIP
    Data aRecno         as Array                    //Array para ultimo recno da busca para atulizar MIP

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cAssinante) Class RmiBusPdvSyncObj

    Local cTenent       := ""
    Local cUser         := ""
    Local cPassword     := ""
    Local cClientId     := ""
    Local cClientSecret := ""
    Local nEnvironment  := 0
    Default cAssinante := "PDVSYNC"
    
    _Super:New(cAssinante)

    self:oXmlSefaz := Nil
    self:nCustodia := 1
    self:oConteudo := JsonObject():New()
    self:aConfirma := {}
    self:dDtDado   := dDataBase
    self:nValor    := 0

    If self:oConfAssin:hasProperty("autenticacao")  
        cTenent       := IIF( self:oConfAssin["autenticacao"]:hasProperty("tenent")         , self:oConfAssin["autenticacao"]["tenent"]         , "")
        cUser         := IIF( self:oConfAssin["autenticacao"]:hasProperty("user")           , self:oConfAssin["autenticacao"]["user"]           , "")
        cPassword     := IIF( self:oConfAssin["autenticacao"]:hasProperty("password")       , self:oConfAssin["autenticacao"]["password"]       , "")
        cClientId     := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientId")       , self:oConfAssin["autenticacao"]["clientId"]       , "")
        cClientSecret := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientSecret")   , self:oConfAssin["autenticacao"]["clientSecret"]   , "")
        nEnvironment  := IIF( self:oConfAssin["autenticacao"]:hasProperty("environment")    , self:oConfAssin["autenticacao"]["environment"]    , 1 )
    EndIf

    If self:lSucesso
        If FindClass("totvs.protheus.retail.rmi.classes.pdvsync.PdvSync") //Incluido dependencia automatica
            self:oPdvSync := totvs.protheus.retail.rmi.classes.pdvsync.PdvSync():New(cTenent, cUser, cPassword, cClientId, cClientSecret, nEnvironment)       
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaProcesso
Metodo responsavel por carregar as informações referente ao processo que será buscado

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetaProcesso(cProcesso) Class RmiBusPdvSyncObj


    self:cStatus := "0"  //0=Fila;1=A Processar;2=Processada;3=Erro

    //Chama metodo da classe pai para buscar informações comuns
    _Super:SetaProcesso(cProcesso)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo com as regras para efetuar conexão com o sistema de destino
Exemplo obter um token

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiBusPdvSyncObj
    
    Local aMensagem := {}

    If (aMensagem := self:oPdvSync:Token())[1]
        self:aHeader := self:oPdvSync:getHeader()
    else
        self:lSucesso := aMensagem[1]
        self:cRetorno := aMensagem[2]
    EndIf

Return self:lSucesso

//-------------------------------------------------------------------
/*/{Protheus.doc} Busca
Metodo responsavel por buscar as informações no Assinante

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Busca() Class RmiBusPdvSyncObj

    Local cIdProprietario := ""
    Local cPath           := ""
    Local lContinua       := .F.
    Local cParams         := ""
    Local aParams         := self:oLayoutEnv:GetNames() //Array de parametros para a chamada do Get
    Local nPsh            := 0 // Elemento do Array onde se encontra a tag 'configPSH' (controle de versionamento)
    Local nI              := 0

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If self:lSucesso

        nPsh := aScan(aParams,{|x| Alltrim(x) == "configPSH"})
        If nPsh > 0
            aDel(aParams,nPsh) //Removo o elemento contendo 'configPSH' para não adicioná-lo como parâmetro 
            aSize(aParams,Len(aParams) - 1)
        EndIf

        For nI := 1 To Len(aParams)
            If nI > 1
                cParams += "&"    
            EndIf

	        If  !SubStr(self:oLayoutEnv[aParams[nI]], 1, 1) == "&" // Tratamento para macro executar a configuração de envio.
	            cParams += aParams[nI] +"="+ self:oLayoutEnv[aParams[nI]]
	        else            
	            cParams += aParams[nI] +"="+ &(AllTrim(SubStr(self:oLayoutEnv[aParams[nI]],2)))
	        EndIf    

        Next nI

        If self:oBusca == Nil
            self:oBusca := FWRest():New("")
        EndIf

        cPath := Alltrim(self:oConfProce["url"]) + self:oConfAssin["inquilino"]
      

        If self:oLayoutEnv:HasProperty("listIdProprietario") //valido a tag listIdProprietario
	        If  !SubStr(self:oLayoutEnv["listIdProprietario"], 1, 1) == "&" 
	            cIdProprietario := self:oLayoutEnv["listIdProprietario"]
	        else            
	            cIdProprietario := &(AllTrim(SubStr(self:oLayoutEnv["listIdProprietario"],2)))
	        EndIf        
            lContinua := !Empty(cIdProprietario)
        Else
            lContinua := .T.        
        EndIf    
                    
        if lContinua

            self:oBusca:SetPath(cPath)

            If !Empty(cParams)
                self:oBusca:SetGetParams(cParams)    
            EndIf

            If self:oBusca:Get( self:aHeader )

                self:cRetorno := self:oBusca:GetResult()

                If self:oRetorno == Nil
                    self:oRetorno := JsonObject():New()
                EndIf

                LjGrvLog("RmiBusPdvSyncObj", "Retorno da API do PDV Sync sem nenhum tratamento:", self:cRetorno)

                self:oRetorno:FromJson(self:cRetorno)
                self:cRetorno := ""

                //Centraliza os retorno permitidos
                self:TrataRetorno()

                //Envia o status de processamento para o PDVSYNC exceto CONSOLIDADO, que não tem status de processamento
                self:aRecno := {}
                If self:lDetDistrib .and. alltrim(self:cProcesso) <> "CONSOLIDADO" .and. MIP->( ColumnPos("MIP_DTCONF") ) > 0
                    self:setStatusSync()
                endIf
            Else

                self:lSucesso := .F.
                self:cRetorno := self:oBusca:GetLastError() + " - [" + self:oConfProce["url"] + "]" + CRLF
            EndIf
            
        else
        
            self:lSucesso := .F.
            LjGrvLog("RmiBusPdvSyncObj", "IdProprietario não encontrado verifique a configuração no Assinante PdvSync")
        endif
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Confirma
Metodo que efetua a confirmação do recebimento

@author  Danilo Rodrigues
@version 1.0
/*/
//-------------------------------------------------------------------
Method Confirma() Class RmiBusPdvSyncObj
    
    Local cUrl      := ""
    Local cJson     := ""

    If Len(self:aConfirma) == 0

        LjGrvLog(GetClassName(self), "Não há dados para confirmar.", self:cProcesso)
    Else

        self:oConfirma := JsonObject():New()
        self:oConfirma:Set(self:aConfirma)
        cJson          := EnCodeUtf8( self:oConfirma:toJson() )

        If Rat("/",self:oConfProce["url"])
            cUrl := Alltrim(Substr(self:oConfProce["url"], 1, Len(self:oConfProce["url"]) - 1 ))
        Else
            cUrl := Alltrim(self:oConfProce["url"])
        EndIf

        if self:oEnvia == Nil
            self:oEnvia := FWRest():New("")
        EndIf

        self:oEnvia:SetPath(cUrl)
        LjGrvLog("Confirma", "PUT - Method Confirma classe RmiBusPdvSyncObj Json enviado - "+cJson)
        If self:oEnvia:Put( self:aHeader, cJson )
            self:cRetorno := self:oEnvia:GetResult()
            self:lSucesso := .T.
        Else

            self:lSucesso := .F.
            self:cRetorno := self:oEnvia:GetLastError() + " - " + self:oEnvia:CRESULT + "." 
        EndIf        

        FwFreeObj(self:oConfirma)
        FwFreeArray(self:aConfirma)
        self:aConfirma := {}
    EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Metodo para carregar a publicação de cadastro

@author  Everson S P Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno() Class RmiBusPdvSyncObj

    Local nPos := 0    
  
    If !self:oRetorno["success"]

        self:lSucesso := .F.
        self:cRetorno := AllTrim(self:cProcesso) + " - " + self:oRetorno["message"]
        LjGrvLog("RmiBusPdvSyncObj", self:cRetorno, self:lSucesso)
    Else
       
        If Len(self:oRetorno["data"]) == 0

            self:lSucesso := .F.
            self:cRetorno := I18n("Não há dados a serem baixadas:", { ProcName(), self:cRetorno} )   
            LjGrvLog("RmiBusPdvSyncObj", self:cRetorno)

        Else

            For nPos:=1 To Len(self:oRetorno["data"])

                self:oRegistro   := self:oRetorno["data"][nPos]
                self:cMsgOrigem  := Decode64(self:oRegistro["conteudo"])
                self:cMsgOrigem  := DecodeUtf8(self:cMsgOrigem)

                self:oConteudo:FromJson(self:cMsgOrigem)
                
                self:setEvento(self:oConteudo)

                self:dDtDado := dDataBase
                If self:oConteudo:hasProperty("DataCadastro")
                    self:dDtDado := sToD( self:AuxTrataTag("MIP_DATGER", self:oConteudo["DataCadastro"]) )
                endIf

                self:nValor := 0
                If self:oConteudo:hasProperty("ValorLiquido")
                    self:nValor := self:oConteudo["ValorLiquido"]
                endIf

                //Atualiza cChaveUnica a partir do oConfProce["ChaveUni"]
                self:setChaveUnica(IIf(Len(self:oConteudo) > 0,self:oRegistro,self:oConteudo))

                //Define se ignora o registro
                If self:IgnoraPub()
                    LjGrvLog( "RmiBusPdvSyncObj", "Publicação ignorada, condição atendida no método IgnoraPub.", {self:cAssinante, self:cProcesso, self:oRegistro["tipoMovimento"]} )
                    Loop
                EndIf

                If self:AuxExistePub()

                    //Carrega recebimento para confirmação
                    self:AddConfirma(self:oRetorno["data"][nPos]["id"], 5, "Publicação já existe, será ignorada.")  //5 - Venda enviada mais de uma vez, já integrado com sucesso.

                    LjGrvLog( "RmiBusPdvSyncObj", "Publicação já existe, será ignorada.", {self:cAssinante, self:cProcesso, self:cChaveUnica} )
                    Loop
                EndIf
                //Grava o Id da Venda para Envio de Status.
                self:cConfirma := cValtoChar(self:oRetorno["data"][nPos]["id"])
                
                self:Grava()
                //Carrega recebimento para confirmação
                self:AddConfirma(self:cConfirma, IIF(self:lSucesso, 1, 2), self:cRetorno)

                FwFreeObj(self:oRegistro)
                self:oRegistro  := Nil

            Next nPos
            
        EndIf        
    EndIf

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LayEstAuto
Metodo que Envia os dados especificos do layout de publicação para 
o metodo generico LayEstAuto, onde cadastrará a estação AUTOMATICO caso seja necessário.

@author  Danilo Rodrigues
@since 	 03/12/2021
@version 1.0		
/*/
//-------------------------------------------------------------------------------------
Method LayEstAuto(cCmpRet) Class RmiBusPdvSyncObj
        
    Local cRetorno  := ""
    Local cNumPdv   := ""

    Default cCmpRet := ""

    /*
    ModeloFiscal
    1 - SAT
    2 - NFC-e
    3 - MFE
    4 - PAF
    5 - NF-e
    */
    self:cModelo    := allTrim( cValtoChar(self:oRegistro['ModeloFiscal']) )
    self:cModelo    := IIF( self:cModelo $ "2|5", "2", self:cModelo)

    self:cCodLoja   := IIF( self:oRegistro['Loja'] == NIL        , "", self:oRegistro['Loja']['IdRetaguarda']        )
    self:cEstacao   := IIF( self:oRegistro['Periferico'] == NIL  , "", self:oRegistro['Periferico']['NumeroSerie']   )
    self:cSerie     := IIF( self:cModelo == "1"                  , "", cValtoChar(self:oRegistro['SerieNota'])       )  //Se for SAT deixa vazia a serie para não tentar gerar estação com serie 0
    cNumPdv         := IIF( self:oRegistro['NumeroPdv'] == NIL   , "", self:oRegistro['NumeroPdv']                   )

    cRetorno := _Super:LayEstAuto(cCmpRet, cNumPdv)

Return cRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} AuxTrataTag
Metodo para efetuar o tratamento das Tags que serão gravadas na publicação

@type    method
@param   cTag, Caractere, Nome da tag que ira retornar
@param   xConteudo, Indefinido, Conteudo da tag
@param   nItem, Numerico, Numero do item quando tag esta em um lista
@return  Indefinido, Conteudo da tag tratado

@author  Rafael Tenorio da Costa
@since   03/12/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method AuxTrataTag(cTag, xConteudo, nItem) Class RmiBusPdvSyncObj

    Local xTag := _Super:AuxTrataTag(cTag, xConteudo, nItem)

    If ValType(self:oXmlSefaz) == "O" .And. !self:oXmlSefaz:getStatus()
        self:lSucesso := .F.
        self:cRetorno := self:oXmlSefaz:getErro()
    EndIf

Return xTag



//-------------------------------------------------------------------
/*/{Protheus.doc} IgnoraPub
Metodo que define se ignora uma publicação

@type    method
@return  Lógico, Define se o registro deve ser ignorado na publicação
@author  Rafael Tenorio da Costa
@since   12/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method IgnoraPub() Class RmiBusPdvSyncObj

    Local lIgnora   := .F.
    Local cProcesso := AllTrim(self:cProcesso)

    Do Case

        Case cProcesso == "SANGRIA"

            //Se não for FechamentoCaixa = 1, Sangria = 2,
            If !( self:oRegistro["tipoMovimento"] $ "1|2" )
                lIgnora := .T.
            EndIf

        Case cProcesso == "SUPRIMENTO"

            //Se não for AberturaCaixa = 0, Suprimento = 3
            If !( self:oRegistro["tipoMovimento"] $ "0|3" )
                lIgnora := .T.
            EndIf
    End Case
    
Return lIgnora

//-------------------------------------------------------------------
/*/{Protheus.doc} setEvento
Metodo que define o Evento a ser utilizado na MHQ

@type    method
@return  Nil
@author  Everson S P Junior
@since   12/05/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Method setEvento(oConteudo) Class RmiBusPdvSyncObj

    self:cEvento := "1"

    If Alltrim(self:cProcesso) == "VENDA"
        self:cEvento := Iif(oConteudo["SituacaoVenda"] == 0,'1',self:cEvento) //Venda
        self:cEvento := Iif(oConteudo["SituacaoVenda"] == 1,'2',self:cEvento) //Venda canc
        self:cEvento := Iif(oConteudo["SituacaoVenda"] == 3,'3',self:cEvento) //Venda Inut
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddConfirma
Incrementa retornos de confirmação

@type    method
@param   cIdMensagem, Caractere, Código da mensagem que será confirmada
@param   nStatus, Numerico, Tipo de status de confirmação
@param   cObservacao, Caractere, Mensagem de retorno
@author  Rafael Tenorio da Costa
@since   06/07/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Method AddConfirma(cIdMensagem, nStatus, cObservacao) Class RmiBusPdvSyncObj

    Local nConfirma := Len(self:aConfirma) + 1

    aAdd( self:aConfirma, JsonObject():New() )

    self:aConfirma[nConfirma]["idMensagem"] := cValToChar(cIdMensagem)
    self:aConfirma[nConfirma]["status"]     := nStatus          //0=Processar, 1=Processada, 2=Erro, 3=Reprocessar, 4=IntegradoComSucesso (utilizado no final do processo, quando o registro foi incluído no protheus)
    self:aConfirma[nConfirma]["observacao"] := cObservacao

    if alltrim(self:cProcesso) == "CONSOLIDADO"
        self:aConfirma[nConfirma]["numeroRegistrosConfirmados"] := 0
    endIf
    
Return Nil
//--------------------------------------------------------
/*/{Protheus.doc} GetRetRes
Retorna a reserva

@type    Method
@return  Caractere, Código da reserva
@author  Everson S P Junior
@version 1.0
@since   24/01/23   
/*/
//--------------------------------------------------------
Method GetReserva(nItem) Class RmiBusPdvSyncObj
Local cReserva := ""
Local cProduto := self:oXmlSefaz:getDet({'prod', 'cProd'}, self:oRegistro['VendaItems'][nItem]['Sequencia'],'')
Local cFilint  := self:oRegistro['Loja']['IdRetaguarda']
Local cDocRes  := Alltrim(STR(IIF(self:oRegistro['preVendaId']==NIL,0,self:oRegistro['preVendaId'])))
Local nQuant   := self:oXmlSefaz:getDet({'prod', 'qCom'}, self:oRegistro['VendaItems'][nItem]['Sequencia'],'')
Local cQuery    := "" 
Local cAlias    := GetNextAlias()


cQuery := "SELECT C0_NUM "
cQuery += "  FROM " + RetSqlName("SC0")
cQuery += " WHERE C0_FILIAL = '" + PADR(cFilint,TAMSX3("C0_FILIAL")[1]) + "'"
cQuery += " AND C0_DOCRES = '" + PADR(cDocRes,TAMSX3("C0_DOCRES")[1]) + "'"
cQuery += " AND C0_PRODUTO = '" + PADR(cProduto,TAMSX3("C0_PRODUTO")[1]) + "'"
cQuery += " AND C0_QUANT = " + Alltrim(STR(nQuant)) +""
cQuery += " AND D_E_L_E_T_ <> '*'"

If !Empty(Self:cNumRes)
    cQuery += " AND C0_NUM NOT IN (" + Self:cNumRes + ")"
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If Empty(Self:cNumRes)
    Self:cNumRes := (cAlias)->C0_NUM
Else
    Self:cNumRes += ","+(cAlias)->C0_NUM
EndIf

If !(cAlias)->(Eof())
    cReserva := (cAlias)->C0_NUM
    LjGrvLog("GetReserva", "Documento da Reserva enviado na venda: "+cDocRes)
    LjGrvLog("GetReserva", "Numero da Reserva no Protheus: "+cReserva)
Else
    self:lSucesso := .F.
    Self:cRetorno := "A Venda com reserva, não foi encontrado reserva para o documento enviado numero: "+cDocRes    
EndIf    

(cAlias)->( DbCloseArea() )

Return cReserva

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Grava a publicação recebida


@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava() Class RmiBusPdvSyncObj

    Local cFilMip := IIF( alltrim(self:cProcesso) $ "VENDA|CLIENTE", self:oConteudo["Loja"]["IdRetaguarda"], cFilAnt )

    _Super:Grava()

    If self:lSucesso .And. self:lDetDistrib

        RmiStDist(  "1"                 ,;  //cStatus
                    1                   ,;  //nIndex
                    cFilMip             ,;  //cFil
                    self:cChaveUnica    ,;  //cChvUni
                    MHQ->MHQ_UUID       ,;  //cUUID
                    self:dDtDado        ,;  //dDtOrig
                                        ,;  //cDtOk
                    self:cProcesso      ,;  //cProcesso
                    self:cEvento        ,;  //cEvento
                    self:nValor         )   //nValor
    EndIf
    
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} setStatusSync
Metodo para enviar os Status das Buscas processadas para pdvsync.
@type    method
@return  Nil
@author  Everson S P Junior
@since   11/03/2024
/*/
//-------------------------------------------------------------------
Method setStatusSync() Class RmiBusPdvSyncObj
Local cQuery    := "" 
Local cAlias    := GetNextAlias()
Local cMhlErro  := ""
Local lContinua := .T.

cQuery := " SELECT MIP.R_E_C_N_O_ AS RECNO, MIP_STATUS,MIP_UIDORI,MHQ_IDEXT "
cQuery += " FROM " + RetSqlName("MIP") +" MIP "
cQuery +=   " INNER JOIN " + RetSqlName("MHQ") + " MHQ "
cQuery +=       " ON MHQ.D_E_L_E_T_ = ' '"
cQuery +=           " AND MHQ.MHQ_ORIGEM = '" + padR( "PDVSYNC", tamSx3("MHQ_ORIGEM")[1] ) + "'"
cQuery +=           " AND MHQ.MHQ_IDEXT != '"+SPACE(TAMSX3("MHQ_IDEXT")[1])+"'"
cQuery +=           " AND MHQ.MHQ_UUID = MIP.MIP_UIDORI"
cQuery += " WHERE "
cQuery +=   " MIP.MIP_CPROCE = '" + PADR(self:cProcesso,TAMSX3("MIP_CPROCE")[1]) + "'"
cQuery +=   " AND MIP.MIP_STATUS IN ('2', '3', 'A')"
cQuery +=   " AND MIP.MIP_DTCONF = '" + SPACE(TAMSX3("MIP_DTCONF")[1]) + "'"
cQuery +=   " AND MIP.D_E_L_E_T_ = ' '"
If Len(self:aRecno) > 0 
    cQuery += "  AND MIP.R_E_C_N_O_ > "+Alltrim(STR(self:aRecno[Len(self:aRecno)]))
EndIf    
cQuery += "  ORDER BY MIP.R_E_C_N_O_ "

DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

If (cAlias)->(Eof())
    If Len(self:aConfirma) > 0
        self:confirma()
        LjGrvLog("setStatusSync", "Retorno Method confirma "+self:cRetorno)
        If self:lSucesso
            self:setDtEnvio()//Atualiza os itens confirmados da MIP.
            LjGrvLog("setStatusSync", "Sucesso no envio dos status "+self:cRetorno)
        EndIf    
    EndIf    
    lContinua := .F.
EndIf

dbSelectArea("MHL")
MHL->(DbSetOrder(3))
DbSelectArea("MIP")
While !(cAlias)->(Eof())
    cMhlErro := Posicione("MHL",3,xFilial("MHL")+PadR((cAlias)->MIP_UIDORI,TAMSX3("MHL_UIDORI")[1]), "MHL_ERROR")
    self:AddConfirma(Alltrim((cAlias)->MHQ_IDEXT), IIF((cAlias)->MIP_STATUS $ "2|A",4, 2),Alltrim(cMhlErro)) // Status Sync 2-erro pela retaguarda, 4-com sucesso retaguarda 
    aAdd(self:aRecno,(cAlias)->RECNO)
    (cAlias)->(DbSkip())
EndDo    

(cAlias)->( DbCloseArea() )

If lContinua //chamada recursiva para ir buscando MIP enquanto existir itens a confirmar.
    self:setStatusSync()
EndIf    

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} setDtEnvio
Metodo para atualizar a MIP DTENVI com data hora.
@type    method
@return  Nil
@author  Everson S P Junior
@since   11/03/2024
/*/
//-------------------------------------------------------------------
Method setDtEnvio() Class RmiBusPdvSyncObj
Local nX := 0

Begin Transaction
    For nX:=1 to len(self:aRecno)
        MIP->( DbGoTo( self:aRecno[nX] ))   
        RecLock("MIP", .F.)
            MIP->MIP_DTCONF := FwTimeStamp(2)
        MIP->( MsUnLock() )
    next
End Transaction

FwFreeArray(self:aRecno)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetArrayFil
Carrega a propriedade aArrayFil com o conteudo do campo MHP_FILPRO

@author  Everson S. P. Junior
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetArrayFil() Class RmiBusPdvSyncObj

    Local aArrayCamp := {}
    Local nX         := 0

    aSize(self:aArrayFil, 0)

    aArrayCamp := iif( lStRmixFil, rmixFilial(self:cAssinante, self:cProcesso, self:cTipo), strTokArr( alltrim(MHP->MHP_FILPRO), ";") )

    For nX:=1 To Len(aArrayCamp)
        //Carrega o self:aArrayFil com a mesma informação para manter a estrutura
        aAdd( self:aArrayFil, {aArrayCamp[nX], aArrayCamp[nX]} )
    Next nX

    if len(self:aArrayFil) == 0

        self:lSucesso := .F.
        self:cRetorno := I18n("Campo obrigatório de filiais (#1), não preenchido no cadastro de assinantes.", {"MHP_FILPRO ou MHP_LAYFIL"})  //"Campo obrigatório de filiais (#1), não preenchido no cadastro de assinantes."
    EndIf

    fwFreeArray(aArrayCamp)

    LjGrvLog("RmiBusPdvSyncObj", "Carregando filiais:", {self:cRetorno, self:aArrayFil} )

Return Nil
