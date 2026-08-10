#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIENVPDVSYNCOBJ.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe RmiEnvLiveObj
Classe responsável pelo envio de dados ao Live

/*/
//-------------------------------------------------------------------
Class RmiEnvPdvSyncObj From RmiEnviaObj

    Data aProcessos             as Array        //Array com todos os processos de envio ativos para abertura de lote
    Data aMhrRec                as Array
    Data nMaxPorLote            as Numeric
    Data nQtdList               as Numeric
    Data cBodylist              as Character    //Corpo da mensagem que será enviada para o sistema de destino
    Data oPdvSync               as Object       //Objeto PdvSync
    Data lDetDistrib            as Logical      //Define se esta ativo a gração da tabela MIP - Detalhe da Distribuição
    Data aLojasProprietario     as Array        //Lojas atreladas a um determinado proprietario
    Data aTiposDados            as Array        //Lista de tipos de dados retornados pela API LojaLotes

    Method New()                                //Metodo construtor da Classe

    Method AbreLote()                           //Método para gerar o Json de abertura do Lote
    Method FechaLote()                          //Método para gerar o Json de fechamento do Lote
    Method EnviaAbreLote(cJson)                 //Método que faz a comunicação com o PdvSync para abertura do Lote
    Method EnviaFechaLote()                     //Método que faz a comunicação com o PdvSync para fechamento do Lote
    Method TrataRetorno(cJson, nTipo)           //Trata o retorno ao abrir ou fechar um lote
    Method GrvAbertura(cProcesso, cLote, cId)   //Metodo responsavel em gravar a abertura do lote na tabela MIK
    Method GrvFechamento()                      //Metodo responsavel em gravar fechamento do lote na tabela MIK

    Method ProcessoPend(cLote)          //Verifica se há algum processo que ainda não terminou o envio antes de fechar o lote
    Method GetProcessos()               //Carrega processos para abertura de lote
    Method GetLote()                    //Esse metodo verifica se para um determinado processo já tem lote em aberto para seguir com o envio dos dados para o PDVSync

    Method PreExecucao()                //Metodo para gerar o token no PDV Sync
    Method PosExecucao()                //Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.
    Method Envia()                      //Metodo responsavel por enviar a mensagens ao PDVSync

    Method Grava()                      //Metodo que ira atualizar a situação da distribuição e gravar o de/para
    Method Consulta()                   //Consulta as publicações disponiveis para o envio para um determinado processo com base nos LOTE's abertos
    Method Processa()                   //Metodo que ira controlar o processamento dos envios em lista

    Method getLojasProprietario()       //Metodo que carrega as lojas atreladas a um determinado proprietario

    Method EnviaIP()                      //Envia para a engenharia a informação de IP externo para atualização de IP do servidor (referente ao fluxo online)    

    Method StatusDet()                  //Método que irá tratar os status dos envios detalhados por loja/lote (MIP)
    Method GetStatus(cLote,cLoja)       //Método que faz a comunicação com o PdvSync para consulta do status do lote enviado
    Method UpdStatus(cLote,cLoja,cStatus)       //Método que atualiza o status dos envios detalhados por Loja/Lote (MIP)
    Method GravaErrosStatus()           //Método que grava os erros encontrados pelo retorno da API LojaLoteRetornos nas devidas tabelas (MHL,MIP,MHR)
    Method GetTiposDados(nTipoDado,cProcesso)     //Método que busca o nome do processo do envio no protheus conforme o tipo de dado retornado do PDVSYNC
    Method StatusLista()                //Atualiza o Status MHR por item da Lista.
    Method ExecLojaLote()             //Valida se pode executar a consulta dos status dos envios detalhados por loja/lote (MIP)

    Method precedencia()                //Metodo para tratamento de precedencia

    Method getHeader()                  //Metodo para carregar o header enviado em cada requisição (token)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da Classe

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cProcesso) Class RmiEnvPdvSyncObj
    
    Local cTenent       := ""
    Local cUser         := ""
    Local cPassword     := ""
    Local cClientId     := ""
    Local cClientSecret := ""
    Local nEnvironment  := 0

    _Super:New("PDVSYNC", cProcesso)

    If self:lSucesso

        self:aProcessos         := {}

        self:nMaxPorLote        := IIF( self:oConfAssin:hasProperty("qtdMaxPorLote"), self:oConfAssin["qtdMaxPorLote"], 500 )

        self:aLojasProprietario := {}

        self:aTiposDados        := {}

        If self:oConfAssin:hasProperty("autenticacao")  
            cTenent       := IIF( self:oConfAssin["autenticacao"]:hasProperty("tenent")         , self:oConfAssin["autenticacao"]["tenent"]         , "")
            cUser         := IIF( self:oConfAssin["autenticacao"]:hasProperty("user")           , self:oConfAssin["autenticacao"]["user"]           , "")
            cPassword     := IIF( self:oConfAssin["autenticacao"]:hasProperty("password")       , self:oConfAssin["autenticacao"]["password"]       , "")
            cClientId     := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientId")       , self:oConfAssin["autenticacao"]["clientId"]       , "")
            cClientSecret := IIF( self:oConfAssin["autenticacao"]:hasProperty("clientSecret")   , self:oConfAssin["autenticacao"]["clientSecret"]   , "")
            nEnvironment  := IIF( self:oConfAssin["autenticacao"]:hasProperty("environment")    , self:oConfAssin["autenticacao"]["environment"]    , 1 )
        EndIf

        If FindClass("totvs.protheus.retail.rmi.classes.pdvsync.PdvSync") //Incluido dependencia automatica
            self:oPdvSync := totvs.protheus.retail.rmi.classes.pdvsync.PdvSync():New(cTenent, cUser, cPassword, cClientId, cClientSecret, nEnvironment)       
        EndIf

        Aadd( self:aTiposDados ,{0   , 'CLIENTE' })
        Aadd( self:aTiposDados ,{1   , 'CADASTRO LOJA' })
        Aadd( self:aTiposDados ,{3   , 'PERFIL OPERADOR' })
        Aadd( self:aTiposDados ,{4   , 'OPERADOR LOJA' })
        Aadd( self:aTiposDados ,{6   , 'COMPARTILHAMENT' })
        Aadd( self:aTiposDados ,{7   , 'ICMS' })
        Aadd( self:aTiposDados ,{8   , 'NCM' })
        Aadd( self:aTiposDados ,{9   , 'PIS/COFINS' })
        Aadd( self:aTiposDados ,{11  , 'CATEGORIA' })
        Aadd( self:aTiposDados ,{12  , 'PRODUTO' })
        Aadd( self:aTiposDados ,{12  , 'PRODUTO SLK' })
        Aadd( self:aTiposDados ,{13  , 'PRECO' })
        Aadd( self:aTiposDados ,{14  , 'SALDO ESTOQUE' })
        Aadd( self:aTiposDados ,{15  , 'ADMINISTRADORA'	})
        Aadd( self:aTiposDados ,{16  , 'COMPL PAGAMENTO' })
        Aadd( self:aTiposDados ,{17  , 'CONDICAO PAGTO'	})
        Aadd( self:aTiposDados ,{18  , 'FORMA PAGAMENTO' })   

        self:EnviaIP()

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AbreLote
Método para gerar o Json que fara a abertura do lote

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method AbreLote() Class RmiEnvPdvSyncObj

    Local cJson     := ""   //Guarda o Json para geração do lote
    Local nI        := 0    //Variavel de loop
    Local oError    := Nil  //Variavel para captura de erro
    Local cTipos    := ""   //Tipo de lotes a serem abertos

    TRY EXCEPTION
        If !LockByName("GERALOTE")
            Sleep(9000)
            If Self:GetLote(Self:cProcesso)
                Self:lSucesso := .T.
                Self:cRetorno := ""
               LjGrvLog(" RmiEnvPdvSyncObj ","Existe um lote em aberto para o processo " + Self:cProcesso + "iniciando o envio dos dados para o PDVSYNC. Lote: ")  //"Serviço #1 já esta sendo utilizado por outra instância."
            Else
                // -- Voltam os essa alteração, o registro esta ficando com 6 onde deveria ser pulado
                Self:lSucesso := .F.
                Self:cRetorno := STR0001 + Self:cProcesso + STR0002 //"Não existe um lote em aberto para o processo " # ", os dados desse processo não serão enviados até que o lote em aberto seja fechado."
                LjGrvLog(" RmiEnvPdvSyncObj ", Self:cRetorno)
            EndIf
            Return Nil
        EndIf

        If !Self:GetLote() // --Neste ponto não quero q tenha nenhum lote em aberto
            
            //Carrega processos para abertura de lote
            self:getProcessos()

            If Len(Self:aProcessos) > 0

                cJson := '{"status": "InicioEnvio",'
                
                For nI := 1 To Len(Self:aProcessos)
                    cTipos += Self:aProcessos[nI][2] + ","
                Next

                cTipos := '"tipoLote": [' + SubStr(cTipos,1,Len(cTipos) - 1) + '],'

                cJson += cTipos
                cJson += '"idInquilino": "' + Self:oConfAssin["inquilino"] + '"'
                cJson += '}'

                Self:EnviaAbreLote(cJson, 0)
            EndIf

        EndIf

        UnLockByName("GERALOTE")

    CATCH EXCEPTION USING oError

        UnLockByName("GERALOTE")
        Self:lSucesso := .F.
        Self:cRetorno := "Ocorreu erro ao gerar lote ->  " + AllTrim(oError:ErrorStack)
        LjGrvLog(" RmiEnvPdvSyncObj ", Self:cRetorno)

    ENDTRY

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Processos
Carrega processos para abertura de lote

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetProcessos() Class RmiEnvPdvSyncObj

    Local aArea     := GetArea()
    Local cQuery    := ""                   //Guarda a query a ser executada
    Local cTabela   := ""                   //Pega o próximo alias para consulta da MHP
    Local oAux      := JsonObject():New()   //Objeto Json da MHP_CONFIG
    Local oLayEnv   := JsonObject():New()   //Objeto Json da MHP_LAYENV
    Local lContinua := .F.

    fwFreeArray(self:aProcessos)
    self:aProcessos := {}

    //Retorna os processos de envio ativos para abertura de lote
    cQuery := " SELECT MHP_CPROCE, R_E_C_N_O_ "
    cQuery += " FROM " + RetSqlName("MHP")
    cQuery += " WHERE MHP_CASSIN = '" + self:cAssinante + "'"
    cQuery +=       " AND MHP_FILIAL = '" + xFilial("MHP") + "'"
    cQuery +=       " AND MHP_TIPO = '1'"     //1=Envio
    cQuery +=       " AND MHP_ATIVO = '1'"    //1=Sim
    cQuery +=       " AND D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY MHP_CPROCE"

    cTabela := GetNextAlias()
    cQuery  := ChangeQuery(cQuery)
    
    ljGrvLog("RmiEnvObj", "Query que retorna os processos de envio ativos para abertura de lote.", cQuery)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

    while !(cTabela)->( Eof() )
        MHP->( DbGoTo( (cTabela)->R_E_C_N_O_) )
        
        //Verifica se o json de configuração esta valido.
        lContinua := oAux:fromJson( allTrim(MHP->MHP_CONFIG) ) == nil

        //Verifica se o json de envio esta valido e se a carga inicial esta ativa para o processo
        //Assim em um primeiro momento não abre lote com ele
        if lContinua
            if  oLayEnv:fromJson( allTrim(MHP->MHP_LAYENV) ) == nil .and. oLayEnv:hasProperty("configPSH") .and.;
                oLayEnv["configPSH"]:hasProperty("cargaInicial") .and. oLayEnv["configPSH"]["cargaInicial"]
                lContinua := .F.
            endIf
        endIf

        if lContinua
            aAdd(self:aProcessos, { (cTabela)->MHP_CPROCE, oAux["codigotipo"], oAux["descricaotipo"] } )
        endIf

        (cTabela)->( dbSkip() )
    endDo
    
    (cTabela)->( DbCloseArea() )

    fwFreeObj(oAux)
    fwFreeObj(oLayEnv)

    restArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaAbreLote
Faz a solicitação ao PDVSync para abrir lote.

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method EnviaAbreLote(cJson) Class RmiEnvPdvSyncObj

    Local oRest := Nil //Objeto que faz a comunicação via Rest com PDVSync para abrir ou fechar um lote
    Local jRet  := jsonObject():new()

    oRest := FWRest():New("")
    oRest:nTimeOut := self:nTimeOut

    //Seta a url do lote
    oRest:SetPath( Self:oConfAssin["url_lote"] )

    //Seta o corpo do Post
    oRest:SetPostParams( cJson )

    LjGrvLog(" RmiEnvPdvSyncObj ", "Method EnviaAbreLote(): JSON de de envio da abertura de lote : ",{cJson})

    //Carrega o aHeader
    self:getHeader()
    
    //Busca o lote
    If oRest:Post( self:aHeader )
        Self:TrataRetorno(oRest:GetResult(), 0)
    Else
        Self:lSucesso := .F.
        If jRet:fromJson( oRest:cResult ) == nil .And. Valtype(jRet['errors']) == "J"
            If jRet['errors']:hasProperty("lote") .And. !Empty(jRet['errors']['lote'])
                
                Self:cRetorno := I18n(STR0017,{jRet['errors']['lote']}) //"Lote #1 foi aberto no PDV Omni/Sync e não possui referência na tabela MIK do Protheus. O lote será fechado para seguir o fluxo de integração na próxima execução do Job. "
                
                Self:cLote := jRet['errors']['lote']
                Self:EnviaFechaLote()
                Self:cLote := ""
            EndIf  
        Else
            Self:cRetorno := STR0004 + oRest:GetLastError() + " - " + IIF( ValType(oRest:cResult) == "C", oRest:cResult, "Detalhe do erro não retornado." ) //"Não foi possivel realizar a abertura do lote.  - "
        EndIf
    EndIf

    fwFreeObj(jRet)
    
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaFechaLote
Faz a solicitação ao PDVSync para fechar lote

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method EnviaFechaLote() Class RmiEnvPdvSyncObj

    Local oRest := Nil                                  //Objeto que faz a comunicação via Rest com PDVSync para abrir ou fechar um lote
    Local cPath := AllTrim(Self:oConfAssin["url_lote"]) //EndPoint para realizar o fechamento
    Local cErro := ""
    Local aSql  := {}
    Local nCont := 0
    Local oJson := jsonObject():new()
    Local cJson := ""

    //Carrega os processos enviados no lote
    aSql := RmiXSql("SELECT MHR_CPROCE FROM " + retSqlName("MHR") + " WHERE D_E_L_E_T_ = ' ' AND MHR_LOTE = '" + self:cLote + "' GROUP BY MHR_CPROCE", "*", /*lCommit*/, /*aReplace*/)

    //Carrega tipos do lotes para enviar ao fechamento do lote
    oJson["tipolote"] := {}
    for nCont:=1 to len(aSql)
        aAdd( oJson["tipolote"], self:getTiposDados(/*nTipoDado*/, aSql[nCont][1]) )
    next nCont
    cJson := oJson:toJson()

    oRest := FWRest():New("")
    oRest:nTimeOut := self:nTimeOut

    If SubStr(cPath,Len(cPath),1) == "/"
        cPath := SubStr(cPath, 1, Len(cPath) - 1)
    EndIf

    //Seta a url do lote
    cPath := cPath + "/" + AllTrim(Self:oConfAssin["inquilino"]) + "/" + AllTrim(Self:cLote)
    oRest:SetPath(cPath)

    //Carrega o aHeader
    self:getHeader()

    ljGrvLog("RmiEnvPdvSyncObj", "Envia fechamento do lote:", {cPath, cJson, self:aHeader})

    //Fecha o lote
    If oRest:Put(self:aHeader, cJson)
        Self:TrataRetorno(oRest:GetResult(), 1)
    Else

        cErro := allTrim( oRest:GetLastError() ) + " - " + iif( valType(oRest:cResult) == "C", allTrim(oRest:cResult), "Detalhe do erro não retornado." )

        ljxjMsgErr( i18n("Erro ao efetuar o fechamento do lote #1: #2", {self:cLote, cErro}), /*cSolucao*/, "RmiEnvPdvSyncObj", self:oConfAssin)
    EndIf
    
    fwFreeArray(aSql)
    fwFreeObj(oJson)
    fwFreeObj(oRest)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRetorno
