#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "RMIENVPDVSYNCOBJ.CH"
#INCLUDE "FWMVCDEF.CH"

Static cStTamDtFe   := space( tamSx3("MIK_DTFECH")[1] )
Static cStTamHrFe   := space( tamSx3("MIK_HRFECH")[1] )

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
    Data aLojasProprietario     as Array        //Lojas atreladas a um determinado proprietario
    Data cProprietario          as Character    //ID do proprietario
    Data oLojasProp             as Object       //Objeto tHashMap para armazenar as lojas do idProprietario e evitar consultas repetidas
    Data lStatusBx              as Logical      //Indica se a tabela MIK possui o campo de status para controle de baixa (MIK_STATBX)

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

    Method Consulta()                   //Consulta as publicações disponiveis para o envio para um determinado processo com base nos LOTE's abertos
    Method Processa()                   //Metodo que ira controlar o processamento dos envios em lista

    Method EnviaIP()                      //Envia para a engenharia a informação de IP externo para atualização de IP do servidor (referente ao fluxo online)    

    Method StatusLista()                //Atualiza o Status MHR por item da Lista.

    Method precedencia()                //Metodo para tratamento de precedencia

    Method getHeader()                  //Metodo para carregar o header enviado em cada requisição (token)
    Method ultimoProc()              //Verifica se é o último processo do lote para fechar o lote no PDVSync

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
        self:nMaxPorLote        := IIF( self:oConfAssin:hasProperty("qtdMaxPorLote"), self:oConfAssin["qtdMaxPorLote"], 1000 )
        self:nQtdList           := 100
        self:aLojasProprietario := {}
        self:cProprietario      := ""
        self:oLojasProp         := tHashMap():New()
        self:lStatusBx          := MIK->( columnPos("MIK_STATBX") ) > 0

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

        self:GetProcessos()

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
    cQuery += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "'"
    cQuery +=       " AND MHP_CASSIN = '" + self:cAssinante + "'"
    cQuery +=       " AND MHP_TIPO = '1'"   //1=Envio
    cQuery +=       " AND MHP_ATIVO = '1'"  //1=Sim
    cQuery +=       " AND D_E_L_E_T_ = ' '"

    ljGrvLog(/*cNumControl*/, "Antes da consulta que retorna os processos de envio ativos para abertura de lote.", cQuery)
    cTabela := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)

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
    Local cSql  := ""
    Local aSql  := {}
    Local nCont := 0
    Local oJson := jsonObject():new()
    Local cJson := ""
    Local nProce := 0

    //Carrega os processos enviados no lote
    cSql := " SELECT DISTINCT MHR_CPROCE"
    cSql += " FROM " + retSqlName("MHR")
    cSql += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
    cSql +=     " AND MHR_LOTE = '" + self:cLote + "'"
    cSql +=     " AND D_E_L_E_T_ = ' '"

    ljGrvLog(/*cNumControl*/, "Antes de consultar os processos enviados no lote.", cSql)
    tcSqlToArr(cSql, @aSql, /*aBinds*/, /*aSetFields*/, /*aQryStru*/)

    //Carrega tipos do lotes para enviar ao fechamento do lote
    oJson["tipolote"] := {}
    If Len(self:aProcessos) > 0
        for nCont:=1 to len(aSql)
            nProce := aScan(self:aProcessos, {|x| Alltrim(x[1]) == Alltrim(aSql[nCont][1])})
            aAdd( oJson["tipolote"], self:aProcessos[nProce][2] )
        next nCont
    EndIf
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

    Local cSemaforo := "FECHALOTE" //Semáforo para controle de concorrência
    Local cSql      := ""

    If LockByName(cSemaforo)

        cSql := " UPDATE " + retSqlName("MIK") 
        cSql +=     " SET MIK_DTFECH = '" + dToS( date() ) + "', MIK_HRFECH = '" + time() + "'"

        if self:lStatusBx
            cSql += ", MIK_STATBX = '1'"    //1=Pendente baixa
        endIf

        cSql += " WHERE MIK_FILIAL = '" + xFilial("MIK") + "'"
        cSql +=     " AND MIK_LOTE = '" + Self:cLote + "'"            
        cSql +=     " AND MIK_CPROCE = '" + Self:cProcesso + "'"
        cSql +=     " AND MIK_DTFECH = '" + cStTamDtFe + "'"
        cSql +=     " AND MIK_HRFECH = '" + cStTamHrFe + "'"
        cSql +=     " AND D_E_L_E_T_ = ' '"

        ljGrvLog(/*cNumControl*/, "Antes de gravar o fechamento do lote.", {Self:cLote, Self:cProcesso, cSql})
        tcSqlExec(cSql)

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

    Local cQuery    := ""   //Armazena a query
    Local cAlias1   := ""   //Proximo alias disponivel
    Local lExiste   := .F.  //Se existe ou nao um lote já aberto
       
    cQuery := " SELECT MIK_LOTE "
    cQuery += " FROM " + RetSqlName("MIK")
    cQuery += " WHERE MIK_FILIAL = '" + xFilial("MIK") + "'"
    cQuery +=   " AND MIK_DTFECH = '" + cStTamDtFe + "'"
    
    if !Empty(cProcesso)
        cQuery += " AND MIK_CPROCE = '" + cProcesso + "'"
    endIf

    cQuery +=   " AND D_E_L_E_T_ = ' '"

    ljGrvLog(/*cNumControl*/, "Antes da consulta que retorna o lote aberto.", cQuery)
    cAlias1 := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)

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

        self:GrvFechamento()
    
        If self:ultimoProc()
            Self:EnviaFechaLote()
        EndIf
        
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
    Local cQuery    := ""           //Query de processos pendentes
    Local cAliasMik := ""           //Proximo alias disponivel
    Local cAliasMhr := ""           //Proximo alias disponivel
    Local lRet      := .F.          //Variavel de retorno

    cQuery := " SELECT MIK_CPROCE, MIK_LOTE"
    cQuery += " FROM " + RetSqlName("MIK")
    cQuery += " WHERE MIK_FILIAL = '" + xFilial("MIK") + "'"

    If !Empty(Self:cLote)
        cQuery += " AND MIK_LOTE = '" + Self:cLote + "'"
    Else
        cQuery += " AND MIK_DTFECH = '" + cStTamDtFe + "'"
        cQuery += " AND MIK_CPROCE = '" + Self:cProcesso + "'"
    EndIf

    cQuery += " AND D_E_L_E_T_ = ' '"

    ljGrvLog(/*cNumControl*/, "Antes da consulta que retorna o lote aberto.", cQuery)
    cAliasMik := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)

    If !(cAliasMik)->( Eof() )

        If Empty(Self:cLote)
            Self:cLote := AllTrim((cAliasMik)->MIK_LOTE)
        EndIf

        //Consulta quantidade de registros enviados para o lote
        cQuery := " SELECT COUNT(1) REGISTROS_ENVIADOS"
        cQuery += " FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
        cQuery +=   " AND MHR_CASSIN = '" + self:cAssinante + "'"
        cQuery +=   " AND MHR_LOTE = '" + Self:cLote + "'"
        cQuery +=   " AND MHR_STATUS > '1'"
        cQuery +=   " AND D_E_L_E_T_ = ' '"

        ljGrvLog(/*cNumControl*/, "Antes da consulta que retorna a quantidade de registros enviados para o lote.", cQuery)
        cAliasMhr := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)
        
        nRecEnviados := (cAliasMhr)->REGISTROS_ENVIADOS
        
        (cAliasMhr)->( DbCloseArea() )

        If nRecEnviados >= Self:nMaxPorLote
            lRet := .F. 
            LjGrvLog(" RmiEnvPdvSyncObj ", "LOTE  [" + Self:cLote + "] sera fechado pois execedeu o limite de: " + cValToChar(Self:nMaxPorLote) + " envios por LOTE")
        Else

            //Consulta quantidade de registros pendentes de envio por processo e assinante
            cQuery := " SELECT COUNT(1) REGISTROS_PENDENTE"
            cQuery += " FROM " + RetSqlName("MHR") + " MHR INNER JOIN " + RetSqlName("MHQ") + " MHQ"
            cQuery +=   " ON MHR_FILIAL = MHQ_FILIAL AND MHR_UIDMHQ = MHQ_UUID AND MHQ.D_E_L_E_T_ = ' '"
            cQuery += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
            cQuery +=   " AND MHR_CPROCE = '" + self:cProcesso + "'"
            cQuery +=   " AND MHR_CASSIN = '" + self:cAssinante + "'"
            cQuery +=   " AND MHR_STATUS = '1'"
            cQuery +=   " AND MHR.D_E_L_E_T_ = ' '"

            ljGrvLog(/*cNumControl*/, "Antes da consulta de quantidades de registros pendentes de envio por processo e assinante.", cQuery)
            cAliasMhr := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)

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
Method Consulta(lReenvio) Class RmiEnvPdvSyncObj

    Local nQtdReenvio   := 0
    Local cUpdate       := ""
    Local cWhere        := ""

    Default lReenvio    := .F.  //Define se é para consultar os registros com erro para reenvio

    if !self:precedencia()

        // -- Se tiver LOTE em aberto para o processo atual faço a consulta. 
        If Self:GetLote(Self:cProcesso) .OR. !Self:GetLote()

            //Campos que serão retornados na consulta
            self:cQuery := "SELECT "
            self:cQuery +=     " MHR.R_E_C_N_O_ AS RECNO_DIS,"
            self:cQuery +=     " MHQ.R_E_C_N_O_ AS RECNO_PUB" 

            //Consulta de reprocessamentos
            if lReenvio

                if self:oConfProce:hasProperty("qtdereenvio")
                    nQtdReenvio := len(self:oConfProce["qtdereenvio"])
                endIf

                self:cQuery += " FROM " + RetSqlName("MIP") + " MIP"
                
                self:cQuery += " INNER JOIN " + RetSqlName("MHR") + " MHR"
                self:cQuery +=      " ON"
                self:cQuery +=              " MHR.MHR_FILIAL = '" + xFilial("MHR") + "'"
                self:cQuery +=          " AND MHR.MHR_UIDMHQ = MIP.MIP_UIDORI"
                self:cQuery +=          " AND MHR.MHR_CPROCE = '" + self:cProcesso + "'"
                self:cQuery +=          " AND MHR.MHR_CASSIN = '" + self:cAssinante + "'"
                self:cQuery +=          " AND MHR.D_E_L_E_T_ = ' '"
                
                self:cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ"
                self:cQuery +=      " ON"
                self:cQuery +=              " MHQ.MHQ_FILIAL = '" + xFilial("MHQ") + "'"
                self:cQuery +=          " AND MHQ.MHQ_UUID = MHR.MHR_UIDMHQ"
                self:cQuery +=          " AND MHQ.D_E_L_E_T_ = ' '"
                
                self:cQuery += " WHERE MIP.MIP_CPROCE = '" + self:cProcesso + "'"
                self:cQuery +=      " AND MIP.MIP_STATUS = '3'"                                  //1=A processar, 2=Processado, 3=Erro
                self:cQuery +=      " AND MIP.MIP_TENTAT <= '" + cValtoChar(nQtdReenvio) + "'"   //Quantidade de tentativas limitada a quantidade configurada no processo
                self:cQuery +=      " AND MIP.MIP_DATPRO >= '" + dToS(dDataBase - 7) + "'"       //Reprocessamento limitado aos ultimos 7 dias
                self:cQuery +=      " AND MIP.D_E_L_E_T_ = ' '"

            //Consulta de novos envios
            else

                //Carrega where para consulta e update
                cWhere := " WHERE MHR.MHR_FILIAL = '" + xFilial("MHR") + "'"
                cWhere +=      " AND MHR.MHR_CPROCE = '" + self:cProcesso + "'"
                cWhere +=      " AND MHR.MHR_CASSIN = '" + self:cAssinante + "'"
                cWhere +=      " AND MHR.MHR_STATUS = '1'"  //1=A processar, 2=Processado, 3=Erro
                cWhere +=      " AND MHR.D_E_L_E_T_ = ' '"

                //Update para manter apenas o registro mais recente de cada MHR_IDRET não enviado, os outros registros com o mesmo MHR_IDRET serão marcados como duplicados (MHR_STATUS = 'D') e não serão enviados
                /*  REVER ESTE TRECHO PORQUE O CAMPO MHR_IDRET SÓ É ATUALIZADO APÓS O ENVIO PARA O PDV SYNC, ENTÃO TODOS OS REGISTROS VÃO TER O MESMO MHR_IDRET ATÉ O PRIMEIRO ENVIO SER REALIZADO
                
                    cUpdate := " UPDATE " + RetSqlName("MHR")
                    cUpdate += " SET MHR_STATUS = 'D', MHR_DATPRO = '" + dToS( date() ) + "', MHR_HORPRO = '" + time() + "'"        //D=Duplicado
                    cUpdate += " WHERE R_E_C_N_O_ IN ("
                    cUpdate +=      " SELECT R_E_C_N_O_"
                    cUpdate +=      " FROM ("
                    cUpdate +=              " SELECT R_E_C_N_O_,"
                    cUpdate +=              " ROW_NUMBER() OVER (PARTITION BY MHR_IDRET ORDER BY R_E_C_N_O_ DESC) AS ORDEM_REGISTRO"
                    cUpdate +=              " FROM " + RetSqlName("MHR") + " MHR"
                    cUpdate +=              cWhere
                    cUpdate +=      " ) REGISTROS_DUPLICADOS"
                    cUpdate +=      " WHERE ORDEM_REGISTRO > 1"
                    cUpdate += " )"

                    ljGrvLog(//cNumControl//, "Antes do update que mantem apenas o registro mais recente de cada MHR_IDRET.", cUpdate)
                    tcSqlExec(cUpdate)
                */

                //Carrega consulta de registros pendentes de envio
                self:cQuery += " FROM " + RetSqlName("MHR") + " MHR"

                self:cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ"
                self:cQuery +=      " ON"
                self:cQuery +=             " MHQ.MHQ_FILIAL = '" + xFilial("MHQ") + "'"
                self:cQuery +=         " AND MHQ.MHQ_UUID = MHR.MHR_UIDMHQ"
                self:cQuery +=         " AND MHQ.D_E_L_E_T_ = ' '"

                self:cQuery += cWhere
            endIf

            //Limita a quantidade de retorno
            self:cQuery += " ORDER BY MHR.R_E_C_N_O_"
            self:cQuery +=      " OFFSET 0 ROWS"
            self:cQuery +=      " FETCH NEXT " + cValToChar(self:nTamQuery) + " ROWS ONLY"            

            if !empty(self:cAliasQuery) .and. select(self:cAliasQuery) > 0
                (self:cAliasQuery)->( dbCloseArea() )
                self:cAliasQuery := ""
            endIf

            ljGrvLog(/*cNumControl*/, "Antes da consulta dos registros que serão enviados.", {lReenvio, self:cQuery})
            self:cAliasQuery := mpSysOpenQuery(self:cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)
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

        if self:oConfProce:hasProperty("qtdEnvio")
            self:nQtdList := self:oConfProce["qtdEnvio"]
        endIf
    EndIf
    

    If self:lSucesso .And. !Empty(self:cAliasQuery)

        While !(self:cAliasQuery)->( Eof() )

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
                    Aadd(self:aMhrRec[Len(self:aMhrRec)], (self:cAliasQuery)->RECNO_DIS )   //aMhrRec[n][1] = RECNO do MHR
                    Aadd(self:aMhrRec[Len(self:aMhrRec)], self:cBody                    )   //aMhrRec[n][2] = Body do registro montado para envio
                    Aadd(self:aMhrRec[Len(self:aMhrRec)], Self:cIdRetaguarda            )   //aMhrRec[n][3] = IdRetaguarda do registro enviado
                    Aadd(self:aMhrRec[Len(self:aMhrRec)], self:lSucesso                 )   //aMhrRec[n][4] = Define se o envio foi com sucesso ou não
                    Aadd(self:aMhrRec[Len(self:aMhrRec)], self:cRetorno                 )   //aMhrRec[n][5] = Retorno recebido
                    
                    //aMhrRec[n][6] = MD5 exclusivo do registro
                    //aMhrRec[n][7] = Define se o registro foi enviado como duplicado
                    If lCtrlMd5
                        Aadd(self:aMhrRec[Len(self:aMhrRec)],Self:cMD5)
                        Aadd(self:aMhrRec[Len(self:aMhrRec)],Self:lEnvDuplic)
                    else
                        Aadd(self:aMhrRec[Len(self:aMhrRec)], "" )
                        Aadd(self:aMhrRec[Len(self:aMhrRec)], .F.)
                    EndIf 

                    //aMhrRec[n][8] = idProprietario
                    if self:oBody:hasProperty("idProprietario")
                        Aadd(self:aMhrRec[Len(self:aMhrRec)], self:oBody["idProprietario"])
                    else
                        Aadd(self:aMhrRec[Len(self:aMhrRec)], "")
                    endIf

                    Aadd(self:aMhrRec[Len(self:aMhrRec)], self:cIdExt)  //aMhrRec[n][9] = IdExt do registro enviado MHQ_IDEXT

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

            ljGrvLog(/*cNumControl*/, "Inicia atualização de MHR\MHL, para os registros:", self:aMhrRec)            
            Begin Transaction

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

                    self:cProprietario := self:aMhrRec[nX][8]   //idProprietario
                    self:cIdExt        := self:aMhrRec[nX][9]   //IdExt do registro enviado MHQ_IDEXT

                    self:cRetorno := IIF(!Empty(self:aMhrRec[nX][5]),self:aMhrRec[nX][5],self:cRetorno)// Gravar o motivo do erro
                    If !MHR->(Eof())                        
                        self:Grava()
                    EndIf
                Next nX

            End Transaction

            LjGrvLog("RmiEnvPdvSyncObj", "Executa PosExecucao ")
            self:PosExecucao()
            self:aMhrRec := {}
            self:cBodyList := ""
            self:lSucesso  := .T. 


            If (self:cAliasQuery)->( Eof() )
                self:Consulta()

                //Chama reprocessamento, caso não tenha mais registros novos para enviar
                if (self:cAliasQuery)->( Eof() )
                    self:Consulta(.T.)
                endIf
            Endif              
        EndDo

        (self:cAliasQuery)->( DbCloseArea() )

        self:PosExecucao()  //caso o lote estiver aberto fechar.
    EndIf

    RestArea(aAreaMHQ)

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
        If Len(aErros) > 0
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
            self:cRetorno := oJson:ToJson()// Array de erros vazio
            self:lSucesso   := .F.
            LjGrvLog(" StatusLista ", "Retorno de Status enviado pelo Sync está fora do padrão, todos os itens ficaram com erro." ,self:cRetorno)
        EndIf
    Else
        self:cRetorno := STR0015 + IIF( ValType(self:oEnvia:CRESULT) == "C", self:oEnvia:CRESULT, "Detalhe do erro não retornado: " + oJson:toJson() )  //"Propriedade 'errors' está com uma estrutura inválida Verifique ->"
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
/*/{Protheus.doc} UltimoProc
Verifico se é o ultimo processo a utilizar o lote em questão

@author  Evandro Pattaro
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Method ultimoProc() Class RmiEnvPdvSyncObj

    Local lRet  := .F.
    Local cQuery:= ""
    Local aSql  := {}

    cQuery := "	SELECT COUNT(1) REG "
    cQuery += " FROM " + RetSqlName("MIK")
    cQuery += "	WHERE MIK_FILIAL = '" + xFilial("MIK") + "'"
    cQuery += " AND MIK_LOTE = '" + Self:cLote + "'"
    cQuery += "	AND MIK_DTFECH = '" + cStTamDtFe + "'"
    cQuery += "	AND MIK_HRFECH = '" + cStTamHrFe + "'"
    cQuery += "	AND D_E_L_E_T_ = ' '"

    aSql := RmiXSql(cQuery, "*", /*lCommit*/, /*aReplace*/)

    If Len(aSql) > 0 .And. aSql[1][1] == 0
        lRet := .T.
    EndIf

Return lRet