Trata o retorno do lote, abertura ou fechamento

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method TrataRetorno(cJson, nTipo) Class RmiEnvPdvSyncObj

    Local oRet  := JsonObject():New()
    Local nI    := 0 //Variavel de loop
    Local nCod  := 0 //Código do processo
    Local aProcGrv := {} //Array que controla os processos já gravados
    oRet:FromJson( DeCodeUTF8(cJson) )

    LjGrvLog(" RmiEnvPdvSyncObj ", "Method TrataRetorno(): "+IIf(nTipo == 0,"Abertura","Fechamento")+" de lote executado. JSON de Retorno da API PdvSync : ",{cJson})

    //0 Abertura
    If nTipo == 0             
            Begin Transaction            
	            For nI := 1 To Len(oRet["data"]["tipoLote"])
	                nCod := aScan(Self:aProcessos, {|x| x[2] == cValToChar(oRet["data"]["tipoLote"][nI])})
	                
	                If aScan(aProcGrv, nCod) > 0
	                    nCod := aScan(Self:aProcessos, {|x| x[2] == cValToChar(oRet["data"]["tipoLote"][nI])}, nCod+1)
	                EndIf
	
	                If nCod > 0                    
	                    Self:GrvAbertura(Self:aProcessos[nCod][1],oRet["data"]["loteOrigem"],oRet["data"]["id"])
	                    AAdd(aProcGrv,nCod)
	                EndIf
	            Next nI
            End Transaction
    //1 Fechamento            
    Else
        Self:GrvFechamento()
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvAbertura
Faz a gravação dos lotes gerados na tabela MIK

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GrvAbertura(cProcesso, cLote, cId) Class RmiEnvPdvSyncObj

    Self:cLote := cLote

    RecLock("MIK",.T.)
    MIK->MIK_FILIAL := xFilial("MIK")
    MIK->MIK_LOTE := cLote
    MIK->MIK_CPROCE := cProcesso
    MIK->MIK_DTABE := Date()
    MIK->MIK_HRABE := Time()
    MIK->MIK_IDLOTE := cId
    MIK->( MsUnLock() )
  
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvFechamento
Faz a atualização do fechamento do lote

@author  Bruno Almeida
@Date    24/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GrvFechamento() Class RmiEnvPdvSyncObj

    Local cQuery := "" //Query a ser executada
    Local cAlias := GetNextAlias() //Proximo alias disponivel
    Local cSemaforo := "FECHALOTE" //Semáforo para controle de concorrência

    If LockByName(cSemaforo)
        
        cQuery := "SELECT R_E_C_N_O_ "
        cQuery += "  FROM " + RetSqlName("MIK")
        cQuery += " WHERE MIK_FILIAL = '" + xFilial("MIK") + "'"
        cQuery += "   AND MIK_LOTE = '" + Self:cLote + "'"
        cQuery += "   AND MIK_DTFECH = ' '"
        cQuery += "   AND MIK_HRFECH = ' '"
        cQuery += "   AND D_E_L_E_T_ = ' '"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)
        
        LjGrvLog(" RmiEnvPdvSyncObj ", "Gravando fechamento do lote: " + Self:cLote + " - Query: " + cQuery)

        If !(cAlias)->( Eof() )
            Begin Transaction
            While !(cAlias)->( Eof() )
                MIK->(DbGoTo((cAlias)->R_E_C_N_O_))
                RecLock("MIK",.F.)
                MIK->MIK_DTFECH := Date()
                MIK->MIK_HRFECH := Time()  
                MIK->( MsUnLock() )
                (cAlias)->( DbSkip() )
            EndDo
            End Transaction
        Else
            LjGrvLog(" RmiEnvPdvSyncObj ", "Lote (" + Self:cLote + ") não encontrado na tabela para atualizar os campos de Data e Hora de fechamento")
        EndIf
        
        (cAlias)->( DbCloseArea() )
        UnLockByName(cSemaforo)

    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLote
Esse metodo verifica se para um determinado processo já tem lote em
aberto para seguir com o envio dos dados para o PDVSync

@author  Bruno Almeida
@Date    17/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetLote(cProcesso) Class RmiEnvPdvSyncObj

    Local cQuery    := "" //Armazena a query
    Local cAlias1   := GetNextAlias() //Proximo alias disponivel
    Local lExiste   := .F. //Se existe ou nao um lote já aberto
       
    cQuery := " SELECT MIK_LOTE "
    cQuery += " FROM " + RetSqlName("MIK")
    cQuery += " WHERE MIK_DTFECH = ' ' "
    
    If !Empty(cProcesso)
        cQuery += " AND MIK_CPROCE = '" + cProcesso + "'"
    EndIF 

    cQuery += " AND MIK_FILIAL = '" + xFilial("MIK") + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias1, .T., .F.)

    If !(cAlias1)->( Eof() )
        lExiste     := .T.    
        Self:cLote  := AllTrim((cAlias1)->MIK_LOTE)
    Else
	    lExiste     := .F.
        Self:cLote  := ""
    EndIf

    (cAlias1)->( DbCloseArea() )

Return lExiste

//-------------------------------------------------------------------
/*/{Protheus.doc} PreExecucao
Metodo para gerar o token no PDV Sync

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method PreExecucao() Class RmiEnvPdvSyncObj

    If self:lSucesso
        self:AbreLote()    
    EndIf
    
    If !self:lSucesso
        LjxjMsgErr(self:cRetorno, /*cSolucao*/, /*cRotina*/)    
    EndIf

Return self:lSucesso


//-------------------------------------------------------------------
/*/{Protheus.doc} Envia
Metodo responsavel por enviar a mensagens ao PDVSync

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Envia() Class RmiEnvPdvSyncObj

    //Inteligencia poderá ser feita na classe filha - default em Rest com Json
    If Self:lSucesso

        //Inteligencia poderá ser feita na classe filha - default em Rest com Json    
        If Self:oEnvia == Nil
            Self:oEnvia := FWRest():New("")
            Self:oEnvia:nTimeOut := self:nTimeOut
        EndIf

        Self:oEnvia:SetPath( Self:oConfProce["url"] )

        Self:cBody := "[" + Self:cBody + "]"

        Self:oEnvia:SetPostParams(EncodeUTF8(Self:cBody))
        LjGrvLog(" RmiEnvPdvSyncObj ", "Method Envia() no oEnvia:SetPostParams(cBody) " ,{Self:cBody})

        //Carrega o aHeader
        self:getHeader()

        If Self:oEnvia:Post( self:aHeader )
            Self:lSucesso := .T.
            Self:cRetorno := Self:oEnvia:oResponseH:cStatusCode
        Else
            Self:StatusLista() //Atualiza o Erro
            Self:cRetorno := Self:oEnvia:GetLastError() + " - [" + Self:oConfProce["url"] + "]" + CRLF
            Self:cRetorno += IIF( ValType(self:oEnvia:CRESULT) == "C", self:oEnvia:CRESULT, "Detalhe do erro não retornado." )
            LjGrvLog(" RmiEnvPdvSyncObj ", "Não teve sucesso retorno => " ,{Self:cRetorno}) 
        EndIf
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FechaLote
Método para gerar o Json que fara o fechamento do lote

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method FechaLote() Class RmiEnvPdvSyncObj

    If !Self:ProcessoPend()
        Self:EnviaFechaLote()
    EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessosPend
Verifica se há algum processo que ainda não terminou o envio
antes de fechar o lote

@author  Bruno Almeida
@Date    21/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method ProcessoPend() Class RmiEnvPdvSyncObj              

    Local aArea     := getArea()
    Local cQuery    := ""               //Query de processos pendentes
    Local cAliasMik := GetNextAlias()   //Proximo alias disponivel
    Local cAliasMhr := GetNextAlias()   //Proximo alias disponivel
    Local lRet      := .F.              //Variavel de retorno
    Local cAuxIn    := ""

    cQuery := "SELECT MIK_CPROCE, MIK_LOTE"
    cQuery += "  FROM " + RetSqlName("MIK")

    If !Empty(Self:cLote)
        cQuery += " WHERE MIK_LOTE = '" + Self:cLote + "'"
    Else
        cQuery += " WHERE MIK_CPROCE = '" + Self:cProcesso + "'"
        cQuery += "   AND MIK_DTFECH = ' '"
    EndIf

    cQuery += "   AND MIK_FILIAL = '" + xFilial("MIK") + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMik, .T., .F.)

    If !(cAliasMik)->( Eof() )

        If Empty(Self:cLote)
            Self:cLote := AllTrim((cAliasMik)->MIK_LOTE)
        EndIf

        cQuery := " SELECT COUNT(1) REGISTROS_ENVIADOS "
        cQuery += " FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "' "
        cQuery += " AND MHR_CASSIN = '" + self:cAssinante + "' "
        cQuery += " AND MHR_LOTE = '" + Self:cLote + "' "
        cQuery += " AND MHR_STATUS <> '1' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        cAliasMhr := GetNextAlias() 
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhr, .T., .F.)
        
        nRecEnviados := (cAliasMhr)->REGISTROS_ENVIADOS
        
        (cAliasMhr)->( DbCloseArea() )

        If nRecEnviados >= Self:nMaxPorLote
            lRet := .F. 
            LjGrvLog(" RmiEnvPdvSyncObj ", "LOTE  [" + Self:cLote + "] sera fechado pois execedeu o limite de: " + cValToChar(Self:nMaxPorLote) + " envios por LOTE")
        Else

            While !(cAliasMik)->( Eof() )
				cAuxIn += " '" + (cAliasMik)->MIK_CPROCE +  "',"
                (cAliasMik)->( DbSkip() )
            EndDo
            
            cAuxIn := SUBSTR(cAuxIn,1, Len(cAuxIn) - 1)

            cQuery := " SELECT COUNT(1) REGISTROS_PENDENTE"
            cQuery += " FROM " + RetSqlName("MHR") + " MHR INNER JOIN " + RetSqlName("MHQ") + " MHQ"
            cQuery +=   " ON MHR_FILIAL = MHQ_FILIAL AND MHR_UIDMHQ = MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"
            cQuery += " WHERE MHR.D_E_L_E_T_ = ' '"
            cQuery +=   " AND MHR_FILIAL = '" + xFilial("MHR") + "'"
            cQuery +=   " AND MHR_CPROCE In (" + cAuxIn + ")"
            cQuery +=   " AND MHR_CASSIN = '" + self:cAssinante + "' "
            cQuery +=   " AND MHR_STATUS = '1'"

            cAliasMhr := GetNextAlias() 
            DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasMhr, .T., .F.)

            If (cAliasMhr)->REGISTROS_PENDENTE > 0
                lRet := .T.
                LjGrvLog(" RmiEnvPdvSyncObj ", "Lote (" + Self:cLote + ") não sera encerrado pois consta MHR_STATUS = 1 para o processo " + AllTrim((cAliasMik)->MIK_CPROCE))
            EndIf

            (cAliasMhr)->( DbCloseArea() )
        EndIf 
        
    Else
        lRet := .T.
    EndIf
    
    (cAliasMik)->( DbCloseArea() )

    restArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Metodo que ira atualizar a situação da distribuição e gravar o de/para

@author  Bruno Almeida
@Date    15/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Method Grava(cStatus) Class RmiEnvPdvSyncObj        

    Local nCont         := 1
    Local lInclui       := .F.
    Local dDate         := Nil
    Local cTime         := ""
    Local nTamFil       := tamSx3("MIP_FILIAL")[1]
    Local nTamPro       := tamSx3("MIP_CPROCE")[1]
    Local cBkpFilAnt    := cFilAnt

    Default cStatus     := IIF( self:lSucesso, "6", IIF(self:lEnvDuplic, "R", "3") )     //1=A processar, 2=Processado, 3=Erro, 6=Aguardando Confirmação R=Repetido
    
    Begin Transaction

        //Atualiza dados na tabela MHR
        _Super:atualizaMHR(IIF( self:lSucesso, "2", IIF(self:lEnvDuplic, "R", "3") ))

        //Gera Detalhe da Distribuição
        If self:lDetDistrib .And. !self:lEnvDuplic

            self:getLojasProprietario()

            For nCont:=1 To Len(self:aLojasProprietario)

                cFilAnt := padR(self:aLojasProprietario[nCont], nTamFil)
                dDate   := Date()
                cTime   := TimeFull()

                MIP->( DbSetOrder(1) )  //MIP_FILIAL+MIP_CPROCE+MIP_CHVUNI
                lInclui := !MIP->( DbSeek(padR(self:aLojasProprietario[nCont], nTamFil) + padR(self:cProcesso, nTamPro) + self:cChaveUnica) )

                RecLock("MIP", lInclui)

                    //Tratamento para reenvio
                    if !lInclui .and. MIP->MIP_UIDORI == MHR->MHR_UIDMHQ
                        MIP->MIP_TENTAT := cValToChar( val(MIP->MIP_TENTAT) + 1 )
                    else
                        MIP->MIP_TENTAT := "0"
                    endIf

                    MIP->MIP_FILIAL := self:aLojasProprietario[nCont]
                    MIP->MIP_CPROCE := self:cProcesso
                    MIP->MIP_CHVUNI := self:cChaveUnica
                    MIP->MIP_LOTE   := self:cLote
                    MIP->MIP_DATGER := dDate
                    MIP->MIP_HORGER := cTime
                    MIP->MIP_DATPRO := IIF( self:lSucesso, CtoD("") , dDate)
                    MIP->MIP_HORPRO := IIF( self:lSucesso, ""       , cTime)
                    MIP->MIP_STATUS := cStatus
                    MIP->MIP_UUID   := FwUUID("MIP" + DtoS(MIP->MIP_DATGER) + MIP->MIP_HORGER)
                    MIP->MIP_UIDORI := MHR->MHR_UIDMHQ
                    MIP->MIP_IDRET  := MHR->MHR_IDRET

                MIP->( MsUnLock() )
            
                //Grava log MHL
                If !self:lSucesso
                    RmiGrvLog(cStatus       , "MIP"         , MIP->( Recno() )  , "ENVIA"       ,;
                            self:cRetorno  , /*lRegNew*/   , /*lTxt*/          , /*cFilStatus*/,;
                            .F.            , /*nIndice*/   , self:cChaveUnica  , self:cProcesso,;
                            self:cAssinante, MIP->MIP_UIDORI )
                EndIf

            Next nCont

            cFilAnt := cBkpFilAnt
        EndIf

    End Transaction

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PosExecucao
Metodo com as regras para efetuar algum tratamento depois de ser feito o envio.

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Method PosExecucao() Class RmiEnvPdvSyncObj
    self:FechaLote()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Consulta
Metodo que efetua consulta das distribuições a enviar

@author  Lucas Novais (lNovais)
@version 1.0
/*/
//-------------------------------------------------------------------
Method Consulta() Class RmiEnvPdvSyncObj

    Local cDB       := AllTrim( TcGetDB() )
    Local cQuant    := "1000"
    Local cSelect   := IIF( cDB == "MSSQL"            , " TOP " + cQuant          , "" )
    Local cWhere    := IIF( cDB == "ORACLE"           , " AND ROWNUM <= " + cQuant, "" )
    Local cLimit    := IIF( !(cDB $ "MSSQL|ORACLE")   , " LIMIT " + cQuant        , "" )
    Local nX        := 0
    Local aDataHora := {}
    Local aTent     := {}

    if !self:precedencia()

        // -- Se tiver LOTE em aberto para o processo atual faço a consulta. 
        If Self:GetLote(Self:cProcesso) .OR. !Self:GetLote()

            LjGrvLog(" RmiEnviaObj ", "Antes da execução do metodo consulta", FWTimeStamp(2))
            
            //Carrega a distribuições que devem ser enviadas
            LjGrvLog("RmiEnviaObj", "Conectado com banco de dados: " + cDB)

            self:cAliasQuery := GetNextAlias()

            self:cQuery      := "SELECT "
            self:cQuery      += cSelect
            self:cQuery      += " MHQ_CPROCE, MHQ.R_E_C_N_O_ AS RECNO_PUB, MHR.R_E_C_N_O_ AS RECNO_DIS "
            self:cQuery      += " FROM " + RetSqlName("MHQ") + " MHQ INNER JOIN " + RetSqlName("MHR") + " MHR "
            self:cQuery      += " ON MHQ_FILIAL = MHR_FILIAL AND MHQ_UUID = MHR_UIDMHQ "

            If !Empty(self:cProcesso)
                self:cQuery  += " AND MHQ_CPROCE = '" + self:cProcesso + "'"
            EndIf    

            self:cQuery      += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
            self:cQuery      += " AND MHR_CASSIN = '" + self:cAssinante + "'"
            self:cQuery      += " AND ( MHR_STATUS = '1'"                         //1=A processar, 2=Processado, 3=Erro

            If self:lDetDistrib

                //Pelo menos um reprocessamento sempre ira ter e vai mandar em um proximo lote
                self:cQuery += " OR"
                self:cQuery +=      " MHR_UIDMHQ IN (   SELECT MIP_UIDORI"
                self:cQuery +=                          " FROM " + RetSqlName("MIP") 
                self:cQuery +=                          " WHERE D_E_L_E_T_ = ' '"
                self:cQuery +=                              " AND MIP_CPROCE = '" + self:cProcesso + "'"
                self:cQuery +=                              " AND MIP_STATUS = '3'"
                self:cQuery +=                              " AND MIP_TENTAT = '0' 
                self:cQuery +=                              " AND MIP_DATPRO = '" + dToS(dDataBase) + "'"
                self:cQuery +=                              " AND ( MIP_LOTE = '" + space(tamSx3("MIP_LOTE")[1]) + "' OR MIP_LOTE <> '" + padR(self:cLote, tamSx3("MIP_LOTE")[1]) + "' )"
                self:cQuery +=                      ")" 

                if self:oConfProce <> Nil .and. self:oConfProce:hasProperty("qtdereenvio")

                    aTent  := self:oConfProce["qtdereenvio"]

                    LjGrvLog("RmiEnviaObj", "Encontrada propriedade na configuração para reenvio: ", aTent)

                    If Len(aTent) == 0 .or. Len(aTent) > 9
                        LjGrvLog("RmiEnviaObj", "A tag qtdereenvio configurada no processo de #1 está incorreta, não será feito o reenvio de registros com erro, por favor verifique!", aTent)
                        Return Nil
                    EndIF        

                    self:cQuery += " OR"
                    self:cQuery +=      " MHR_UIDMHQ IN (   SELECT MIP_UIDORI"
                    self:cQuery +=                          " FROM " + RetSqlName("MIP") 
                    self:cQuery +=                          " WHERE D_E_L_E_T_ = ' '"
                    self:cQuery +=                              " AND MIP_CPROCE = '" + self:cProcesso + "'"
                    self:cQuery +=                              " AND MIP_STATUS = '3'"
                    self:cQuery +=                              " AND ("

                    //Inclui a quantidade de tentativas de reenvio
                    For nX := 1 to len(aTent)

                        aDataHora := SHPRepData(aTent[nX]) 

                        aDataHora[1] := DtoS(aDataHora[1])
                        aDataHora[2] := aDataHora[2] + ":59" 

                        self:cQuery +=                                  " (MIP_TENTAT = '" + cValtoChar(nX) + "' AND MIP_DATPRO = '" + aDataHora[1] + "' AND MIP_HORPRO <= '" + aDataHora[2] + "')"

                        If nX < Len(aTent)
                            self:cQuery +=                          " OR "
                        Endif
                    Next nX

                    self:cQuery +=      " ) )"
                endIf
            EndIF

            self:cQuery += " )"
            self:cQuery += " AND MHR.D_E_L_E_T_ = ' ' "
            self:cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "

            //Ajuste envia PdvSync para nao repetir itens na lista.
            If self:nMhrRec > 0
                self:cQuery      += " AND MHR.R_E_C_N_O_ > "+Alltrim(STR(self:nMhrRec))
            EndIf
            
            self:cQuery      += cWhere    

            self:cQuery      += " ORDER BY MHR.R_E_C_N_O_"

            self:cQuery      += cLimit

            ljGrvLog("RmiEnvObj", "Query com registros que serão enviados:", self:cQuery)
            
            DbUseArea(.T., "TOPCONN", TcGenQry( , , self:cQuery), self:cAliasQuery, .T., .F.)

            LjGrvLog(" RmiEnviaObj ", "Apos executar a query do metodo consulta", FWTimeStamp(2))
        Else   
            LjGrvLog("Consulta","AVISO: " + STR0001 + Self:cProcesso + STR0002)  //"Não existe um lote em aberto para o processo " # ", os dados desse processo não serão enviados até que o lote em aberto seja fechado."
        EndIf

    endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Processa
Metodo que ira controlar o processamento dos envios em lista

@author  totvs
@version 1.0
/*/
//-------------------------------------------------------------------
Method Processa() Class RmiEnvPdvSyncObj

    Local nX            := 0
    Local lCtrlMd5      := AttIsMemberOf(Self, "cMD5", .T.) .And. AttIsMemberOf(Self, "lEnvDuplic", .T. ) .And. AttIsMemberOf(Self, "nMhqRec", .T. )
    Local aAreaMhq      := MHQ->(GetArea())
    Local lBkpSucesso   := .T.

    self:cBodyList      := ''
    self:aMhrRec        := {}
    
    //Carrega a distribuições que devem ser enviadas
    self:SetaProcesso(self:cProcesso)
    
    If self:lSucesso
        
        self:Consulta()
        self:nQtdList := IIF(self:oConfProce:hasProperty("qtdEnvio") ,self:oConfProce['qtdEnvio'],1)

        //Adicionando Limite de itens na Lista 
        self:nQtdList := IIF(self:nQtdList>1000,1000,self:nQtdList)

    EndIf
    

    If self:lSucesso .And. !Empty(self:cAliasQuery)
    
        While !(self:cAliasQuery)->( Eof() ) //500        

            If !self:PreExecucao()
                Exit
            EndIf            
            
            If Self:lSucesso
                
                While !(self:cAliasQuery)->( Eof() ) .AND. Len(self:aMhrRec) < self:nQtdList
                    
                    self:lSucesso := .T.
                    self:cRetorno := ""
                    self:cBody    := ""

                    //Posiciona na publicação
                    MHQ->( DbSetOrder(1) )  //MHQ_FILIAL + MHQ_ORIGEM + MHQ_CPROCE
                    MHQ->( DbGoTo( (self:cAliasQuery)->RECNO_PUB ) )                                        

                    self:cOrigem     := MHQ->MHQ_ORIGEM
                    self:cEvento     := MHQ->MHQ_EVENTO //1=Upsert, 2=Delete, 3=Inutilização
                    self:cChaveUnica := MHQ->MHQ_CHVUNI
                    self:cIdExt      := allTrim(MHQ->MHQ_IDEXT)

                    If lCtrlMd5
                        self:nMhqRec     := MHQ->(Recno())
                    EndIf 
                    
                    //Carrega o layout com os dados da publicação
                    If self:lSucesso                            
                        //Carrega a publicação que será distribuida
                        self:cPublica := AllTrim(MHQ->MHQ_MENSAG)
                        If self:oPublica == Nil
                            self:oPublica := JsonObject():New()
                        EndIf
                        If !Empty(Alltrim(self:cPublica))
                            self:oPublica:FromJson(self:cPublica)                                
                            self:CarregaBody()
                        Else
                            self:lSucesso := .F.
                            self:cRetorno := "campo MHQ_MENSAG em branco MHQ_UUID -> "+ MHQ->MHQ_UUID    
                        EndIf    
                    EndIf

                    // -- se For um envio duplicado não incluo na lista de envio
                    If (lCtrlMd5 .And. !Self:lEnvDuplic) .Or. !lCtrlMd5
                        self:cBodyList    += IIF(Empty(self:cBodyList),self:cBody,","+self:cBody)
                    EndIf 
                    
                    Aadd(self:aMhrRec,{})
                    Aadd(self:aMhrRec[Len(self:aMhrRec)],(self:cAliasQuery)->RECNO_DIS)
                    Aadd(self:aMhrRec[Len(self:aMhrRec)],self:cBody)
                    Aadd(self:aMhrRec[Len(self:aMhrRec)],Self:cIdRetaguarda)
                    Aadd(self:aMhrRec[Len(self:aMhrRec)],self:lSucesso)
                    Aadd(self:aMhrRec[Len(self:aMhrRec)],self:cRetorno)
                    
                    If lCtrlMd5
                        Aadd(self:aMhrRec[Len(self:aMhrRec)],Self:cMD5)
                        Aadd(self:aMhrRec[Len(self:aMhrRec)],Self:lEnvDuplic)
                    EndIf 
                    
                    self:nMhrRec := (self:cAliasQuery)->RECNO_DIS
                    
                    If !Empty(self:cBodyList)
                        Self:lSucesso := .T.
                        self:cRetorno := ""
                    EndIf 

                    (self:cAliasQuery)->( DbSkip() )
                    
                EndDo
            EndIf
            
            If self:lSucesso .AND. !Empty(self:cBodyList)
                self:cBody := self:cBodyList                            
                self:Envia()
                lBkpSucesso := self:lSucesso
            EndIf    
            
            MHR->( DbSetOrder(1) )  //MHR_FILIAL + MHR_CASSIN + MHR_CPROCE
            For nX := 1 To Len(self:aMhrRec)
                MHR->( DbGoTo(self:aMhrRec[nX][1] ))
                self:cBody          := self:aMhrRec[nX][2] // Grava Body na linha MHR
                Self:cIdRetaguarda  := self:aMhrRec[nX][3]//adiciona ID Retaguarda processado no RmiEnviaObj
                self:cChaveUnica    := Posicione("MHQ",7,xFilial("MHQ")+MHR->MHR_UIDMHQ,"MHQ_CHVUNI") //Ajusta Chave unica quando é lista.
                
                If lBkpSucesso
                    self:lSucesso := self:aMhrRec[nX][4] // Se estiver com erro gravar o motivo.   
                EndIf
                
                If lCtrlMd5
                    Self:cMD5 := self:aMhrRec[nX][6] // Md5 exclusivo do registro
                    Self:lEnvDuplic := self:aMhrRec[nX][7] // Md5 exclusivo do registro
                EndIf 

                self:cRetorno := IIF(!Empty(self:aMhrRec[nX][5]),self:aMhrRec[nX][5],self:cRetorno)// Gravar o motivo do erro
                If !MHR->(Eof())                        
                    self:Grava()
                EndIf
            Next
            LjGrvLog("RmiEnvPdvSyncObj", "Executa PosExecucao ")
            self:PosExecucao()
            self:aMhrRec := {}
            self:cBodyList := ""
            self:lSucesso  := .T. 


            If (self:cAliasQuery)->( Eof() )
                self:Consulta()
            Endif              
        EndDo

        (self:cAliasQuery)->( DbCloseArea() )

        self:PosExecucao()  //caso o lote estiver aberto fechar.
    EndIf

    If self:lDetDistrib                                                                                             .And. ;
    ( Self:oConfAssin:hasProperty("url_consultalote") .And. !Empty(Self:oConfAssin["url_consultalote"]) )           .And. ;
    ( Self:oConfAssin:hasProperty("url_lojaloteretornos") .And. !Empty(Self:oConfAssin["url_lojaloteretornos"]) )
        self:StatusDet()
    else
        If ExistFunc("PSHPostStatus")
            PSHPostStatus("STATUSPDVSYNC",.F.)
        EndIf    
    EndIf        

    RestArea(aAreaMHQ)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getLojasProprietario
Metodo que carrega as lojas atreladas a um determinado proprietario

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method getLojasProprietario() Class RmiEnvPdvSyncObj

    Local aArea             := GetArea()
    Local cCompartilhamento := PadR( "COMPARTILHAMENTOS", TamSx3("MIH_TIPCAD")[1] )
    Local cCadLojas         := PadR( "CADASTRO DE LOJA" , TamSx3("MIH_TIPCAD")[1] )
    Local cNivel            := ""
    Local cProprietario     := ""
    Local cFilProtheus      := ""
    Local aCodLojas         := {}
    Local nCont             := 0
    Local cProcesso         := allTrim(self:cProcesso)

    FwFreeArray(self:aLojasProprietario)
    self:aLojasProprietario := {}

    If self:oBody:hasProperty("idProprietario")
        cProprietario := self:oBody["idProprietario"]
    Else
        LjxjMsgErr( I18n(STR0012, {self:cProcesso}), /*cSolucao*/, "RmiEnvPdvSyncObj") //"Tag idProprietario não localizada no layout de envio do processo #1, geração da tabela MIP não será feita."
    EndIf

    If !Empty(cProprietario)

        MIH->( DbSetOrder(1) )  //MIH_FILIAL, MIH_TIPCAD, MIH_ID
        If MIH->( DbSeek( xFilial("MIH") + cCompartilhamento + cProprietario ) ) .and. ( MIH->MIH_ATIVO $ "1|3" .or. cProcesso $ "COMPARTILHAMENT|CADASTRO LOJA" )

            cNivel := LjCAuxRet("nivel")

            //Compartilhada
            If cNivel == "0"

                If MIH->( DbSeek(xFilial("MIH") + cCadLojas) )

                    While !MIH->( Eof() ) .And. MIH->MIH_TIPCAD == cCadLojas

                        //Valida se a loja esta ativa e se é compativel com a filial de origem do dado
                        cFilProtheus := LjCAuxRet("IDFilialProtheus")
                        if  ( MIH->MIH_ATIVO $ "1|3" .or. cProcesso $ "COMPARTILHAMENT|CADASTRO LOJA" ) .and.;
                            ( empty(self:cIdExt) .or. self:cIdExt == subStr(cFilProtheus, 1, Len(self:cIdExt)) )

                            Aadd(self:aLojasProprietario, cFilProtheus)
                        endIf

                        MIH->( DbSkip() )
                    EndDo
                EndIf

            //Nivel 1 - Central
            elseIf cNivel == "1"

                //Carrega os codigos de lojas relacionados ao compartilhamento nivel 1
                MIH->( DbSeek( xFilial("MIH") + cCompartilhamento ) )
                While !MIH->( eof() ) .and. MIH->MIH_TIPCAD == cCompartilhamento

                    if  ( MIH->MIH_ATIVO $ "1|3" .or. cProcesso $ "COMPARTILHAMENT|CADASTRO LOJA" ) .and.; 
                        LjCAuxRet("IdRetaguardaPai") == cProprietario

                        aadd(aCodLojas, LjCAuxRet("CodigoLoja"))
                    endIf

                    MIH->( DbSkip() )
                EndDo    

                //Carrega as filiais relacionadas aos codigos de lojas
                for nCont:=1 to len(aCodLojas)

                    if MIH->( DbSeek( xFilial("MIH") + cCadLojas + aCodLojas[nCont] ) )
                    
                        //Valida se a loja esta ativa e se é compativel com a filial de origem do dado
                        cFilProtheus := LjCAuxRet("IDFilialProtheus")
                        if  ( MIH->MIH_ATIVO $ "1|3" .or. cProcesso $ "COMPARTILHAMENT|CADASTRO LOJA" ) .and.;
                            ( empty(self:cIdExt) .or. self:cIdExt == subStr(cFilProtheus, 1, Len(self:cIdExt)) )

                            aadd(self:aLojasProprietario, cFilProtheus)
                        endIf
                    endIf
                next nCont

            //Exclusiva
            Else

                If MIH->( DbSeek( xFilial("MIH") + cCadLojas + LjCAuxRet("CodigoLoja") ) )
                
                    //Valida se a loja esta ativa e se é compativel com a filial de origem do dado
                    cFilProtheus := LjCAuxRet("IDFilialProtheus")
                    if  ( MIH->MIH_ATIVO $ "1|3" .or. cProcesso $ "COMPARTILHAMENT|CADASTRO LOJA" ) .and.;
                        ( empty(self:cIdExt) .or. self:cIdExt == subStr(cFilProtheus, 1, Len(self:cIdExt)) )

                        Aadd(self:aLojasProprietario, cFilProtheus)
                    endIf
                EndIf
            EndIf
        EndIf
    EndIf

    fwFreeArray(aCodLojas)

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} EnviaIP
Envia para a engenharia a informação de IP externo para atualização de IP do servidor (referente ao fluxo online)

@author  Evandro Pattaro
@Date    13/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method EnviaIP() Class RmiEnvPdvSyncObj

    Local oRest := Nil //Objeto que faz a comunicação via Rest com PDVSync para abrir ou fechar um lote
    Local cJson := ""
    Local cRetorno
    Local lRet  := .T.

    If self:oConfAssin:hasProperty("url_enviaip") .And. !Empty(Self:oConfAssin["url_enviaip"])

        If lRet
            oRest := FWRest():New("")
            oRest:nTimeOut := self:nTimeOut

            cJson := '{"serviceName": "'+Self:oConfAssin["inquilino"]+'"}'

            //Seta a url
            oRest:SetPath( self:oConfAssin["url_enviaip"] )

            //Seta o corpo do Post
            oRest:SetPostParams( cJson )

            //Carrega o aHeader
            self:getHeader()

            //Busca o lote
            If !oRest:Post( self:aHeader )
                cRetorno := STR0010 + " - " + oRest:GetLastError() + " - " + IIF( ValType(oRest:cResult) == "C", oRest:cResult, STR0008 ) // "EnviaIP - Não foi possível realizar o envio do IP:"/"Detalhe do erro não retornado."
                LjxjMsgErr(cRetorno, /*cSolucao*/, "StatusDet") 
            Else
                LjGrvLog(" EnviaIP ",STR0013 + self:oConfAssin["url_enviaip"]) //"IP Enviado com sucesso! Endpoint do envio:  "
            EndIf
            
            FwFreeObj(oRest)
        EndIf
    EndIf        
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} StatusDet
Método que irá tratar os status dos envios detalhados por loja/lote (MIP)

@author  Evandro Pattaro
@Date    13/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method StatusDet() Class RmiEnvPdvSyncObj
    
    Local oStatus   := JsonObject():New()
    Local oRetornos := JsonObject():New()
    Local cAlias    := GetNextAlias()   //Proximo alias disponivel    
    Local cQuery    := ""               //Guarda a query a ser executada
    Local cRet      := ""
    Local cStatus   := ""
    Local cProce    := ""
    Local cIdRet    := ""
    Local cLote     := ""
    Local lHasNext  := .F. 
    Local nX        := 0
    Local nPagina   := 0
    Local lContinua := .F.
    Local nData     := 0
    
    If self:lSucesso
    
        //Consulta registros pendentes de confirmação que estão com o lote fechado
        cQuery := " SELECT MIP_FILIAL,MIP_LOTE"
        cQuery += " FROM " + RetSqlName("MIP") + " MIP INNER JOIN " + RetSqlName("MIK") + " MIK" 
        cQuery +=       " ON MIK_FILIAL = '" + xFilial("MIK") + "' AND MIP_LOTE = MIK_LOTE"
        cQuery += " WHERE MIP_STATUS = '6'"
        cQuery +=       " AND MIP_CPROCE = '"+self:cProcesso+"'"
        cQuery +=       " AND MIP.D_E_L_E_T_ = ' '"
        cQuery +=       " AND MIK_DTFECH <> '" + space( tamSx3("MIK_DTFECH")[1] ) + "'"
        cQuery +=       " AND MIK.D_E_L_E_T_ = ' '"
        cQuery += " GROUP BY MIP_FILIAL,MIP_LOTE"
        cQuery += " ORDER BY MIP_FILIAL,MIP_LOTE"

        cQuery := ChangeQuery(cQuery)

        ljGrvLog("RmiEnvPdvSyncObj", "Query que retorna os registros pendentes de confirmação que estão com o lote fechado.", cQuery)
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        //Existe registro para atualizar e esta dentro do tempo para execução
        If !(cAlias)->( Eof() ) .and. self:ExecLojaLote()

            //Envia status de execução lojaLote para o SYNC
            If ExistFunc("PSHPostStatus")
                PSHPostStatus("STATUSPDVSYNC")
            EndIf

            While !(cAlias)->( Eof() )

                cStatus := ""
                nPagina := 0   
                nX      := 0 
                cLote   := (cAlias)->MIP_LOTE

                ljGrvLog("RmiEnvPdvSyncObj", "Executa a atualização de status do lote", {self:cProcesso, alltrim(cLote), alltrim((cAlias)->MIP_FILIAL)})

                //Retorna o status do sync e popula o jsonObject
                If oStatus:fromJson( self:getStatus( alltrim(cLote), alltrim((cAlias)->MIP_FILIAL) ) ) == nil

                    If oStatus["success"]

                        If oStatus["data"]:hasProperty("status")                             

                            self:UpdStatus(cLote,(cAlias)->MIP_FILIAL) //atualizo somente a data e hora de consulta

                            //BaixadoComSucesso - Indica que todos os dados enviados para o loja lote foram integrados com sucesso ao PDV Omni
                            If oStatus["data"]["status"] == 5
                                cStatus := "2"

                            //BaixadoComErro - Indica que ao menos um item deu erro na integração com o PDV Omni
                            ElseIf oStatus["data"]["status"] == 6 //Lote está com erros. Verificar os retornos detalhados do lote

                                While lHasNext .Or. nPagina == 0                                        

                                    If ValType( cRet := oRetornos:FromJson(self:GetStatus(Alltrim(cLote),Alltrim((cAlias)->MIP_FILIAL),.T.,nPagina)) ) == "C"
                                        self:lSucesso := .F.
                                        self:cRetorno := I18n(STR0005, {"lojaloteretornos"}) + cRet //"Retorno da API #1 inválido. Verifique! - "
                                        
                                        LjxjMsgErr(self:cRetorno, /*cSolucao*/, "StatusDet")
                                        Exit    
                                    Else
                                        If oRetornos["success"]

                                            lContinua := .F.

                                            if valType( oRetornos["data"] ) == "A" 

                                                for nData:=1 to len(oRetornos["data"])

                                                    //BaixadoComErro - Indica que ao menos um item deu erro na integração com o PDV Omni
                                                    if oRetornos["data"][nData]["status"] == 6 .and. valType( oRetornos["data"][nData]["errosIdentificados"] ) == "A"

                                                        lContinua := .T.

                                                        For nX := 1 To Len(oRetornos["data"][nData]["errosIdentificados"])
                                                            
                                                            lHasNext := IIF(oRetornos["data"][nData]["errosIdentificados"][nX]:hasProperty("hasnext") ,oRetornos["data"][nData]["errosIdentificados"][nX]["hasnext"],.F.)

                                                            cProce  := PadR( self:GetTiposDados(oRetornos["data"][nData]["errosIdentificados"][nX]["tipoLojaLote"]), TamSx3("MIP_CPROCE")[1] )
                                                            cIdRet  := PadR( oRetornos["data"][nData]["errosIdentificados"][nX]["idRetaguarda"], TamSx3("MIP_IDRET")[1])

                                                            self:GravaErrosStatus((cAlias)->MIP_FILIAL,(cAlias)->MIP_LOTE,cProce,cIdRet,oRetornos["data"][nData]["errosIdentificados"][nX]["erro"])
                                                        Next
                                            
                                                    endIf
                                                next nData
                                            endIf

                                            if !lContinua
                                                self:lSucesso := .F.
                                                self:cRetorno := i18n(STR0016, {"syncServer [lojaLoteRetornos]", (cAlias)->MIP_LOTE, oRetornos:toJson()})   //"Retorno do #1 incompatível, todos os registros do lote [#2] serão considerados com erro. Retorno: #3"
                                                self:gravaErrosStatus( (cAlias)->MIP_FILIAL, (cAlias)->MIP_LOTE, /*cProce*/, /*cIdRet*/, self:cRetorno )
                                                ljxjMsgErr(self:cRetorno, /*cSolucao*/, "StatusDet")
                                            endIf

                                        Else
                                            self:lSucesso := .F.
                                            self:cRetorno := oRetornos["message"]
                                            LjxjMsgErr(self:cRetorno, /*cSolucao*/, "StatusDet") 
                                            Exit
                                        EndIf    
                                        
                                    EndIf

                                    nPagina++                                        
                                    
                                Enddo

                                cStatus := "2" //Como já atualizei os erros que deram nos itens, atualizo os itens restantes como OK 
                            Endif  

                            If !Empty(cStatus)
                                self:UpdStatus(cLote,(cAlias)->MIP_FILIAL,cStatus)    
                            EndIf

                        Else
                            self:cRetorno := I18n(STR0005, {"lojalotes"}) + oStatus:toJson() //"Retorno da API lojalotes inválido. Verifique! - "   
                        EndIf
                    Else
                        self:lSucesso := .F.
                        self:cRetorno := oStatus["message"]
                        LjxjMsgErr(self:cRetorno, /*cSolucao*/, "StatusDet") 
                    EndIf                                        

                EndIf

                (cAlias)->(DbSkip())    

            EndDo
                        
        EndIf

    Else
        LjGrvLog(" RmiEnvPdvSyncObj ", Self:cRetorno)
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
Método que faz a comunicação com o PdvSync para consulta do status do lote enviado

@param cLote, Caractere,    código do lote que foi enviado para o PDVSync
@param cLoja, Caractere,  código da filial distribuída pelo LojaLote do PDVSync
@param lErro, Lógico,  Indica se a consulta será do status geral do lote (.F.) ou se é do detalhe dos erros no Lojalote (.T.)
@Param nPagina, Inteiro, Indica a página do retorno da consulta

@author  Evandro Pattaro
@Date    13/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetStatus(cLote,cLoja,lErro,nPagina) Class RmiEnvPdvSyncObj

    Local oRest         := Nil  //Objeto que faz a comunicação via Rest com PDVSync para abrir ou fechar um lote
    Local cJson         := ""
    Local aHeader       := {}
    Local cLltConURL    := AllTrim(Self:oConfAssin["url_consultalote"]) + "/" + AllTrim(Self:oConfAssin["inquilino"])                   //consulta do status geral
    Local cLltRetURL    := AllTrim(Self:oConfAssin["url_lojaloteretornos"]) + "/" + AllTrim(Self:oConfAssin["inquilino"]) + "/" + cLote //consulta lote com erros
    Local cUrl          := ""
    Local cErro         := ""

    Default lErro := .F.

    //Carrega o aHeader
    self:getHeader()
    aHeader := aClone(self:aHeader)
    
    oRest := FWRest():New("")
    oRest:nTimeOut := self:nTimeOut

    //Seta a url do lote
    cUrl := IIF(lErro, cLltRetURL, cLltConURL)
    oRest:SetPath(cUrl)

    If !lErro
        aAdd( aHeader, "loteOrigem: " + cLote)
    EndIf
    
    aAdd( aHeader, IIF(lErro,"idRetaguardaLoja: ","idLojaRetaguarda: ") + cLoja)

    If lErro .And. nPagina > 0
        aAdd( aHeader, "pagina: " + cValToChar(nPagina))
    EndIf
    
    //Busca o lote
    If oRest:Get(aHeader)

        cJson := DeCodeUTF8(oRest:GetResult())
        ljGrvLog("RmiEnvPdvSyncObj", "Retorno do sync, metodo de consulta de status:", {cUrl, aHeader, cJson})
    Else

        cErro := STR0007 + cLote + " - " + oRest:GetLastError() + " - " + IIF( ValType(oRest:cResult) == "C", oRest:cResult, STR0008 )  //"Não foi possível realizar a consulta do status do lote:" / "Detalhe do erro não retornado."
        self:gravaErrosStatus(cLoja, cLote, /*cProce*/, /*cIdRet*/, cErro)
    EndIf

    fwFreeArray(aHeader)
    fwFreeObj(oRest)

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdStatus
Método que atualiza o status dos envios detalhados por Loja/Lote (MIP)

@param cLote, Caractere,    código do lote que foi enviado para o PDVSync
@param cLoja, Caractere,  código da filial distribuída pelo LojaLote do PDVSync
@param cStatus, Caractere,  código do status do Lote a ser atualizado na tabela

@enum Status dos envios: 

MHR : 
    1 = Aguardando processamento
    6= enviado para o sync
    2 = baixado no pdv (tudo ok) 
    3 = erro 
MIP : 
    1 = Aguardando processamento LojaLote; 
    2 = Baixado no PDV; (no sync Lojalote = 5) 
    3 = Erro. (no sync Lojalote = 6 )

@author  Evandro Pattaro
@Date    13/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method UpdStatus(cLote,cLoja,cStatus) Class RmiEnvPdvSyncObj
    
    Local cSql := ""
    
    Default cStatus := ""

    cSql := "UPDATE " + RetSqlName("MIP") + " SET "
    
    If cStatus == "2"
        cSql += " MIP_STATUS = '"+ cStatus +"',"
        cSql += " MIP_ULTOK = '"+ FwTimeStamp(2) +"',"
    EndIf

    cSql += " MIP_DATPRO = '"+ DTOS(Date()) +"',"
    cSql += " MIP_HORPRO = '"+ TimeFull() +"'"
    cSql += " WHERE MIP_FILIAL = '"+ cLoja +"'"
    cSql += " AND MIP_LOTE =  '"+ cLote +"'"
    cSql += " AND MIP_CPROCE = '"+ self:cProcesso +"'"    
    cSql += " AND MIP_STATUS = '6'"
    cSql += " AND D_E_L_E_T_ = ' '"

    If TcSqlExec(cSql) < 0
        self:lSucesso := .F.
        self:cRetorno := STR0011 + TcSqlError() //"Não foi possível executar UPDATE: "
        LjxjMsgErr(self:cRetorno, /*Solucao*/, ProcName(/*nAtivacao*/))
    EndIf

Return self:lSucesso


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaErrosStatus
Método que grava os erros encontrados pelo retorno da API LojaLoteRetornos nas devidas tabelas (MHL,MIP,MHR)

@param cLoja, Caractere,  código da filial distribuída pelo LojaLote do PDVSync
@param cLote, Caractere,    código do lote que foi enviado para o PDVSync
@param cProce, Caractere, Código do processo no Protheus  (TipoDado)   
@param cIdRet, Caractere, IdRetaguarda do item com erro 
@param cErro, Caractere,  Detalhamento do erro


@author  Evandro Pattaro
@Date    13/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method GravaErrosStatus(cLoja,cLote,cProce,cIdRet,cErro) Class RmiEnvPdvSyncObj

    Local aArea     := getArea()
    Local cQuery    := ""
    Local cTabela   := ""
    Local cBkpFilAnt:= cFilAnt

    Default cProce := ""
    Default cIdRet := ""

    //Se não informar o processo e o id_retaguarda ou id_retaguarda default sync, atualiza todos os registros do processo e lote
    if ( empty(cProce) .and. empty(cIdRet) ) .or. allTrim(cIdRet) == "00000000-0000-0000-0000-000000000000"

        //Retorna os registros de uma determinada filial e lote pendentes de retorno 
        cQuery := " SELECT R_E_C_N_O_"
        cQuery += " FROM " + RetSqlName("MIP")
        cQuery += " WHERE MIP_FILIAL = '" + padR(cLoja, tamSx3("MIP_FILIAL")[1]) + "'"
        cQuery +=   " AND MIP_LOTE = '" + padR(cLote, tamSx3("MIP_LOTE")[1]) + "'"
        cQuery +=   " AND MIP_STATUS = '6'"             //6=Pendente retorno
        cQuery +=   " AND MIP_CPROCE = '"+self:cProcesso+"'"
        cQuery +=   " AND D_E_L_E_T_ = ' '"

        cTabela := getNextAlias()
        cQuery  := changeQuery(cQuery)
        
        ljGrvLog("RmiEnvObj", "Query que retorna os registros de uma determinada filial e lote pendentes de retorno.", cQuery)
        dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

        while !(cTabela)->( eof() )

            MIP->( dbGoTo( (cTabela)->R_E_C_N_O_) )
            
            If !MIP->( eof() )
                cFilAnt := MIP->MIP_FILIAL
                rmiGrvLog(  "3"             , "MIP"         , MIP->( Recno() )  , "LOJALOTE"        ,;
                            cErro           , /*lRegNew*/   , /*lTxt*/          , /*cFilStatus*/    ,;
                            .F.             , /*nIndice*/   , MIP->MIP_CHVUNI   , MIP->MIP_CPROCE   ,;
                            self:cAssinante , MIP->MIP_UIDORI )
                cFilAnt := cBkpFilAnt                        
            EndIf

            (cTabela)->( dbSkip() )
        enddo
        (cTabela)->( dbCloseArea() )

    else

        MIP->( DbSetOrder(4) )  //MIP_FILIAL+MIP_CPROCE+MIP_LOTE+MIP_IDRET
        If MIP->( DbSeek(cLoja + self:cProcesso + cLote + cIdRet ) )                                                
            cFilAnt := cLoja
            RmiGrvLog( "3" , "MIP" , MIP->(Recno()) , "LOJALOTE" ,;
                            cErro ,,, "MIP_STATUS",;
                            , 4   , MIP->MIP_CHVUNI , MIP->MIP_CPROCE ,self:cAssinante , MIP->MIP_UIDORI )            
            cFilAnt := cBkpFilAnt
        EndIf

    endIf

    restArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTiposDados
Método que busca o nome do processo do envio no protheus conforme o tipo de dado retornado do PDVSYNC

@param nTipoDado, Numérico, Código do tipo de dado retornado do PDVSYNC
@param cProcesso, Caractere, Nome do Processo

@return xRetorno, Indefinido, Depende do parametro de entrada, caso entre o nTipoDado retorna o processo e se entrar o cProcesso retorna o tipo do dado

@author  Evandro Pattaro
@Date    13/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetTiposDados(nTipoDado, cProcesso) Class RmiEnvPdvSyncObj
    
    Local xRetorno  := ""
    Local nPos      := 0

    if nTipoDado == nil

        nPos := aScan(self:aTiposDados,{|x| allTrim(x[2]) == allTrim(cProcesso) })
        if nPos > 0 
            xRetorno := self:aTiposDados[nPos][1]
        endIf

    else

        nPos := aScan(Self:aTiposDados,{|x| x[1] == nTipoDado })
        If nPos > 0 
            xRetorno := self:aTiposDados[nPos][2]
        EndIf
    endIf

Return xRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} StatusLista
Método atualiza o status dos itens da lista

@author  Everson S P Junior
@Date    04/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Method StatusLista() Class RmiEnvPdvSyncObj
Local oJson         := JsonObject():New()
Local cIdRetaguada  := ""
Local nY            := 1
Local cRetorno      := ""
Local lContinua     := .T.
Local nI            := 0

LjGrvLog(" StatusLista ", "Executando função")
oJson:FromJson(self:oEnvia:CRESULT)

If oJson:hasProperty("details")
    self:lSucesso   := .F.    
    lContinua       := .F.
    LjGrvLog(" StatusLista ", "Legado nessa versão caso retorne erro todos registro na MHR e MIP ficam com 3")
EndIf

If lContinua
    If oJson:hasProperty("errors") .AND. oJson["errors"] != Nil
        aErros:= oJson["errors"]:GetNames()
        For nY := 1 To Len(aErros)
            If Valtype(oJson["errors"][aErros[nY]]) == 'J' .And. oJson["errors"][aErros[nY]]:hasProperty("IdentificadorExterno")
                cIdRetaguada := oJson["errors"][aErros[nY]]["IdentificadorExterno"][1]
                cRetorno     := oJson["errors"][aErros[nY]]:ToJson()
                LjGrvLog(" StatusLista ", "Não teve sucesso retorno => " ,{cRetorno})
                nI := aScan(self:aMhrRec,{|x| x[3] == cIdRetaguada })
                If nI > 0
                    self:aMhrRec[nI][4] := .F.
                    self:aMhrRec[nI][5] := cRetorno
                    LjGrvLog(" StatusLista ", "Esse item retornou erro => " ,{self:aMhrRec[nI]})
                EndIf    
            Else
                self:cRetorno := oJson:ToJson()// Erro de Tag obrigatoria nao enviada sem IdentificadorExterno
                self:lSucesso   := .F.
                LjGrvLog(" StatusLista ", "Retorno de Status enviado pelo Sync está fora do padrão, todos os itens ficaram com erro." ,self:cRetorno)
                Exit
            EndIf
        next
    Else
        self:cRetorno := STR0015 + self:oEnvia:CRESULT//"Propriedade 'errors' está com uma estrutura inválida Verifique ->"
        self:lSucesso   := .F.
        LjGrvLog(" StatusLista ", "Verifique o retorno junto a equipe do SyncServer => " ,{self:cRetorno})
    EndIf
EndIf

FwFreeObj(oJson)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} precedencia
Metodo para tratamento de precedencia

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method precedencia() Class RmiEnvPdvSyncObj

    Local aArea         := getArea()
    Local aPrecedencia  := {}
    Local cPrecedencia  := ""
    Local lPrecedencia  := .F.
    Local nCont         := 0
    Local cSql          := ""
    Local cProcesso     := ""
    Local nTamSx3       := tamSx3("MHQ_CPROCE")[1]
    Local cTabela       := ""

    if self:lSucesso .and. self:oLayoutEnv:hasProperty("configPSH") .and. self:oLayoutEnv["configPSH"]:hasProperty("cargaInicial") .and. self:oLayoutEnv["configPSH"]["cargaInicial"]

        cProcesso := allTrim(self:cProcesso)

        if !(cProcesso $ "CADASTRO LOJA|COMPARTILHAMENT")
            aAdd(aPrecedencia, "CADASTRO LOJA"   )
            aAdd(aPrecedencia, "COMPARTILHAMENT" )
        endIf

        do case
            case cProcesso == "PRODUTO"
                aAdd(aPrecedencia, "ICMS"       )
                aAdd(aPrecedencia, "PIS/COFINS" )
                aAdd(aPrecedencia, "NCM"        )

            case cProcesso == "PRECO"
                aAdd(aPrecedencia, "ICMS"       )
                aAdd(aPrecedencia, "PIS/COFINS" )
                aAdd(aPrecedencia, "NCM"        )
                aAdd(aPrecedencia, "PRODUTO"    )

            case cProcesso == "SALDO ESTOQUE"
                aAdd(aPrecedencia, "ICMS"       )
                aAdd(aPrecedencia, "PIS/COFINS" )
                aAdd(aPrecedencia, "NCM"        )
                aAdd(aPrecedencia, "PRODUTO"    )

            case cProcesso == "OPERADOR LOJA"
                aAdd(aPrecedencia, "PERFIL OPERADOR")

            case cProcesso == "FORMA PAGAMENTO"
                aAdd(aPrecedencia, "ADMINISTRADORA" )
                aAdd(aPrecedencia, "CONDICAO PAGTO" )
                aAdd(aPrecedencia, "COMPL PAGAMENTO")
        end case

        //Verifica se o processo tem precedencia
        if len(aPrecedencia) > 0

            for nCont:=1 to len(aPrecedencia)
                cPrecedencia += "'" + padR(aPrecedencia[nCont], nTamSx3) + "',"
            next nCont
            cPrecedencia := subStr(cPrecedencia, 1, len(cPrecedencia) - 1)

            cSql := " SELECT SUM(QTD) AS 'TOTAL' FROM ("
            cSql +=         " SELECT COUNT(1) AS 'QTD' FROM " + retSqlName("MHQ") 
            cSql +=         " WHERE D_E_L_E_T_ = ' ' AND MHQ_FILIAL = '" + xFilial("MHQ") + "' AND MHQ_CPROCE IN (" + cPrecedencia + ") AND MHQ_ORIGEM <> '" + self:cAssinante + "' AND MHQ_STATUS = '1'"
            cSql +=     " UNION"
            cSql +=         " SELECT COUNT(1) AS 'QTD' FROM " + retSqlName("MHR")
            cSql +=         " WHERE D_E_L_E_T_ = ' ' AND MHR_FILIAL = '" + xFilial("MHR") + "' AND MHR_CPROCE IN (" + cPrecedencia + ") AND MHR_CASSIN = '" + self:cAssinante + "' AND MHR_STATUS = '1'"
            cSql += ") PENDENTES"

            ljGrvLog("RmiEnvPdvSyncObj", "Verificando precedência da carga inicial processo e query executada:", {cProcesso, cSql})
            cTabela := getNextAlias()
            dbUseArea(.T., "TOPCONN", tcGenQry( , , cSql), cTabela, .T., .F.)        

            if !(cTabela)->( Eof() ) .and. (cTabela)->TOTAL > 0
                lPrecedencia := .T.
                ljxjMsgErr( i18n("O processo de #1 não será enviado neste momento, porque existe precedência(s) de #2.", {cProcesso, cPrecedencia}), /*cSolucao*/, /*cRotina*/, (cTabela)->TOTAL)
            endIf

            (cTabela)->( dbCloseArea() )
        endIf

        //Quando não existir precedencia pela 1ª vez desativa a carga inicial
        if !lPrecedencia
            self:oLayoutEnv["configPSH"]["cargaInicial"] := .F.
            
            MHP->( DbSetOrder(1) )  //MHP_FILIAL + MHP_CASSIN + MHP_CPROCE + MHP_TIPO
            If MHP->( DbSeek( xFilial("MHP") + self:cAssinante + self:cProcesso + self:cTipo ) )
                recLock("MHP", .F.)
                    MHP->MHP_LAYENV := self:oLayoutEnv:toJson()
                MHP->( msUnLock() )

                ljGrvLog("RmiEnvPdvSyncObj", "Desativando precedência da carga inicial.", {self:cAssinante, self:cProcesso, self:cTipo, MHP->MHP_LAYENV})
            endIf
        endIf
    endIf

    restArea(aArea)

Return lPrecedencia

//-------------------------------------------------------------------
/*/{Protheus.doc} getHeader
Metodo para carregar o header

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method getHeader() Class RmiEnvPdvSyncObj

    Local aAux := {}

    //Carrega dados header utiliza nas APIs - autenticação
    If (aAux := self:oPdvSync:Token())[1]
        self:aHeader := self:oPdvSync:getHeader()
    else
        self:lSucesso := aAux[1]
        self:cRetorno := aAux[2]
    EndIf
    fwFreeArray(aAux)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecLojaLote
Valida se pode executar a consulta dos status dos envios detalhados por loja/lote (MIP)

@author  Evandro Pattaro
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method ExecLojaLote() Class RmiEnvPdvSyncObj
    
    Local aArea := GetArea()
    Local lRet  := .T.
    Local lLayOk := .T.
    Local cCadMIH := "PSH"
    Local aConfig := {}
    Local oJson     := Nil

    MIG->( dbSetOrder(1) )  //MIG_FILIAL, MIG_TIPCAD, R_E_C_N_O_, D_E_L_E_T_
    if !MIG->( dbSeek( xFilial("MIG") + cCadMIH) )
        lLayOk := .F.
        ljCadAuxVd()
    Else    
        oJson := JsonObject():New()
        oJson:FromJson(MIG->MIG_LAYOUT)
        If oJson:hasProperty("LayoutVersion") .and. oJson["LayoutVersion"] < 2
            lLayOk := .F.
            ljCadAuxVd()
        EndIf                
    endIf

    if lLayOk

        MIH->( dbSetOrder(1) )  //MIH_FILIAL, MIH_TIPCAD, MIH_ID, R_E_C_N_O_, D_E_L_E_T_
        if !MIH->( dbSeek( xFilial("MIH") + cCadMIH) )

            lRet := PshGrvCad(cCadMIH, MODEL_OPERATION_INSERT,{ ;
                        { "MIHMASTER", "MIH_DESC", "CONFIGURACAO" }, ;
                        { "MIHDETAIL", "horaLojaLote",Time() }, ;
                        { "MIHDETAIL", "tempoConsultaLojaLote", 30 } ;
                    })

            if lRet
                MIH->( dbSeek( xFilial("MIH") + cCadMIH) )
            endIf
        endIf

        if lRet

            aConfig := PshListCad(cCadMIH,{"horaLojaLote","tempoConsultaLojaLote"})

            If Empty(aConfig[1][1]) .Or. ElapTime(aConfig[1][1],Time()) > "00:"+Padl(cValToChar(aConfig[1][2]),2,"0")+":00"
                lRet := PshGrvCad(cCadMIH, MODEL_OPERATION_UPDATE,{ ;
                            { "MIHMASTER", "MIH_DESC", "CONFIGURACAO" }, ;
                            { "MIHDETAIL", "horaLojaLote",Time() };
                        })
            Else 
                lRet := .F.                 
                LjGrvLog(" RmiEnvPdvSyncObj ", i18n(STR0018, {cValToChar(aConfig[1][2])})) //"A hora da última execução do LojaLote é menor que o intervalo configurado. Intervalo configurado: #1 minutos"
            EndIf        

        endIf
    endIf

    fwFreeObj(oJson)
    RestArea(aArea)

Return lRet 
