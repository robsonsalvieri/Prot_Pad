#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "RMIPUBLICA.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static cStFonte     := "RMIPUBLICA"             //Constante para o nome do log
Static oError       := Nil                      //Objeto que recebe a exceção que ocorreu na execução da query
Static oEnviaObj    := Nil                      //Objeto para execução do metodo SetArrayFil
Static aMINAux      := Array(7)                 //Array auxiliar da Tabela MIN
Static aStStructs   := {}                       //Array com a extrutura das tabelas já autilizadas
Static aStTemSta    := {}                       //Array que define as tabelas que tem o campo S_T_A_M_P_
Static oStBulk      := nil                      //Objeto fwBulk
Static nStTamBulk   := 1000                     //Tamanho do commit no Bulk
Static nStTamQry    := 10000                    //Tamanho de retorno da query
Static aStDados     := {}                        //Array que recebe os dados da tabela a ser enviada
Static oEnvio       := Nil                      //Objeto que recebe a instancia da classe RmiEnviaObj conforme assinante
Static lGeraMHQ     := .F.                      //Variavel que define se deve ou não gerar a MHQ

Static aStProcesso  := {}                       //Array que recebe as propriedades do processo que será publicado
Static cStProcesso  := ""                       //Variavel que recebe o processo que deve ser publicado
Static oStCmpsEnv   := nil                      //Objeto tHashMap para armazenar os campos enviados e evitar consultas repetidas
Static oStRelMih    := nil                      //Objeto tHashMap para armazenar o conteudo da MIH e evitar consultas repetidas
Static lStCargaIni  := .F.                      //Define se o processo de carga inicial esta disponivel

Static cStBanco     := ""                      //Define se o banco de dados esta disponivel

//Definições do array aProcesso\aStProcesso
#DEFINE MHNCOD              1
#DEFINE MHNTABELA           2
#DEFINE MHSTABSECUNDARIAS   3
#DEFINE MHNFILTRO           4
#DEFINE MHPCASSIN           5
#DEFINE MHNSECOBG           6
#DEFINE MHSTIPO             7
#DEFINE MHNCHAVE            8
#DEFINE MHPFILPRO           9
#DEFINE MHNCODGRP           10

//Definições do array aProcesso posição MHSTABSECUNDARIAS
#DEFINE MHSTABELA           1
#DEFINE MHSCHAVE            2
#DEFINE MHNCHAVE_PRINCIPAL  3
#DEFINE MHSFILTRO           4
#DEFINE MHSCONPUB           5
#DEFINE MHSTIPO             6

//Definições do retorno da função ultPublica
#DEFINE MINCPROCE   1
#DEFINE MINFILPUB   2
#DEFINE MINULTPUB   3

//Definições do array aMINAux
#DEFINE MINLJDEST 7

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPublica
Serviços que gera as Publicações

@type    function
@param 	 cEmpImp, Caractere, Empresa de publicação
@param 	 cFilImp, Caractere, Filial de publicação
@param 	 cPubNova, Caractere, Define se o novo controle de publicação (pelo S_T_A_M_P_) esta ativo 0=Não, 1-Sim 
@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIPublica(cEmpImp, cFilImp, cPubNova, cTempoMax, cTipo, cFiltro)
    
    Local lManual       := (cEmpImp == Nil .Or. cFilImp == Nil)
	Local lContinua     := IIF(lManual, .T., .F.)
    Local cSemaforo     := cStFonte
    Local cHoraInicio   := time()
    Local cTabela       := ""
    Local cSql          := ""

    Default cPubNova    := "0"
    Default cTempoMax   := "00:05:00"
    Default cTipo       := "1"  //1=Processo, 2=Grupo
    Default cFiltro     := ""   //Código do processo ou grupo

    //Limita a 15m para a thread não ficar muito tempo sem desativar e limpar a memoria
    if cTempoMax > "00:15:00"
        cTempoMax := "00:15:00"
    endIf

    If !lManual

        //Alterado para RPCSetType(3) para não consumir licença
        RpcSetType(3) 
        If RpcSetEnv(cEmpImp, cFilImp, , , "LOJA", cSemaforo)
            lContinua := .T.
        EndIf
	EndIf

    //Verifica se o Job está dentro dos parâmetros do cadastro auxiliar de CONFIGURACAO (MIH)
    //Quando o filtro for passado não faz esta verificação porque deve haver mais de 1 job de publicação configurado, um para cada processo ou grupo.
    If empty(cFiltro) .and. existFunc("pshChkJob")
        lContinua := PSHChkJob()
    EndIf

	If lContinua

        LjGrvLog(cSemaforo, "Ambiente iniciado:", {cEmpImp, cFilImp, cPubNova, cTempoMax, cModulo, cTipo, cFiltro}) 

        //Valida a regra de compartilhamento da MIN quando controle de publicação pelo S_T_A_M_P_
        if cPubNova == "1" .and. ( fwModeAccess("MIN", 1) <> "C" .or. fwModeAccess("MIN", 2) <> "C" .or. fwModeAccess("MIN", 3) <> "C" )
            ljxjMsgErr(STR0006)     //"Regra de compartilhamento da tabela MIN incorreta, deve ser totalmente compartilhada."
            rpcClearEnv()
            return Nil
        endIf

    	//Trava a execução para evitar que mais de uma sessão ao mesmo tempo
        cSemaforo := cStFonte +"_"+ cTipo  +"_"+ cFiltro
		If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
            LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
            rpcClearEnv()
            Return Nil
		EndIf

        //Atualiza nivel de compatibilidade do banco, observações:
        //- Essa mudança geralmente é segura e recomendada pela TOTVS para versões recentes do ERP.
        //- Para ambientes Protheus alterar o COMPATIBILITY_LEVEL para 130+ é totalmente homologado pela TOTVS para instalações modernas do SQL Server e melhora inclusive a performance do estimador de cardinalidade do banco.
        if allTrim( upper( tcGetDB() ) ) == "MSSQL"

            cSql := "SELECT name, compatibility_level FROM sys.databases WHERE name = DB_NAME()"

            ljGrvLog(/*cNumControl*/, "Consulta que retorna nivel de compatibilidade do banco de dados:", cSql)
            cTabela := mpSysOpenQuery(cSql, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)

            if !(cTabela)->( eof() ) .and. (cTabela)->compatibility_level < 130

                cSql := "ALTER DATABASE " + allTrim( (cTabela)->name ) + " SET COMPATIBILITY_LEVEL = 130"

                ljGrvLog(/*cNumControl*/, "Atualiza nivel de compatibilidade do banco, para utilizar a função OPENJSON:", cSql)
                iif( tcSqlExec(cSql) < 0, ljxjMsgErr("Não foi possível atualizar nivel de compatibilidade: " + tcSqlError(), /*Solucao*/, cStFonte), nil )
            endIf

            (cTabela)->( dbCloseArea() )
        endIf

        //Thread é encerrada quando, estiver sendo executada a mais tempo que o tempo maximo
        while elapTime(cHoraInicio, time()) <= cTempoMax

            //Novo controle de publicação pelo S_T_A_M_P_
            If cPubNova == "1"
                SHPPrePub(cTipo, cFiltro)
            Else
                RmiPrePub()
            EndIf

            sleep(5000)
        endDo

        //Libera semaforo de controle
        UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    EndIf

    fwFreeArray(aStStructs)
    fwFreeArray(aStTemSta)
    fwFreeArray(aStDados)

    rpcClearEnv()

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} RmiPrePub
Função responsavel por buscar os processo que devem gerar publicação considerando as filiais cadastradas

@author  Rafael Tenorio da Costa
@since 	 26/09/19
@version P12.1.17
/*/
//-----------------------------------------------------------------------
Function RmiPrePub()
	
    Local aTable := {}   //Array que ira receber a tabela principal (MHN) e os filhos da tabela (MHS)
    Local nX     := 0    //Variavel de loop

    //Retorna os processos que serão publicados
    aTable := RmiProPub()

    For nX := 1 To Len(aTable)
        StartJob("RmiPubSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aTable[nX] )        
        Sleep(5000)
    Next nX

    LjGrvLog(" RmiPrePub ","Fim do Processamento" )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubSel
Seleciona os registros que serão publicados

@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubSel(cEmpPub, cFilPub, aProcesso)

    Local cSemaforo := cEmpPub + cFilPub + aProcesso[1]      
    Local cSelect   := ""
    Local cSelectCab:= ""
    Local cWhereCab := ""
    Local cWhere    := ""
    Local cOrder    := ""
    Local cTabela   := ""
    Local cDB       := ""
    Local cPrefixo  := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
    Local cCmpExp   := cPrefixo + "_MSEXP"
    Local nFil      := 0
    Local cFilter   := ""

    lGeraMHQ := .T. 

    If aProcesso[5] <> "TERCEIROS"
        RpcSetType(3) // Para não consumir licenças na Threads
    EndIF

    RpcSetEnv(cEmpPub, cFilPub, , ,"LOJ" , "RMIPUBSEL")

    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        Return Nil
    EndIf

    LjGrvLog("RMIPUBSEL", "Serviço iniciado:", {cEmpPub, cFilPub, aProcesso})  

    cDB := TcGetDB()
    LjGrvLog("RMIPUBSEL", "Conectado com banco de dados:", cDB)
    
    IIF(cDB == "MSSQL",cSelectCab := "SELECT TOP(50) R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "" ,"")
    
    IIF(cDB == "ORACLE",cSelectCab := " SELECT R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "","")
    IIF(cDB == "ORACLE",cWhereCab  := " AND ROWNUM <= 50 " ,"")
    
    IIF(cDB <> "ORACLE" .AND. cDB <> "MSSQL" ,cSelectCab := " SELECT R_E_C_N_O_ AS REGISTRO FROM " + RetSqlName(aProcesso[2]) + "" ,"")
    IIF(cDB <> "ORACLE" .AND. cDB <> "MSSQL" ,cOrder  := " LIMIT 50 " ,"")

    LjGrvLog(" RmiPublica ", "Job RMIPUBSEL iniciado  ")  
    LjGrvLog(" RMIPUBSEL ", "Processo:   ",aProcesso)  
   
    //Valida existencia do campo de controle de exportação
    If (aProcesso[2])->( ColumnPos(cCmpExp) ) == 0
        LjGrvLog(" RMIPUBSEL ",I18n(STR0003, {cCmpExp}))     //"Campo #1 não existe, o serviço de publicação não será executado."
    Else

        //Carrega staticas
        carStaticas(aProcesso)

        //Inicia gravação do fwBulk
        iniciaBulk()

        //Seleciona os registros que serão publicados inclui tambem os deletados
        cTabela := GetNextAlias()

        MHP->( DbSetOrder(1) )  //MHP_FILIAL + MHP_CASSIN + MHP_CPROCE + MHP_TIPO
        If MHP->( DbSeek( xFilial("MHP") + aProcesso[5] + Padr(aProcesso[1], TamSx3("MHP_CPROCE")[1] ) + "1" ) ) .And. MHP->MHP_ATIVO == "1"

            oEnviaObj := RmiEnviaObj():New(aProcesso[5],aProcesso[1])
            oEnviaObj:SetArrayFil()

            For nFil:=1 To Len(oEnviaObj:aArrayFil)
                cFilbkp   := cFilAnt
                oEnviaObj:nFil := nFil
                RmiFilInt(oEnviaObj:aArrayFil[nFil][2],.T.)//Atuliza cfilAnt para gerar Xfilial correto.
                
                cSelect := cSelectCab
                LjGrvLog(" RMIPUBSEL ","Query Filial: " + oEnviaObj:aArrayFil[nFil][2])
                
                // -- Publicação olha para as tabelas secundárias? 
                RmiPub4Sec(aProcesso)

                TRY EXCEPTION

                    If !Empty(xFilial(aProcesso[2]))
                        cWhere := " AND " + cPrefixo + "_FILIAL =  '" + xFilial(aProcesso[2]) + "' " 
                    EndIf

                    //Tratamento de macro execução
                    cFilter := aProcesso[4]
                    If SubStr(cFilter, 1, 1) == "&"
                        cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
                    EndIf

                    cWhere  += cWhereCab
                    cSelect +=  " WHERE " + cCmpExp + " = '" + Space( TamSx3(cCmpExp)[1] ) + "'" + IIF(!Empty(cFilter), ' AND ' + AllTrim(cFilter), "") + cWhere
                    
                    // -- Deve ser sempre apos o ORDERBY  caso exista (banco Postgres)
                    cSelect += cOrder

                    LjGrvLog(" RMIPUBSEL ","QUERY Seleciona os registros que serão publicados " + cSelect)
                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                    
	                If !Empty(cFilbkp)
	                    RmiFilInt(cFilbkp,.T.)//Atuliza cfilAnt .T. 
	                EndIf
                //Se ocorreu erro
                CATCH EXCEPTION USING oError        
                    LjGrvLog(" RMIPUBSEL ","Erro ao executar a query " + AllTrim(cSelect) + ". O erro pode estar ocorrendo pois o filtro cadastrado para a tabela " + aProcesso[2] + " pode estar errado, por favor, verifique no cadastro de processo se o filtro esta cadastrado corretamente. Filtro -> " +  ' AND ' + AllTrim(cFilter))
                ENDTRY           

                //Se for igual a Nil, eh porque não deu erro na execução da query, segue o processo normal
                If oError == Nil

                    //Considera os registros deletados
                    SET DELETED OFF

                    While !(cTabela)->( Eof() )

                        DbSelectArea(aProcesso[2])
                        (aProcesso[2])->( DbGoTo( (cTabela)->REGISTRO ) )

                        //Grava publicação
                        RmiPubGrv(aProcesso, (cTabela)->REGISTRO, cCmpExp)

                        (cTabela)->( DbSkip() )
                    EndDo
                    (cTabela)->( DbCloseArea() )

                    //Desconsidera os registros deletados
                    SET DELETED ON

                Else
                    //Se for diferente de Nil, deu erro na query e neste caso apenas limpo a variavel
                    //Essa variavel oError eh apenas uma variavel de controle
                    oError := Nil
                EndIf
            Next nFil

        EndIf

        //Finaliza gravação do fwBulk
        finalizaBulk()

        fwFreeObj(oStCmpsEnv)
        fwFreeObj(oStRelMih)

    EndIf

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubGrv
Grava a publicação na tabela MHQ - Mensagens Publicadas

@author  Rafael Tenorio da Costa
@since   26/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubGrv(aProcesso, nRegistro, cCmpExp, lAltExp)

    Local aArea      := GetArea()
    Local aAreasSec  := {}
    Local cJson      := ""
    Local cCmpHrExp  := StrTran(cCmpExp, "_MSEXP", "_HREXP")
    Local nX         := 0                                       //Variavel de loop 
    Local aRecTabSec := {}
    Local lSecObg    := .T.
    Local cProcesso  := aProcesso[MHNCOD]
    Local cTabela    := aProcesso[MHNTABELA]
    Local aTableFil  := aProcesso[MHSTABSECUNDARIAS]
    Local cChave     := StrTran( aProcesso[MHNCHAVE], "+", "+ '|' +" )  //Retorna campos que compoem a chave da publicação

    Default cCmpExp  := ""
    Default lAltExp  := .T.

    LjGrvLog(" RmiPubGrv ","Grava a publicação na tabela MHQ Function RmiPubGrv",{cProcesso, cTabela, nRegistro, cCmpExp, aTableFil})
    
    (cTabela)->( DbGoTo(nRegistro) )

    If !(cTabela)->( Eof() )

        //Executa funções da etapa de Pré publicação
        If ExistFunc("RmiFunExEt")
            LjGrvLog("RmiPubGrv", "Executando funções da etapa de Pré publicação", cProcesso)
            RmiFunExEt(cProcesso, "1", .T.)
        EndIf

        //Se for diferente de MIH pega o json diretamente via query
        //MIH tem os campos dentro de um campo memo em formato JSON, por isso precisa ser tratado de forma diferente e sua quantidade de registros é bem pequena
        if cTabela <> "MIH"

            //Gera json via query
            cJson := geraJsonSql(nRegistro)
        else

            //Gera publicação da tabela principal
            LjGrvLog("RmiPubGrv", "Gerando publicação da tabela principal", cTabela)
            cJson := GeraJson(cTabela, 0)
        endIf

        //Executa funções da etapa de Publicação
        If ExistFunc("RmiFunExEt")        
            LjGrvLog("RmiPubGrv", "Executando funções da etapa de Publicação", cProcesso)
            cJson := SubStr(cJson, 1, Len(cJson) - 1) + "," + RmiFunExEt(cProcesso, "2", "")
        EndIf

        If oError == Nil 

            cJson := SubStr(cJson, 1, Len(cJson) - 1) + '}' 
            LjGrvLog(" RmiPubGrv ","Resultado Json que será gravado -> "+cJson)

            If lSecObg

                //Tratamento para TOTVS PDV (carga), tabelas sem chave única
                if allTrim(cChave) == "R_E_C_N_O_"
                    cChave := cValToChar( (cTabela)->( Recno() ) )
                else
                    cChave := (cTabela)->&(cChave) + IIF( (cTabela)->( Deleted() ), "|" + cValToChar( (cTabela)->( Recno() ) ), "")
                endIf

                gravaMHQ(cProcesso, cTabela, cChave, cJson, /*cStatus*/, /*cFilReg*/)

                //Executa funções da etapa de Pòs publicação
                If ExistFunc("RmiFunExEt")
                    LjGrvLog("RmiPubGrv", "Executando funções da etapa de Pòs publicação", cProcesso)
                    RmiFunExEt(cProcesso, "3", .T.)
                EndIf
            EndIf

            //Atualiza campos de _MSEXP e _HREXP (antiga publicação)
            If lAltExp

                Begin Transaction

                    //Atualiza campos de controle de exportação da tabela principal
                    AtuCmpExp(cCmpExp, cCmpHrExp)

                    //-- Atualiza campos de controle de exportação das tabelas secundárias
                    //-- Guardo a Area de todas as tabelas secundárias que serão acessadas 
                    For nX := 1 To Len(aTableFil)
                        Aadd(aAreasSec,(aTableFil[nX][1])->(GetArea()))
                    Next
                    
                    // -- Posiciono e atualizo os campos de controle de publicação em todas as tabelas secundárias
                    For nX := 1 To Len(aRecTabSec)
                        DbSelectArea(aRecTabSec[nX][1])
                        (aRecTabSec[nX][1])->(DBGoTo(aRecTabSec[nX][2]))
                        AtuCmpExp(,,aRecTabSec[nX][1])
                    Next nX

                    // -- Retoro as alias atuais de na ordem decrescente
                    For nX := Len(aAreasSec) To 1 STEP -1
                        RestArea(aAreasSec[nX])
                    Next

                End Transaction
            EndIf
        Else
            //Se for diferente de Nil, deu erro na query e neste caso apenas limpo a variavel
            //Essa variavel oError eh apenas uma variavel de controle
            oError := Nil
        EndIf
    EndIf

    LjGrvLog(" RmiPubGrv ","Fim da Gravação ")
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraJson
Função que gera o Json com os campos da tabela passada, 
no registro que esta posicionado

@author  Rafael Tenorio da Costa
@since   30/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraJson(cTabela, nTypeJson, lControle, cTipReg)

    Local cJson      := ""
    Local oReg      := JsonObject():New()    
    Local cTipo      := ""
    Local cCampo     := ""
    Local xConteudo  := ""
    Local nCont      := 1
    Local aStructExp := {}
    Local nPosStr    := 0
    Local cPrefixo   := ""
    
    Local cDB        := TcGetDB()
    Local aCampos    := {}
    Local aReg       := {}
    Local lJsonValid := .F.         //Variavel que define se o resultado da query retornou um Json valido
    Local cQuery     := ""          //Variavel que recebe a query
    Local cCampos    := "" 
    
    Default nTypeJson := 0 
    Default lControle := .F.
    Default cTipReg   := ""

    LjGrvLog(" GeraJson "," Function GeraJson(",{cTabela, nTypeJson, lControle, cTipReg})

    If nTypeJson > 0 .and. cTabela == "MIL" .and. Empty(cTipReg)
        cJson := ""
        LjGrvLog(" GeraJson "," Não é possivel gerar relacionamento entre as tabela MIL, o campo MHS_TIPO não foi incluido nas tabelas secundarias. Verifique o cadastro de Processo!")
        Return cJson
    EndIf
    
    If cTabela != "MIH"

        If cDb $ "MSSQL|ORACLE"

            lJsonValid := .T.

            //Retorna os campos enviados pela integração relacionados a uma tabela
            cCampos := camposEnviados(cTabela)

            cQuery := IIF(cDb == "MSSQL" , "SELECT TRIM( CONVERT( VARCHAR(8000), (SELECT " + cCampos + " FROM " + RetSqlName(cTabela) + " WHERE R_E_C_N_O_ = " + cValtochar( (cTabela)->( recno( )) ) + " For JSON Path,Without_Array_Wrapper) ) ) AS RES"  , cQuery)
            cQuery := IIF(cDb == "ORACLE", "SELECT json_object(" + cCampos + " returning clob)  AS Json_doc from " + RetSqlName(cTabela) + " WHERE R_E_C_N_O_ = " + cValtochar( (cTabela)->( recno() ) )                                                    , cQuery)
        EndIf
    EndIf

    ljGrvLog(/*cNumControl*/, "Consulta que retorna o registro que será publicado:", cQuery)
    If lJsonValid .And. TCSqlToArr(cQuery,aReg) == 0 .And. Len(aReg) > 0

        lJsonValid := .F.

        //Verifica se o resultado da query é um Json valido
        If oReg:fromJson(aReg[1][1]) == nil

            lJsonValid := .T.
            
            aCampos := oReg:GetNames()

            For nCont := 1 To Len(aCampos)
                If Valtype(oReg[aCampos[nCont]]) == "C"
                    oReg[aCampos[nCont]] := Alltrim(oReg[aCampos[nCont]])
                EndIf
            Next nCont 
        EndIf

    Else

        lJsonValid := .F.
    EndIf

    If !lJsonValid
        //Carrega a estrutura da tabela
        if ( nPosStr := aScan(aStStructs, {|x| x[1] == cTabela}) ) == 0 
            aAdd(aStStructs, {cTabela, (cTabela)->( DbStruct() )} )
            nPosStr := len(aStStructs)
        endIf 
        aStructExp := aClone( aStStructs[nPosStr][2] )

        If !Empty(aStructExp)
            cCampo    := AllTrim(aStructExp[1][DBS_NAME] )
            cPrefixo  := SubStr(cCampo, 1, at('_',cCampo)-1)
        EndIf

        LjGrvLog(" GeraJson "," aStructExp estrutura da tabela -> ",aStructExp)
        For nCont:=1 To Len(aStructExp)
            
            cTipo     := AllTrim( aStructExp[nCont][DBS_TYPE] )
            cCampo    := AllTrim( aStructExp[nCont][DBS_NAME] )
            xConteudo := (cTabela)->(FieldGet(nCont))
            
            //Campos em exceção XXX_USERLGA e XXX_USERLGI
            if cCampo $ (cPrefixo+"_USERLGA|" + cPrefixo+"_USERLGI|" + cPrefixo+"_USERGA|" + cPrefixo+"_USERGI|" + cPrefixo+"_MSUIDT|")
                Loop
            EndIf

            If cTipo == "M" .And. Eval({|| xConteudo := AllTrim(xConteudo),SubStr(xConteudo, 1, 1) == "{" .And. SubStr(xConteudo, Len(xConteudo), 1) == "}"})
                CampoJson(xConteudo, cCampo,oReg)         
            Else
                //Trata o conteudo de cada tag
                oReg[cCampo] := Conteudo(cTipo, xConteudo)
            EndIf
        Next nCont
    EndIf

    If nTypeJson > 0 .and. cTabela == "MIL" .and. !Empty(cTipReg)  
        relacionamento(cTipReg, @oReg)
    EndIF

    oReg["STAMP"] := Conteudo("C", FwTimeStamp(3)) 

    cJson := oReg:ToJson()

    fwFreeArray(aStructExp)
    fwFreeObj(oReg)
Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} RetJoin
Retorna o relacionamento entre as tabelas

@author  Bruno Almeida
@since   01/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetJoin(aTb,cCab,cSec,cTabCab,cTabSec)

    Local cRet        := ""     //Variavel de retorno
    Local nX          := 0      //Variavel de loop
    Local lNotMatch   := .F.    //Indica se as duas tabelas tem o compartilhamento diferente
    Local cPrefixoSec := ""     //Prefixo da tabela secundarias
    Local aCab        := {}     //Variavel que ira receber a chave do cabecalho
    Local aSec        := {}     //Variavel que ira receber a chave das tabelas secundarias

    Default cCab    := allTrim( aTb[MHNCHAVE_PRINCIPAL] )
    Default cSec    := allTrim( aTb[MHSCHAVE]           )
    Default cTabSec := aTb[MHSTABELA]

    //Tratamento para join completo na tabela secundaria ou macro execução
    if "=" $ cSec .or. "&" $ cSec

        if subStr(cSec, 1, 1) == "&"
            cSec := &( '"' + allTrim( subStr(cSec, 2) ) + '"' )
        endIf

        cRet := cSec + " "

    //Tratamento para campos da tabela secundaria
    else
    
        aCab := separa(cCab, '+')
        aSec := separa(cSec, '+')

        If !Empty(cTabCab) .AND. !Empty(cTabSec)
            If lNotMatch := xFilial(cTabCab) <> xFilial(cTabSec)
                cPrefixoSec := IIF( SubStr( cTabSec, 1, 1) == "S", SubStr( cTabSec, 2), cTabSec ) 
            EndIf   
        EndIf 

        For nX := 1 To Len(aCab)

            //Tratamento para chave do cabeçalho com mais campos que as tabelas secundarias
            If nX > Len(aSec)
                Exit
            EndIf

            If lNotMatch .AND. aSec[nX] == cPrefixoSec + "_FILIAL"
                cRet += AllTrim(aSec[nX]) + " = '" + xFilial(cTabSec) + "' AND "   
            Else
                cRet += AllTrim(aSec[nX]) + ' = ' + AllTrim(aCab[nX]) + ' AND '
            EndIf 
        Next nX 

        cRet := SubStr(cRet,1,Len(cRet) - 4)
    endIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValor
Retorna o conteudo do campo que é passado como parametro

@author  Bruno Almeida
@since   01/11/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetCont(cTb,cCampo)

    Local cTipo     := TamSx3(cCampo)[3] //Pega o tipo do campo
    Local xConteudo := (cTb)->&( cCampo ) //Pega o conteudo do campo

    Do Case
        Case cTipo $ "C|M|L"
            xConteudo := "'" + xConteudo + "'"

        Case cTipo $ "N"
            xConteudo := cValToChar(xConteudo)

        Case cTipo == "D"
            xConteudo := "'" + DtoS(xConteudo) + "'"
        
    End Case

Return xConteudo

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCmpExp
Atualiza campos de controle de exportação, onde a tabela já deve estar posicionada.

@author  Rafael Tenorio da Costa
@since   05/03/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuCmpExp(cCmpExp, cCmpHrExp, cTabela)
    
    Local cPrefixo     := ""

    Default cTabela   := FwTabPref(cCmpExp)
    
    // -- Caso não seja enviado os campos monto com base na tabela
    If Empty(cCmpExp) .Or. Empty(cCmpHrExp)
        cPrefixo  := IIF( SubStr( cTabela, 1, 1) == "S", SubStr( cTabela, 2), cTabela )
        cCmpExp   := cPrefixo + "_MSEXP"
        cCmpHrExp := cPrefixo + "_HREXP"
    EndIf 

    RecLock(cTabela, .F.)
        If (cTabela)->( ColumnPos(cCmpExp) ) > 0
            (cTabela)->&( cCmpExp ) := DtoS( Date() )
        EndIf

        If (cTabela)->( ColumnPos(cCmpHrExp) ) > 0
            (cTabela)->&( cCmpHrExp ) := Time()
        EndIf
    (cTabela)->( MsUnLock() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Função utilizada por rotina colocadas no Schedule

@author  Rafael Tenorio da Costa
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

    Local aParam  := {}

    aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
                "ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
                /*Alias*/           ,;	
                /*Array de ordens*/ ,;
                /*Titulo*/          }

Return aParam

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RmiPub4Sec
Função responsavel por verificar se houve alteração nas tabelas secundárias e caso houver realiza a limpeza do campo _MSEXP

@type       Static Function
@author     Lucas Novais (lnovais@)
@since      14/07/2021
@version    12.1.33
@param aProcesso, Array, processo representado nas tabelas MHN990 e MHS990

@return Nil,Nulo
/*/
//-------------------------------------------------------------------------------------
Static Function RmiPub4Sec(aProcesso)
    
    Local nTabSec   := 0    // -- Variavel de controle (FOR)
    Local cPrefixoS := ""   // -- Prefixo da tabela secundária
    Local cPrefixoP := ""   // -- Prefixo da tabela primaria
    Local cCmpExpS  := ""   // -- Campo de controle da tabela secundária
    Local cCmpExpP  := ""   // -- Campo de controle da tabela primaria
    Local cTabela   := ""   // -- Alias temporario
    Local cCmpsGrp  := ""   // -- Group By utilizado na query
    Local cSelect   := ""   // -- Query completa
    Local aRecsOK   := {}   // -- Variavel que armazenas os recnos já processados
    local lMSEXP    := .F.  // -- Indica se tem o campo de controle 
    Local cFilter   := ""
   

    For nTabSec := 1 To Len(aProcesso[3])

        If aProcesso[3][nTabSec][5] $ "1|3" // -- Indica que é para considerar a secundárias para a publicação
            
            cPrefixoS := IIF( SubStr( aProcesso[3][nTabSec][1], 1, 1) == "S", SubStr( aProcesso[3][nTabSec][1], 2), aProcesso[3][nTabSec][1] )
            cPrefixoP := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )
            
            cCmpExpS  := cPrefixoS + "_MSEXP"
            cCmpExpP  := cPrefixoP + "_MSEXP"

            //Tratamento de macro execução
            cFilter := aProcesso[3][nTabSec][4]
            If SubStr(cFilter, 1, 1) == "&"
                cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
            EndIf

            IF !Empty(cFilter)
                cFilter := " AND " + cFilter
            Endif

            lMSEXP := (aProcesso[3][nTabSec][1])->(ColumnPos(cCmpExpS)) > 0

            If lMSEXP

                TRY EXCEPTION
                    cTabela  := GetNextAlias()
                    cCmpsGrp := "A." + StrTran(aProcesso[3][nTabSec][2],"+",", A.")
                    
                    BeginContent var cSelect
                    
                        SELECT TOP(50) B.R_E_C_N_O_ AS RECNO_PRINCIPAL 
                        FROM %Exp:RetSqlName(aProcesso[3][nTabSec][1])% AS A
                        INNER JOIN %Exp:RetSqlName(aProcesso[2])% AS B
                        ON %Exp:RetJoin(,aProcesso[3][nTabSec][2],aProcesso[3][nTabSec][3],aProcesso[3][nTabSec][1],aProcesso[2])%
                        WHERE A.%Exp:cCmpExpS% = '%Exp:Space(TamSx3(cCmpExpS)[1])%' 
                        AND A.%Exp:cPrefixoS%_FILIAL = '%Exp:xFilial(aProcesso[3][nTabSec][1])%'
                        %Exp:cFilter%
                        GROUP BY %Exp:cCmpsGrp% ,B.R_E_C_N_O_

                    EndContent

                    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)
                    LjGrvLog(" RmiPub4Sec ","QUERY Seleciona os registros secundárias que serão publicados " + cSelect)

                CATCH EXCEPTION USING oError
                    LjGrvLog(" RmiPub4Sec ","Erro ao executar a query " + AllTrim(cSelect))
                    LjGrvLog(" RmiPub4Sec ","ERROR " + AllTrim(oError:Description))
                ENDTRY
            Else
                LjGrvLog(" RmiPub4Sec ","Campo [" + cCmpExpS  + "] não criado na tabela [" + aProcesso[3][nTabSec][1] + "]. Tabela não será considerada na geração da publicação." )
                LjGrvLog(" RmiPub4Sec ","Com isso, caso a tabela [" + aProcesso[3][nTabSec][1] + "] sofra alteração não será gerada publicação por meio dela." )
            EndIf 

            If oError == Nil .And. lMSEXP
                //Considera os registros deletados
                SET DELETED OFF
                While !(cTabela)->( Eof() )
                    
                    If (aScan(aRecsOK,(cTabela)->RECNO_PRINCIPAL)) == 0 

                        DbSelectArea(aProcesso[3][nTabSec][1])
                        (aProcesso[2])->(DBGoTo((cTabela)->RECNO_PRINCIPAL))
                        
                        If !Empty((aProcesso[2])->&(cCmpExpP))

                            RecLock(aProcesso[2], .F.)
                                REPLACE (aProcesso[2])->&(cCmpExpP) WITH ""
                            (aProcesso[2])->(MsUnLock())
                        EndIf 

                        // -- Armazeno o recno processado para evitar duplo processamento 
                        aAdd(aRecsOK,(cTabela)->RECNO_PRINCIPAL)

                    EndIf 
                    (cTabela)->( DbSkip() )
                EndDo
                (cTabela)->( DbCloseArea() )

                //Desconsidera os registros deletados
                SET DELETED ON

            EndIf 
        Else
            LjGrvLog(" RmiPub4Sec "," A Tabela: [" + aProcesso[3][nTabSec][1] + "] Não é considerada para a publicação do processo: [" +  aProcesso[1] + "]")
        EndIf 

    Next nTabSec

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CampoJson
Publica o um campo memo com conteudo em json.

@param   cJson, Caractere, Json em string que será publicado
@return  Caractere, Conteudo Json em string no formuto da publicação  
@author  Rafael Tenorio da Costa
@since   13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CampoJson(cJson, cCampoX3,oReg)

    Local cTag      := ""
    Local xConteudo := Nil
    Local cTipo     := ""
    Local oJson     := JsonObject():New()
    Local nCont     := 0

    //Carrega configurações do tipo do cadastro        
    oJson:FromJson(cJson)

    if oJson:hasProperty("Components")

        For nCont:=1 To Len(oJson["Components"])

            cTag      := oJson["Components"][nCont]["IdComponent"]
            xConteudo := oJson["Components"][nCont]["ComponentContent"]
            cTipo     := AllTrim( Upper( oJson["Components"][nCont]["ContentType"] ) )
            cTipo     := IIF( cTipo == "NUMBER", "N", IIF(cTipo == "LOGICAL", "L", "C") )

            //Trata o conteudo de cada tag
            oReg[cTag] := Conteudo(cTipo, xConteudo)
        Next nCont
    else

        LjxjMsgErr("O conteúdo do campo " + cCampoX3 + " no formato JSON está fora do padrão, pois não possui a tag [Components]. Portanto, não será publicado.", /*cSolucao*/, "RmiPublica", cJson)
    endIf

    FwFreeObj(oJson)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Conteudo
Trata o conteudo de cada tag que será publicado.

@param   cTipo, Caractere, Tipo que o conteudo deve ter para ser publicado
@param   xConteudo, Indefinido, Conteudo da tag que será publicado 
@param   cTag, Caractere, Indentificador da Tag
@return  Caractere, Tag com o Conteudo que será publicado formatada   
@author  Rafael Tenorio da Costa
@since   13/09/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Conteudo(cTipo, xConteudo)

    Local cRetorno := ""

    Do Case

        Case cTipo == "C"

            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            xConteudo := StrTran(xConteudo,"\","\\")
            
            cRetorno := AllTrim(xConteudo)

        Case cTipo == "M"

            xConteudo := AllTrim(xConteudo)
            //Retira as "" ou '', pois ocorre erro ao realizar o Parse do Json
            xConteudo := StrTran(xConteudo,'"','')
            xConteudo := StrTran(xConteudo,"'","")
            xConteudo := StrTran(xConteudo,"\","\\")
            
            cRetorno := AllTrim(xConteudo)            

        Case cTipo == "N"
            cRetorno := xConteudo            

        Case cTipo == "D"
            cRetorno := DtoS(xConteudo)

        Case cTipo == "L"
            cRetorno := IIF(valType(xConteudo) <> "L" .or. empty(xConteudo) .or. !xConteudo, .F., .T.) //Converte o conteudo para logico, caso não seja logico ou esteja vazio, assume o valor .F.

        OTherWise
            cRetorno :=  STR0004    //"Tipo do campo inválido"            

    End Case

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Relacionameno
Inclui no json de publicação as tags que não fazem parte da tabela MIL

@author  Danio Rodrigues
@since   29/11/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function relacionamento(cContTip, oReg)

    Local oJson     := nil
    Local aDadosMih := {}
    Local cContSai  := oReg["MIL_SAIDA"]
    Local cChave    := xFilial("MIH") + padR(cContTip, tamSx3("MIH_TIPCAD")[1]) + cContSai    
    Local cTipo     := ""
    Local cCampo    := ""
    Local xConteudo := ""    
    Local nTag      := 1
    Local nConteudo := 2
    Local nCont     := 0

    //Carrega MIH da memória, para evitar multiplas consultas ao longo do processo de publicação
    if !oStRelMih:get(cChave, @aDadosMih)

        MIH->(DbSetOrder(1))   //MIH_FILIAL, MIH_TIPCAD, MIH_ID, R_E_C_N_O_, D_E_L_E_T_
        If MIH->( Dbseek(cChave) )
            
            oJson := JsonObject():new()
            oJson:fromJson(MIH->MIH_CONFIG)

            For nCont := 1 to Len(oJson["Components"])           

                cTipo     := Valtype(oJson["Components"][nCont]["ComponentContent"])
                cCampo    := oJson["Components"][nCont]["IdComponent"]
                xConteudo := oJson["Components"][nCont]["ComponentContent"]
            
                //Trata o conteudo de cada tag
                aAdd(aDadosMih, { cCampo, conteudo(cTipo, xConteudo) } )

            Next nCont

            oStRelMih:set(cChave, aClone(aDadosMih))

            fwFreeObj(oJson)
        else

            LjGrvLog(" Relacionamento ", "Tipo de cadastro (" + cContTip + "), e tipo de Saida (" + cContSai + ")  não encontrado, favor verificar se o processo de cadastro auxiliar foi realizado!")
        endIf
    endIf

    //Carrega tags que fazem parte da MIH (cadastros auxiliares)
    for nCont := 1 to Len(aDadosMih)
        oReg[ aDadosMih[nCont][nTag] ] := aDadosMih[nCont][nConteudo]
    next nCont

    aDadosMih := nil
    fwFreeArray(aDadosMih)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} SHPPrePub
Função responsavel encontrar os processos habilidados e iniciar a publicação dos registros

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cEmpPub, Caractere, Empresa de publicação
@param 	 cFilPub, Caractere, Filial de publicação

/*/
//-----------------------------------------------------------------------
Function SHPPrePub(cTipo, cFiltro)

    Local nX          	:= 0   				// -- Variavel de controle
    Local nI          	:= 0   				// -- Variavel de controle
    Local aTable      	:= {}
    Local aUltPublica 	:= {}
    Local aFilsPub    	:= {}  				// -- Array com as filiais que irão ser publicadas
    Local aFilProc    	:= {}
    Local cProcessos    := ""
    Local cGrupos       := ""
    Local lGrupo        := .F.
    Local aProcGrupo    := {}
    Local nPos          := 0

    Default cTipo       := "1"  //1=Processo, 2=Grupo
    Default cFiltro     := ""   //Código do processo ou grupo
    
    //Gera carga para novas lojas
    pendenteCarga()

    //Retorna os processos que serão publicados
    IIF(cTipo == "1", cProcessos := cFiltro, cGrupos := cFiltro)
    lGrupo := cTipo == "2" .and. MHN->( columnPos("MHN_CODGRP") ) > 0
    aTable := RmiProPub(cProcessos, cGrupos, lGrupo)

    //Retorna a data\hora da ultima publicação dos processos
    aUltPublica := ultPublica()

    For nX := 1 To Len(aTable)

        aFilProc := aTable[nX][MHPFILPRO]

        //Verifica\Retorna para quais filiais deve ser feita a publicação do processo
        aFilsPub := publica(aTable[nX], aUltPublica, aFilProc)

        For nI := 1 To len(aFilsPub)

            //Carrega processos por grupo
            if lGrupo

                if ( nPos := aScan(aProcGrupo, {|x| x[1] == aTable[nX][MHNCODGRP]}) ) == 0
                    aAdd(aProcGrupo, { aTable[nX][MHNCODGRP], {} })
                    nPos := len(aProcGrupo)
                endIf

                aAdd(aProcGrupo[nPos][2], { aFilsPub[nI], aTable[nX] })

            else

                StartJob("SHPPubSel", GetEnvServer(), .F./*lEspera*/, cEmpAnt, aFilsPub[nI], aTable[nX] )
                sleep(1000)
            endIf

        Next nI 

    Next nX

    //Publica por grupo, abre uma thread por grupo
    if lGrupo
        for nPos:=1 to len(aProcGrupo)
            startJob("pshPubGrp", GetEnvServer(), .F./*lEspera*/, cEmpAnt, cFilAnt, aProcGrupo[nPos])
            sleep(1000)
        next nPos

        //Grava a ultima execução do JOB RmiPublica
        if findFunction("RmiGrvStSv") .and. !empty(cGrupos)
            RmiGrvStSv("RMIPUBLICA", cEmpAnt, cFilAnt, "", "", cGrupos)
        endIf        
    endIf

    fwFreeArray( aProcGrupo  )
    fwFreeArray( aTable      )
    fwFreeArray( aUltPublica )
    fwFreeArray( aFilsPub    )
    fwFreeArray( aFilProc    )

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} SHPPubSel
Função responsavel por buscar os processo que devem gerar publicação considerando as filiais cadastradas

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cEmpPub, Caractere, Empresa de publicação
@param 	 cFilPub, Caractere, Filial de publicação
@param 	 aProcesso, Array, Array com os dados do processo que será publicadi

/*/
//-------------------------------------------------------------------------
Function SHPPubSel(cEmpPub, cFilPub, aProcesso)

    Local cSemaforo    := ""                                                                                    // -- Controle de execução
    Local cQuery       := ""                                                                                    // -- Variavel utilizada para armazenar Query
    Local cPrefixo     := IIF( SubStr( aProcesso[2], 1, 1) == "S", SubStr( aProcesso[2], 2), aProcesso[2] )     // -- Prefixo da tabela 
    Local nMaxbloco    := nStTamBulk                                                                            // -- Numero maximo de registros na query
    Local cMsgError    := ""                                                                                    // -- Mensagem de erro          
    Local oUltRecno    := nil                                                                                   // -- Json com ultimos recnos
    Local nUltimoRecno := 0
    Local cCmpExp      := cPrefixo + "_MSEXP"
    Local lContinua    := .T.
    Local nCont        := 0
    Local nI           := 0
    Local cUltAltera   := ""
    Local nX           := 0
    Local aReg         := {}                                                                                    // -- Array que armazena os registros que serão publicados:
    Local nReg         := 0
    Local cUltPublica  := ""

    if !empty(cFilPub)

        If aProcesso[5] <> "TERCEIROS"
            RpcSetType(3) // Para não consumir licenças na Threads
        EndIF

        RpcSetEnv(cEmpPub, cFilPub, , , "LOJA", "SHPPubSel")
    endIf

    cSemaforo := "SHPPUBSEL" +"_"+ cEmpPub +"_"+ xFilial(aProcesso[2]) +"_"+ aProcesso[1]
    
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        LjxjMsgErr( I18n(STR0002, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        rpcClearEnv()        
        Return Nil
    EndIf

    //Carrega staticas
    carStaticas(aProcesso)

    //Inicializa variaveis antes do loop de publicação
    oUltRecno := JsonObject():New()

    ljxjMsgErr("Publica" + " - " + cSemaforo + " - " + time() + " - " + cValTochar( ThreadId() ), /*cSolucao*/, /*cRotina*/, {cEmpAnt, cFilAnt, aProcesso})

    For nX := 1 To Len(aProcesso[11])

        Do Case
            Case Alltrim(aProcesso[11][nX]) == "SIGAGPC"
                // -- Cria objeto de envio para o SIGAGPC
                oEnvio := RmiEnvSigaGpcObj():New(Alltrim(aProcesso[1]))
                
            Case Alltrim(aProcesso[11][nX]) == "SMARTLINK"
                // -- Cria objeto de envio para o SmartLink (será alterado)
                oEnvio := RmiEnvSmartLinkObj():New(Alltrim(aProcesso[1]))
                Conout("Envio direto habilitado para o assinante "+Alltrim(aProcesso[11][nX])+", processo: " + Alltrim(aProcesso[2]) + " - " + Alltrim(aProcesso[1]) )

            OTherWise
                lGeraMHQ := .T.
        End Case 

    Next nX 

    If oEnvio <> Nil

        // -- Verifica se o objeto de envio possui a propriedade qtdEnvio
        If oEnvio:oConfProce <> Nil .And. oEnvio:oConfProce:hasProperty("qtdEnvio")   
            nMaxbloco := oEnvio:oConfProce["qtdEnvio"]
        EndIf
    EndIf
    
    //Inicia gravação do fwBulk
    iniciaBulk()

    //Verifica se tem mais registros para processar depois de processar a quantidade do nMaxbloco
    while lContinua
        
        //Carrega dados do controle da publicação do processo/filial
        MIN->( dbSetOrder(1) )  //MIN_FILIAL + MIN_CPROCE + MIN_FILPUB
        if MIN->( dbSeek( xFilial("MIN") + cStProcesso + xFilial(aProcesso[MHNTABELA]) ) )        

            ljGrvLog(/*cNumControl*/, "Retorno com a ultima publicação do proceso/filial:", {MIN->MIN_CPROCE, MIN->MIN_FILPUB, MIN->MIN_ULTPUB, MIN->MIN_ULTREC} )

            oUltRecno:fromJSON(MIN->MIN_ULTREC)
            
            aMINAux[1]         := MIN->MIN_FILPUB
            aMINAux[2]         := MIN->MIN_CPROCE
            aMINAux[3]         := MIN->MIN_ULTPUB
            aMINAux[4]         := oUltRecno 
            aMINAux[5]         := getUltRec(aProcesso[MHNTABELA]) == 0  //Verifica se todos os registros(recnos) já foram processados
            aMINAux[6]         := .T.
            aMINAux[MINLJDEST] := iif(lStCargaIni .and. MIN->MIN_CARGA == "1", MIN->MIN_LJDEST, "")
        Else

            aMINAux[1]         := xFilial(aProcesso[MHNTABELA])
            aMINAux[2]         := aProcesso[1]
            aMINAux[3]         := ""
            aMINAux[4]         := oUltRecno  
            aMINAux[5]         := .T.
            aMINAux[6]         := .T.
            aMINAux[MINLJDEST] := ""
        EndIf
            
        cUltPublica := aMINAux[3]                                        // -- Ultima Publicação    
        cUltAltera  := IIF(empty(cUltAltera), aMINAux[3], cUltAltera)    // -- S_T_A_M_P_ do último registro processado, inicializa com a data da ultima publicação (MIN_ULTPUB)
        nUltREC     := GetUltRec(aProcesso[2])                           // -- Ultimo recno da tabela principal

        aReg   := {}
        cQuery := consulta(aProcesso, cUltPublica, cCmpExp, .T., nUltREC)
        cQuery := changeQuery(cQuery)
        
        LjGrvLog(" RMIPUBSEL ","Query que lista os registros disponiveis para publicação:", cQuery)     

        //aReg[nReg][1] = S_T_A_M_P_
        //aReg[nReg][2] = RECNO
        if TCSqlToArr(cQuery,aReg) == 0 .And. Len(aReg) > 0

            ljGrvLog(" RMIPUBSEL ", "Processando as publicações")

            SET DELETED OFF

            For nReg := 1 To Len(aReg)

                nCont++
                nI++

                (aProcesso[2])->( DbGoTo( aReg[nReg][2] ) )

                If aReg[nReg][1] > cUltAltera 
                    cUltAltera := aReg[nReg][1] 
                EndIf
                nUltimoRecno := aReg[nReg][2]

                //Grava publicação
                RmiPubGrv(aProcesso, aReg[nReg][2], "", .F.)

                //Quando chegar no tamanho do bloco grava o controle MIN
                if nCont == nMaxbloco

                    nCont := 0

                    //-- Atualizo ultima publicação com a data da ultima atalização e ultimo recno processado
                    aMINAux[3] := cUltAltera
                    SetUltRec(aProcesso[2], nUltimoRecno)

                    setUltAlt()
                endIf
            Next nReg

            fwFreeArray(aReg)

            // -- Desconsidera os registros deletados
            SET DELETED ON

            //-- Atualizo ultima publicação com a data da ultima atalização e ultimo recno processado
            aMINAux[3] := cUltAltera
            SetUltRec(aProcesso[2], nUltimoRecno)

            setUltAlt()
        else
        
            cMsgError := "O Processo " + aProcesso[MHNCOD] + " não tem alterações com data superior a [" + cUltPublica + "]" + CRLF
            cMsgError += "Retorno de execução da query: [" + tcSqlError() + "]"

            //Todo o processamento foi encerrado, atualiza controle de publicação retirando ultimo recno
            SetUltRec(aProcesso[MHNTABELA], 0)
            setUltAlt()
        endIf

        //Finaliza o processo após todo o processamento
        if !empty(cMsgError)
            lContinua := .F.
        endIf
    endDo

    //Finaliza gravação do fwBulk
    finalizaBulk()

    fwFreeObj(oStCmpsEnv)
    fwFreeObj(oStRelMih)
    FwFreeObj(oUltRecno)
    FwFreeObj(oEnvio)
    
    LjGrvLog("SHPPubSel", "Job SHPPubSel finalizado, resultado:", {aProcesso, cQuery, cMsgError})
    
    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    
    if !empty(cFilPub)
        rpcClearEnv()
    endIf
    
return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} setUltAlt
Função responsavel por a alteração da tabela MIN (tabelas responsavel por controlar a ultima publicação para o proceso|filial )

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cFilPub, Caractere, Filial de publicação
@param 	 cProcesso, Caractere, processo publicado

/*/
//-----------------------------------------------------------------------
Static Function setUltAlt()

    Local lInclui := Nil
    Local cFilPub := xFilial(aStProcesso[MHNTABELA])

    if oEnvio <> Nil 

        If oEnvio:GetSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .T. e vai executar a rotina oEnvio:Processa() ")
            oEnvio:Processa(aStDados,cFilPub) //carrego array dos dados a serem enviados
        EndIf

        If !oEnvio:getSucesso()
            LjGrvLog(" RmiEnvExec ", " executado o oEnvio:GetSucesso() = .F. e Vai recuperar o erro ")
            oEnvio:getRetorno()
            LjGrvLog(" RmiEnvExec ",oEnvio:getRetorno())
        EndIf

        aStDados := {}
	endIf

    //Commita gravação quando estiver utilizando o fwBulk
    gravaBulk()

    MIN->( dbSetOrder(1) )  //MIN_FILIAL + MIN_CPROCE + MIN_FILPUB
    lInclui := !MIN->( dbseek(xFilial("MIN") + cStProcesso + cFilPub) )

    RecLock("MIN", lInclui)

        If lInclui
            REPLACE MIN->MIN_FILIAL WITH xFilial("MIN")
            REPLACE MIN->MIN_FILPUB WITH cFilPub
            REPLACE MIN->MIN_CPROCE WITH cStProcesso
            
            //Inicia controle de publicação como carga 0=Incremental, porque não tem como saber qual foi a loja que disparou a publicação (MIN_LJDEST)
            if lStCargaIni
                REPLACE MIN->MIN_CARGA WITH "0"     //0=Incremental
            endIf
        EndIf         
        
        REPLACE MIN->MIN_ULTPUB WITH aMINAux[3]           
        REPLACE MIN->MIN_ULTREC WITH aMINAux[4]:toJSON()

        //Caso esteja em carga inicial(1=Inicial) verifica se chegou ao fim da carga, para indicar que a carga inicial foi concluída
        if lStCargaIni
            
            if MIN->MIN_CARGA == "1" .and. ( allTrim(MIN->MIN_ULTPUB) > allTrim(MIN->MIN_DTINIC) .or. getUltRec(aStProcesso[MHNTABELA]) == 0 )
                REPLACE MIN->MIN_CARGA  WITH "0"    //0=Incremental
                REPLACE MIN->MIN_DTFIMC WITH strTran( fwTimeStamp(3, /*dDate*/, timeFull()), "T", " " )
            endIf
        endIf
    
    MIN->( msUnLock() )

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SetUltRec
Função responsavel por setar (atualizar) um numero de recno a key (tabela do processo) atual

@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cKey, Caractere, Chave (Tabela do processo)
@param 	 nRecno, numerico, recno

/*/
//-----------------------------------------------------------------------
Static Function SetUltRec(cKey,nRecno)
    cKey := Alltrim(cKey)
    aMINAux[4][cKey] := nRecno
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetUltRec
Função responsavel por devolver um numero de recno da key (tabela do processo) atual
@author  Lucas Novais (lnovais@)
@since 	 28/04/2022
@version P12.1.2210

@param 	 cKey, Caractere, Chave (Tabela do processo)
/*/
//-----------------------------------------------------------------------
Static Function GetUltRec(cKey)

    Local nRecno := 0

    cKey := Alltrim(cKey)

    If aMINAux[4]:hasProperty(cKey)
        nRecno := aMINAux[4][cKey]
    Else
        aMINAux[4][cKey] := 0
    EndIf 

Return nRecno

//-----------------------------------------------------------------------
/*/{Protheus.doc} RmiProPub
Retorna os processos que serão publicados, com toda a estrutura necessária para a publicação.

@type    Function
@author  Rafael Tenorio da Costa
@since   20/07/22
@version 12.1.33
/*/
//-----------------------------------------------------------------------
Function RmiProPub(cProcessos, cGrupos, lGrupo)
	
    Local cSelect       := "" 
    Local cTabela       := ""
    Local aProcesso     := {}
    Local aTabSec       := {}     
    Local nPos          := 0 
    Local nI            := 0
    Local cTamTab       := Space( TamSx3("MHN_TABELA")[1] )
    Local aFilPro       := {}
    Local oProcAssi     := JsonObject():New()          //Armazena os assinantes que estão utilizando os processos ativos

    Default cProcessos  := ""
    Default cGrupos     := ""
    Default lGrupo      := .F.

    //Seleciona os processos assinados
    cTabela := GetNextAlias()

    cSelect := " SELECT MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE, MHP_CASSIN, MHN_SECOBG, MHN_FILTRO, MHS_FILTRO, MHS_CONPUB, MHS_TIPO"
    cSelect += IIF(lGrupo, ", MHN_CODGRP", "")

    cSelect += " FROM " + RetSqlName("MHN") + " MHN INNER JOIN " + RetSqlName("MHP") + " MHP"
    cSelect +=      " ON MHN_FILIAL = MHP_FILIAL AND MHN_COD = MHP_CPROCE AND MHN.D_E_L_E_T_ = MHP.D_E_L_E_T_ AND MHN_TABELA NOT IN ('XXX','YYY','" + cTamTab + "')"
    cSelect += " LEFT JOIN " + RetSqlName("MHS") + " MHS"
    cSelect +=      " ON MHS_FILIAL = MHN_FILIAL AND MHS_CPROCE = MHN_COD AND MHS.D_E_L_E_T_ = ' '"

    cSelect += " WHERE MHN.D_E_L_E_T_ = ' '"
    cSelect += " AND MHP_ATIVO = '1'"           //1=Sim
    cSelect += " AND MHP_TIPO = '1'"            //1=Envia
    cSelect += " AND MHP_CASSIN <> 'PROTHEUS'"  //Não gerar MHQ para Assinante Protheus em caso do tipo ser 1=Envia.

    If !Empty(cProcessos)
        cSelect += " AND MHN_COD IN " + FormatIn(cProcessos, ",")
    EndIf

    if lGrupo .and. !empty(cGrupos)
        cSelect += " AND MHN_CODGRP IN " + FormatIn(cGrupos, ",")
    endIf

    cSelect += " GROUP BY MHN_COD, MHN_TABELA, MHN_CHAVE, MHS_TABELA, MHS_CHAVE, MHP_CASSIN, MHN_SECOBG, MHN_FILTRO, MHS_FILTRO, MHS_CONPUB, MHS_TIPO"
    cSelect += IIF(lGrupo, ", MHN_CODGRP", "")

    cSelect := ChangeQuery(cSelect)

    LjGrvLog("RmiProPub", "Query executada para retornar os processos que serão publicados:", cSelect)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    While !(cTabela)->( Eof() )
        
        //Verifico no array aProcesso se determinada tabela do cabeçalho ja existe no array
        nPos := aScan(aProcesso,{|x| AllTrim(x[1]) == AllTrim( (cTabela)->MHN_COD ) .And. AllTrim(x[5]) == AllTrim( (cTabela)->MHP_CASSIN ) })

        aTabSec := {    allTrim( (cTabela)->MHS_TABELA  ) ,;
                        allTrim( (cTabela)->MHS_CHAVE   ) ,;
                        allTrim( (cTabela)->MHN_CHAVE   ) ,;
                        allTrim( (cTabela)->MHS_FILTRO  ) ,;
                        allTrim( (cTabela)->MHS_CONPUB  ) ,;
                        allTrim( (cTabela)->MHS_TIPO    ) }        

        //Caso a tabela ainda nao existe no array, entao é add no array a tabela principal mais as filhas
        If nPos == 0

            aFilPro := rmixFilial((cTabela)->MHP_CASSIN, (cTabela)->MHN_COD)

            If Valtype(oProcAssi[AllTrim( (cTabela)->MHN_TABELA  )+'-'+AllTrim( (cTabela)->MHN_COD     )]) == "U"
                oProcAssi[AllTrim( (cTabela)->MHN_TABELA  )+'-'+AllTrim( (cTabela)->MHN_COD     )] := {}
            EndIf    

            Aadd(oProcAssi[AllTrim( (cTabela)->MHN_TABELA  )+'-'+AllTrim( (cTabela)->MHN_COD     )],Alltrim((cTabela)->MHP_CASSIN))

            Aadd(aProcesso ,;   
                        {   allTrim( (cTabela)->MHN_COD     )       ,;
                            allTrim( (cTabela)->MHN_TABELA  )       ,;
                            {}                                      ,;
                            allTrim( (cTabela)->MHN_FILTRO  )       ,;
                            (cTabela)->MHP_CASSIN                   ,;
                            allTrim( (cTabela)->MHN_SECOBG  )       ,;
                            allTrim( (cTabela)->MHS_TIPO    )       ,;
                            allTrim( (cTabela)->MHN_CHAVE   )       ,;
                            aClone(aFilPro)                         ,;
                            IIF(lGrupo, (cTabela)->MHN_CODGRP, "")  }   )

            nPos := Len(aProcesso)
        EndIf

        If !Empty( (cTabela)->MHS_TABELA )
            Aadd(aProcesso[nPos][3], aTabSec)
        EndIf

        (cTabela)->( DbSkip() )
    EndDo
       
    (cTabela)->( DbCloseArea() )

    For nI := 1 To Len(aProcesso)
        Aadd(aProcesso[nI],oProcAssi[aProcesso[nI][2]+'-'+aProcesso[nI][1]]) //Adiciona os assinantes que estão utilizando o processo ativo
    Next nI

    fwFreeArray(aFilPro)
    FwFreeObj(oProcAssi)
    LjGrvLog("RmiProPub", "Processos que serão publicados:", aProcesso)

Return aProcesso
//-------------------------------------------------------------------
/*/{Protheus.doc} RmiPubMix
Grava a publicação na tabela MHQ - Mensagens Publicadas do Mix de Produto

@author  Everson S P Junior
@since   14/03/23
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiPubMix(aProcesso, nRegistro)

    Local aArea      := GetArea()
    Local cJson      := ""
    Local lSecObg    := .T.
    Local cProcesso  := aProcesso[1]
    Local cTabela    := aProcesso[2]
    Local cFilPro    := aProcesso[9]
    Local cChave     := aProcesso[8]  //Retorna campos que compoem a chave da publicação

    Default cCmpExp := ""
    Default lAltExp := .T.

    LjGrvLog(" RmiPubGrv ","Grava a publicação na tabela MHQ Function RmiPubGrv",{cProcesso, cTabela, nRegistro})
    
    (cTabela)->( DbGoTo(nRegistro) )

    If !(cTabela)->( Eof() )

        //Gera publicação da tabela principal
        LjGrvLog("RmiPubGrv", "Gerando publicação da tabela principal", cTabela)
        cJson := GeraJson(cTabela, 0)
        cJson := StrTran(cJson,'"B1_FILIAL": "'+Space(Tamsx3('B1_FILIAL')[1])+'"','"B1_FILIAL": "'+cFilPro+'"')//Verifica se vem com espaço 
        cJson := StrTran(cJson,'"B1_FILIAL":"'+Space(Tamsx3('B1_FILIAL')[1])+'"','"B1_FILIAL": "'+cFilPro+'"')//Verifica se vem com espaço 
        cJson := StrTran(cJson,'"B1_FILIAL": ""','"B1_FILIAL":"'+cFilPro+'"')//Verifica se vem sem espaço
        cJson := StrTran(cJson,'"B1_FILIAL":""','"B1_FILIAL":"'+cFilPro+'"')//Verifica se vem sem espaço
        If oError == Nil 

            cJson := SubStr(cJson,1,Len(cJson) - 1) + CRLF + '}' 
            LjGrvLog(" RmiPubGrv ","Resultado Json que será gravado -> "+cJson)
            Begin Transaction
                If lSecObg

                    GravaMHQ(   cProcesso   ,;
                                cTabela     ,; 
                                cFilPro+'|'+(cTabela)->&(cChave) + IIF( (cTabela)->( Deleted() ), "|" + cValToChar( (cTabela)->( Recno() ) ), "")   ,; 
                                cJson       ,; 
                                "1"         )

                EndIf

            End Transaction
        EndIf
    EndIf

    LjGrvLog(" RmiPubGrv ","Fim da Gravação Mix de Produto")
    RestArea(aArea)

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GravaMHQ
Centraliza a gravação da tabela MHQ

@type    Function
@param 	 cProcesso  , Caractere, Processo da publicação
@param 	 cTabela    , Caractere, Tabela da publicação
@param 	 cChave     , Caractere, Chave unica da publicação
@param 	 cJson      , Caractere, Json da publicação
@param 	 cStatus    , Caractere, Status da publicação
@param 	 cFilReg    , Caractere, Filial do registro publicado
@author  Rafael Tenorio da Costa
@since   19/05/23
@version 12.1.2210
/*/
//-----------------------------------------------------------------------
Static Function GravaMHQ(cProcesso, cTabela, cChave, cJson, cStatus,;
                         cFilReg )

    Local cHora := IIF( TamSx3("MHQ_HORGER")[1] >= 12, TimeFull(), Time() )
    Local cUuid := FWUUIDV4(.T.)

    Default cStatus := "1"  //0=Em publicação; 1=Liberado para distribuição; 9=Aguardando confirmação do produto
    Default cFilReg := iif( empty(aMINAux[MINLJDEST]), xFilial(cTabela), aMINAux[MINLJDEST] )

    If oEnvio <> Nil 
        aadd(aStDados, { xFilial("MHQ")                             ,;  //MHQ->MHQ_FILIAL
                        "PROTHEUS"                                  ,;  //MHQ->MHQ_ORIGEM
                        cProcesso                                   ,;  //MHQ->MHQ_CPROCE
                        IIF( (cTabela)->( Deleted() ), "2", "1" )   ,;  //MHQ->MHQ_EVENTO
                        cChave                                      ,;  //MHQ->MHQ_CHVUNI
                        cJson                                       ,;  //MHQ->MHQ_MENSAG
                        Date()                                      ,;  //MHQ->MHQ_DATGER
                        cHora                                       ,;  //MHQ->MHQ_HORGER
                        cStatus                                     ,;  //MHQ->MHQ_STATUS
                        cUuid                                       ,;  //MHQ->MHQ_UUID
                        cFilReg                                     })  //MHQ->MHQ_IDEXT    
    EndIf

    If lGeraMHQ

        //Utiliza fwBulk na gravação
        //O array de extrutura (aStStrBulk) deve estar na mesma ordem da inclusão do registro no fwBulk (oStBulk:addData)
        oStBulk:addData({   xFilial("MHQ")                              ,;  //MHQ->MHQ_FILIAL
                            "PROTHEUS"                                  ,;  //MHQ->MHQ_ORIGEM
                            cProcesso                                   ,;  //MHQ->MHQ_CPROCE
                            IIF( (cTabela)->( Deleted() ), "2", "1" )   ,;  //MHQ->MHQ_EVENTO
                            cChave                                      ,;  //MHQ->MHQ_CHVUNI
                            cJson                                       ,;  //MHQ->MHQ_MENSAG
                            Date()                                      ,;  //MHQ->MHQ_DATGER
                            cHora                                       ,;  //MHQ->MHQ_HORGER
                            cStatus                                     ,;  //MHQ->MHQ_STATUS
                            cUuid                                       ,;  //MHQ->MHQ_UUID
                            cFilReg                                     })  //MHQ->MHQ_IDEXT
    endIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} publica
Verifica se existem registros para publicar,
e retorna as filiais onde deve ser feito o processamento.

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function publica(aProcesso, aUltPublica, aFilProc)

    Local aArea         := getArea()
    Local aFilRet       := {}
    Local aTabelas      := {}
    Local nTabela       := 0
    Local cTabela       := ""
    Local cSql          := ""
    Local nPosUltPub    := 0
    Local cUltPublica   := ""
    Local cPrefixo      := ""
    Local cCmpFil       := ""
    Local cCmpExp       := ""
    Local cFilPub       := ""
    Local aAux          := {}
    Local nFil          := 0

    Default aUltPublica := {}

    //Verifica se tem tabela preenchida porque existe processos de gatilhos(MHN_GATILH)
    if !empty( aProcesso[MHNTABELA] )

        aAdd( aTabelas, aProcesso[MHNTABELA] )

        for nTabela:=1 to len(aTabelas)

            cTabela  := aTabelas[nTabela]
            cPrefixo := IIF( subStr( cTabela, 1, 1) == "S", subStr( cTabela, 2), cTabela )
            cCmpFil  := cPrefixo + "_FILIAL"
            cCmpExp  := cPrefixo + "_MSEXP"

            //Verifico se o campo de controle existe
            if !temStamp(cTabela)

                ljxjMsgErr("Campo de controle S_T_A_M_P_ não existe na tabela " + cTabela + ", a integração não será executada.", /*cSolucao*, /*cRotina*/, /*xVar*/)
            else

                for nFil:=1 to len(aFilProc)

                    cUltPublica := ""
                    cFilPub     := xFilial(cTabela, aFilProc[nFil])

                    //Procura o processo e a filial no controle de publicação
                    nPosUltPub  := aScan( aUltPublica, {|x| allTrim(x[MINCPROCE]) == allTrim(aProcesso[MHNCOD]) .and. allTrim(x[MINFILPUB]) == allTrim(cFilPub)} )
                    if nPosUltPub > 0
                        cUltPublica := aUltPublica[nPosUltPub][MINULTPUB]
                    endIf

                    //Consulta a tabela para ver se tem registro para publicar
                    cSql := " SELECT COUNT(1) FROM ("
                    cSql += consulta(aProcesso, cUltPublica, cCmpExp, /*lStamp*/, /*nUltREC*/, .F./*lOrderBy*/,aFilProc[nFil] /*cFilPub*/)
                    cSql += " ) CONTADOR"

                    ljGrvLog(/*cNumControl*/, "Consulta que retorna a quantidade de registros disponiveis para publicação:", cSql)
                    aSql := rmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

                    if len(aSql) > 0 .and. aSql[1][1] > 0

                        //Tratamento para não abrir uma thread para cada filial, dependendo da regra de compartilhamento da tabela
                        if aScan( aAux, {|x| x[2] == cFilPub} ) == 0
                            aAdd(aAux   , {aFilProc[nFil], cFilPub})
                            aAdd(aFilRet, aFilProc[nFil])
                        endIf
                    endIf

                next nFil
            endIf
        next nTabela

    endIf

    fwFreeArray(aTabelas)
    fwFreeArray(aAux)

    restArea(aArea)

Return aFilRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ultPublica
Retorna a data\hora da ultima publicação dos processos

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function ultPublica()

    Local aArea := getArea()
    Local cSql  := ""
    Local aSql  := {}

    cSql    := " SELECT MIN_CPROCE, MIN_FILPUB, MIN(MIN_ULTPUB) as MIN_ULTPUB"
    cSql    += " FROM " + RetSqlName("MIN")
    cSql    += " WHERE D_E_L_E_T_ = ' '"
    cSql    +=      " AND MIN_ULTPUB <> '" + space( tamSx3("MIN_ULTPUB")[1] ) + "'""
    cSql    += " GROUP BY MIN_CPROCE, MIN_FILPUB"

    aSql := rmiXSql(cSql, "*", /*lCommit*/, /*aReplace*/)

    restArea(aArea)

Return aSql

//-------------------------------------------------------------------
/*/{Protheus.doc} consulta
Retorna a query dos registros que devem ser publicados com base no processo, 
data da ultima publicação, recno e tabelas secundarias.

@author  Rafael tenorio da Costa 
@since 	 06/03/2026
@version 12.1.2510
/*/ 
//-------------------------------------------------------------------
Static Function consulta(aProcesso, cUltPublica, cCmpExp, lStamp, nUltREC, lOrderBy,cFilPub)

    Local cDB         := allTrim( upper( tcGetDB() ) )
    Local lSqlMenor16 := (cDB == "MSSQL" .And. getSqlVersao() < 16)
    Local cProcesso   := aProcesso[MHNCOD]
    Local cTabela     := aProcesso[MHNTABELA]
    Local cFiltro     := aProcesso[MHNFILTRO]
    Local cPrefixo    := IIF( subStr( cTabela, 1, 1) == "S", subStr( cTabela, 2), cTabela )
    Local cSelect     := ""
    Local cFrom       := ""
    Local cGreaTest   := "COALESCE(" + cTabela + ".S_T_A_M_P_," + IIf(cDb == "MSSQL", "'1900-01-01'", "TIMESTAMP '1900-01-01 00:00:00.000'") + ")"
    Local cGreatSec   := ""
    Local cLeftJoin   := ""
    Local cWhere      := ""   
    Local cOrderBy    := ""
    Local nTabSec     := 0
    Local cStampOri   := IIF(cDb == "MSSQL", "STAMP_ORIGEM", "TO_TIMESTAMP(TO_CHAR(STAMP_ORIGEM, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'YYYY-MM-DD HH24:MI:SS.FF3')")

    Default lStamp    := .T.
    Default nUltREC   := 0
    Default lOrderBy  := .T.
    Default cFilPub   := cFilAnt

    //Trata datetime da ultima publicação para comparação com o S_T_A_M_P_
    cUltPublica := allTrim(cUltPublica)
    if !empty(cUltPublica)
        if cDb == "MSSQL"
            cUltPublica := "'" + strTran(cUltPublica, " ", "T") + "'"
        else
            cUltPublica := "TIMESTAMP '" + cUltPublica + "'"
        endIf
    endIf

    //Verifica se o banco é MSSQL e a versão é inferior a 16 para tratar o GREATEST, porque versões anteriores não tem suporte
    If lSqlMenor16
        cGreaTest := "("+cGreaTest+")"
    EndIf
        
    //Inclui filtro pelas secundarias, caso existam
    For nTabSec := 1 To Len(aProcesso[MHSTABSECUNDARIAS])

        cTabelaSec := aProcesso[MHSTABSECUNDARIAS][nTabSec][MHSTABELA]
        cFiltroSec := aProcesso[MHSTABSECUNDARIAS][nTabSec][MHSFILTRO]

        //Indica que é para considerar as secundárias para a publicação
        //MIL não considera porque é gerada antes da principal (funções do processo de produto)
        If aProcesso[MHSTABSECUNDARIAS][nTabSec][MHSCONPUB] $ "1|3" .And. cTabelaSec <> "MIL"
            
            if temStamp(cTabelaSec)

                cGreatSec := "COALESCE(" + cTabelaSec + ".MAX_STAMP, "+IIf(cDb == "MSSQL","'1900-01-01'","TIMESTAMP '1900-01-01 00:00:00.000'")+")"

                //Verifica se o banco é MSSQL e a versão é inferior a 16 para tratar o GREATEST, porque versões anteriores não tem suporte
                If lSqlMenor16
                    cGreatSec := "("+cGreatSec+")"
                EndIf
                cGreaTest += ", "+cGreatSec

                cLeftJoin += IIF(cDB == "MSSQL", " OUTER APPLY", " LEFT JOIN LATERAL")
                cLeftJoin +=  " ( SELECT MAX(S_T_A_M_P_) MAX_STAMP FROM " + RetSqlName(cTabelaSec) + " " + cTabelaSec 

                cLeftJoin +=    " WHERE " 

                //Filtro de relacionamento com a tabela principal
                cLeftJoin +=        retJoin(aProcesso[MHSTABSECUNDARIAS][nTabSec], /*cCab*/, /*cSec*/, cTabela, /*cTabSec*/)

                //Filtra stamp >= nas secundarias para não ter que incluir o recno da principal e ser mais performático, recno é aplicado no where principal caso exista
                if !empty(cUltPublica)
                    cLeftJoin +=    " AND " + cTabelaSec + ".S_T_A_M_P_ >= " + cUltPublica
                endIf

                //Filtro da secundaria
                if SubStr(cFiltroSec, 1, 1) == "&"
                    cFiltroSec := &( allTrim( subStr(cFiltroSec, 2) ) )
                endIf
                cLeftJoin += iif( !empty(cFiltroSec), " AND " + cFiltroSec, "")

                cLeftJoin +=  " ) " + cTabelaSec + IIF(cDB == "MSSQL", "", " ON 1=1")
                
            Else
                LjGrvLog(cStFonte, "Campo de controle S_T_A_M_P_ não esta presente na tabela " + cTabelaSec )
                LjGrvLog(cStFonte, "Não será gerada publicação para o processo " + cProcesso + ", considerando a tabela secundária " + cTabelaSec)
            EndIf 

        Else
            LjGrvLog(cStFonte, " A tabela " + cTabelaSec + " não é considerada para a publicação do processo " + cProcesso)
        EndIf

    Next nTabSec

    //Tratamento de macro execução
    If SubStr(cFiltro, 1, 1) == "&"
        cFiltro := &( AllTrim( SubStr(cFiltro, 2) ) )
    EndIf

    cSelect :=  "SELECT "
    cSelect +=          IIF(cDB == "MSSQL"   , "CONVERT(VARCHAR(23), STAMP_ORIGEM, 21)"            ,;
                        IIF(cDB == "POSTGRES", "TO_CHAR(STAMP_ORIGEM, 'YYYY-MM-DD HH:MI:SS.MS')"   ,;
                        IIF(cDB == "ORACLE"  , "TO_CHAR(STAMP_ORIGEM, 'YYYY-MM-DD HH24:MI:SS.FF6')",;
                        "S_T_A_M_P_") ) )
    cSelect +=      " STAMP,"
    cSelect +=      " REGISTRO"

    cFrom :=    " FROM ("
    cFrom +=        " SELECT "
    cFrom +=            cTabela + ".R_E_C_N_O_ REGISTRO, "

    //Verifica se o banco é MSSQL e a versão é inferior a 16 para tratar o GREATEST, porque versões anteriores não tem suporte
    if lSqlMenor16
        cFrom +=            "(SELECT MAX(data) FROM (VALUES " + cGreaTest + " ) AS STAMPS(data)) AS STAMP_ORIGEM"
    else
        cFrom +=            "GREATEST( " + cGreaTest + " ) STAMP_ORIGEM"
    endIf
    
    cFrom +=        " FROM " + RetSqlName(cTabela) + " " + cTabela
    cFrom +=            cLeftJoin
    
    cFrom +=        " WHERE " + cPrefixo + "_FILIAL =  '" + xFilial(cTabela,cFilPub) + "'"
    cFrom +=            IIF(!Empty(cFiltro), " AND " + AllTrim(cFiltro), "")

    //Valida existencia do campo de controle de exportação
    If (cTabela)->( ColumnPos(cCmpExp) ) > 0
        cFrom += " AND " + cCmpExp + " <> 'PSH-INTE'"
    Else
        ljGrvLog("PUBLICAÇÃO", "Campo " + cCmpExp + " não existe, caso seu cadastro de assinante esteja utilizando busca e envio de um mesmo processo, pode ocorrer um loop infiníto. Exemplo: Processo de cliente busca e envia.")
    EndIf

    cFrom +=    " ) RESULTADO

    if lStamp .and. !empty(cUltPublica)

        cWhere += " WHERE ( "
        cWhere += cStampOri + " > " + cUltPublica

        If nUltREC > 0
            cWhere += " OR ( " + cStampOri + " = " + cUltPublica + " AND REGISTRO > " + cValToChar(nUltREC) + ")"
        EndIf 

        cWhere += " ) "
    endIf

    If lOrderBy
        cOrderBy := " ORDER BY STAMP_ORIGEM, REGISTRO"
        cOrderBy += " OFFSET 0 ROWS"
        cOrderBy += " FETCH NEXT " + cValToChar(nStTamQry) + " ROWS ONLY"
    EndIf

Return cSelect + cFrom + cWhere + cOrderBy

//-------------------------------------------------------------------
/*/{Protheus.doc} temStamp
Valida a existencia do campo S_T_A_M_P_, direto no banco de dados,
e ja carrega o resultado no array estatico para consultas posteriores.

@author  Rafael tenorio da Costa 
@since 	 13/06/2024
@version 12.1.2410
/*/ 
//-------------------------------------------------------------------
Static Function temStamp(cTabela)

    if ( nPos := aScan( aStTemSta, {|x| x[1] == cTabela} ) ) == 0

        aAdd( aStTemSta, {cTabela, (aScan( tcStruct( retSqlName(cTabela) ), {|x| x[1] == "S_T_A_M_P_"} ) > 0) } )

        nPos := len(aStTemSta)
    endIf

Return aStTemSta[nPos][2]

//-------------------------------------------------------------------
/*/{Protheus.doc} pshPubGrp
Efetua a publicação dos processos de um determinado grupo

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function pshPubGrp(cEmpAmb, cFilAmb, aProcGrupo)

    Local cSemaforo     := "pshPubGrp" +"_"+ cEmpAmb +"_"+ aProcGrupo[1]
    Local nCont         := 1
    Local cBkpFilial    := ""
    
    rpcSetType(3)
    rpcSetEnv(cEmpAmb, cFilAmb, /*cEnvUser*/, /*cEnvPass*/, "LOJA", "pshPubGrp")

    //Trava a execução para evitar que mais de uma sessão faça a execução.
    If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        rpcClearEnv()
        Return Nil
    EndIf

    cBkpFilial := cFilAnt

    for nCont:=1 to len(aProcGrupo[2])

        cFilAnt := aProcGrupo[2][nCont][1]
        shpPubSel(cEmpAnt, "", aProcGrupo[2][nCont][2])

    next nCont

    cFilAnt := cBkpFilial

    UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

    fwFreeArray(aProcGrupo)
    rpcClearEnv()

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} pendenteCarga
Processamento para ativação de nova loja

@author  Rafael Tenorio da Costa
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function pendenteCarga()

    Local aArea         := getArea()
    Local cSelect       := ""
    Local cTabela       := GetNextAlias()
    Local cSelectMIN    := ""    
    Local cTabelaMIN    := ""
    Local cFilMIH		:= ""
    Local cFilPub       := ""
    Local oLayEnv       := Nil
    Local nTamProce     := tamSx3("MIN_CPROCE")[1]
    Local cCadLoja      := padR("CADASTRO LOJA"   , nTamProce)
    Local nTamAssin     := tamSx3("MHP_CASSIN")[1]
    Local cCodAssin     := padr("PDVSYNC" , nTamAssin)    

	//Query que filtra lojas pendentes de carga
	cSelect := " SELECT R_E_C_N_O_ as REC FROM "+ retSqlName("MIH")
    cSelect += " WHERE D_E_L_E_T_ = ' '"
    cSelect +=      " AND MIH_FILIAL = '" + xFilial("MIH") + "'"
    cSelect +=      " AND MIH_ATIVO = '3'"                       //3=Pendente carga
    cSelect +=      " AND MIH_TIPCAD = '" + padR("CADASTRO DE LOJA", tamSx3("MIH_TIPCAD")[1]) + "'"

    cSelect := ChangeQuery(cSelect) 

    LjGrvLog("RMIPUBLICA", "Query que lista as lojas pendentes de carga:", cSelect)
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelect), cTabela, .T., .F.)

    if !(cTabela)->( eof() )
        
        cTabelaMIN  := GetNextAlias()

        Begin Transaction

            while !(cTabela)->(Eof())

                MIH->( dbGoTo( (cTabela)->REC ) )

                cFilMIH := LjCAuxRet("IDFilialProtheus")
                
                //Limpar a MIN
                //Query que filtra os processos para publicar nova carga para as lojas pendentes
                cSelectMIN := " SELECT MIN.R_E_C_N_O_ AS RECMIN FROM "+ retSqlName("MIN")+" MIN"
                cSelectMIN += " INNER JOIN "+retSqlName("MHP")+" MHP ON MIN_CPROCE = MHP_CPROCE"
                cSelectMIN += " WHERE MHP_CASSIN = '" + cCodAssin + "'"
                cSelectMIN += " AND MHP.D_E_L_E_T_ = ' '"
                cSelectMIN += " AND MIN.D_E_L_E_T_ = ' '"
                cSelectMIN += " AND MIN_FILIAL = '" + xFilial("MIN") + "'"
                cSelectMIN += " AND MIN_CPROCE NOT IN ('" + cCadLoja + "')" //Não retorno CADASTRO LOJA, não existe a necessidade de reenviar estes cadastros

                cSelectMIN := ChangeQuery(cSelectMIN) 

                LjGrvLog("RMIPUBLICA", "Query que lista todos os processos já publicados:", cSelectMIN)
                DbUseArea(.T., "TOPCONN", TcGenQry( , , cSelectMIN), cTabelaMIN, .T., .F.)

                while !(cTabelaMIN)->( Eof() )
                        
                    MIN->( dbGoTo( (cTabelaMIN)->RECMIN ) )

                    cFilPub := allTrim(MIN->MIN_FILPUB)

                    //Avalia se ja publicou algum dado que a nova loja deva receber, para apagar a MIN
                    if empty(cFilPub) .or. cFilPub == subStr(cFilMIH, 1, Len(cFilPub))
                        LjGrvLog("RMIPUBLICA", "Deleta controle de publicação na tabela MIN, MIN_CPROCE\MIN_FILPUB:", {MIN->MIN_CPROCE, MIN->MIN_FILPUB})

                        RecLock("MIN", .F.)
                            MIN->( dbDelete() )
                        MIN->( msUnLock() )
                    endIf
                    
                    (cTabelaMIN)->( dbSkip() )
                endDo
                (cTabelaMIN)->( dbCloseArea() )

                //Ativa loja
                LjGrvLog("RMIPUBLICA", "Ativando processamento de carga loja\filial:", {cFilMIH, MIH->( recno() )})
                RecLock("MIH", .F.)
                    MIH->MIH_ATIVO := "1"
                MIH->( msUnLock() )

                (cTabela)->( dbSkip() )
            endDo

            //Ativa a carga inicial nos processos, para controle de precedencia
            MHP->( dbSetOrder(1) )  //MHP_FILIAL, MHP_CASSIN, MHP_CPROCE, MHP_TIPO, R_E_C_N_O_, D_E_L_E_T_
            if MHP->( dbSeek( xFilial("MHP") + padR("PDVSYNC", tamSx3("MHP_CASSIN")[1]) ) )

                oLayEnv := JsonObject():new()

                while !MHP->( eof() ) .and. allTrim(MHP->MHP_CASSIN) == "PDVSYNC"

                    //Verifica se é processo de ENVIO e consegue popular o json
                    if MHP->MHP_TIPO == "1" .and. oLayEnv:fromJson(MHP->MHP_LAYENV) == nil

                        LjGrvLog("RMIPUBLICA", "Ativando o controle de cargaInicial para o processo:", {MHP->MHP_CPROCE, MHP->MHP_CASSIN})

                        if oLayEnv:hasProperty("configPSH")
                            oLayEnv["configPSH"]["cargaInicial"] := .T.
                        else
                            oLayEnv["configPSH"] := JsonObject():new()
                            oLayEnv["configPSH"]["Version"]      := "1.0"
                            oLayEnv["configPSH"]["cargaInicial"] := .T.
                        endIf

                        RecLock("MHP", .F.)
                            MHP->MHP_LAYENV := oLayEnv:toJson()
                        MIH->( msUnLock() )
                    endIf
                
                    MHP->( dbSkip() )
                endDo

                fwFreeObj(oLayEnv)
            endIf

        End Transaction

    endIf
    (cTabela)->( dbCloseArea() )

    restArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} iniciaBulk
Inicia a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function iniciaBulk()

    Local aStStrBulk := {}  //Struct MHQ utilizado no fwBulk

    //O array de extrutura (aStStrBulk) deve estar na mesma ordem da inclusão do registro no fwBulk (oStBulk:addData)
    aAdd( aStStrBulk, {"MHQ_FILIAL" })
    aAdd( aStStrBulk, {"MHQ_ORIGEM" })
    aAdd( aStStrBulk, {"MHQ_CPROCE" })
    aAdd( aStStrBulk, {"MHQ_EVENTO" })
    aAdd( aStStrBulk, {"MHQ_CHVUNI" })
    aAdd( aStStrBulk, {"MHQ_MENSAG" })
    aAdd( aStStrBulk, {"MHQ_DATGER" })
    aAdd( aStStrBulk, {"MHQ_HORGER" })
    aAdd( aStStrBulk, {"MHQ_STATUS" })
    aAdd( aStStrBulk, {"MHQ_UUID"   })
    aAdd( aStStrBulk, {"MHQ_IDEXT"  })

    oStBulk := fwBulk():New(retSqlName("MHQ"), nStTamBulk)
    oStBulk:setFields(aStStrBulk)

    fwFreeArray(aStStrBulk)

    ljGrvLog("Bulk", "Iniciada inclusão de registros por fwBulk.")

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaBulk
Commita a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function gravaBulk()

    Local cErro := ""

    oStBulk:flush()

    cErro := oStBulk:getError()
    if !empty(cErro)
        ljxjMsgErr("Erro ao efetuar a publicação utilizando fwBulk: " + cErro, /*cSolucao*/, "gravaBulk", aMINAux)
    endIf

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} finalizaBulk
Finaliza a gravação por fwBulk

@author  Rafael Tenorio da Costa
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function finalizaBulk()

    oStBulk:close()
    oStBulk:destroy()

    fwFreeObj(oStBulk)
    
    ljGrvLog("Bulk", "Finalizada inclusão de registros por fwBulk.")

return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} camposEnviados
Retorna os campos enviados pela integração relacionados a uma tabela

@type    Function
@author  Evandro Pattaro
@since   23/10/25
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function camposEnviados(cTabela, lExecTrim)

    Local oRegex    := nil
    Local cRetorno  := "*"
    Local lRetorno  := .F.
    Local aTokens   := {}
    Local aIndexes  := {}
    Local cPattern  := ""
    Local cCampo    := ""
    Local nI        := 0
    Local cLayouts  := ""
    Local aAux      := {}
    Local aTcStruct := {}
    Local aCmpsEsp  := {"D_E_L_E_T_", "R_E_C_N_O_", "R_E_C_D_E_L_", "S_T_A_M_P_", "I_N_S_D_T_"}

    Default lExecTrim   := .F.
    
    if !oStCmpsEnv:get(cTabela, @cRetorno)

        //Carrega todos os layouts de envio do processo       
        //MHPT103 MHP_FILIAL, MHP_CPROCE, MHP_TIPO, MHP_ATIVO, R_E_C_N_O_, D_E_L_E_T_
        MHP->( dbSetOrder(3) )
        If MHP->( dbSeek( xFilial("MHP") + cStProcesso + "11" ) )

            while !MHP->( eof() ) .and. MHP->MHP_FILIAL == xFilial("MHP") .and. MHP->MHP_CPROCE == cStProcesso .and. MHP->MHP_TIPO == "1" .and. MHP->MHP_ATIVO == "1"
                if !empty(MHP->MHP_LAYENV)
                    cLayouts += allTrim(MHP->MHP_LAYENV)
                endIf

                MHP->( dbSkip() )
            endDo

            If Substr(cTabela,1,1) == "S"
                cCampo := Substr(cTabela, 2)
            Else
                cCampo := cTabela
            EndIf
            
            //Validar a expressão regular: https://regex101.com/
            cPattern := "\b"+cCampo+"_[A-Z0-9_]+\b"
                        
            oRegex := tlpp.regex.Regex():new(cPattern) 

            lRetorno := oRegex:tokenizer(cLayouts, aTokens, aIndexes) //Retorna o array com os campos encontrados

            if lRetorno .and. len(aTokens) > 0

                cRetorno := ""

                for nI:=1 to len(aTokens)
                    //Remove os colchetes e aspas simples
                    aTokens[nI] := strTran( strTran(aTokens[nI], "['", "") , "']","")
                    
                    //Verifica se o campo já foi incluído no array de retorno
                    if (cTabela)->(FieldPos(aTokens[nI])) > 0 .And. aScan(aAux,{|x| x == aTokens[nI]}) == 0
                        aAdd(aAux, aTokens[nI])
                        if lExecTrim .and. tamSx3(aTokens[nI])[3] $ "C|M"
                            if cStBanco == "MSSQL"
                                cRetorno += "TRIM(" + aTokens[nI] + ") AS " + aTokens[nI] + ", "
                            else
                                cRetorno += "'" + aTokens[nI] + "' VALUE NVL(TRIM(" + aTokens[nI] + "), ' '), "
                            endIf
                        else
                            cRetorno += aTokens[nI] + ", "
                        endIf
                    endIf
                next nI

                //Inclui os campos especiais
                aTcStruct := tcStruct( retSqlName(cTabela) )
                for nI:=1 to len(aCmpsEsp)
                    if aScan( aTcStruct, {|x| x[1] == aCmpsEsp[nI]} ) > 0
                        if lExecTrim .and. aCmpsEsp[nI] == "D_E_L_E_T_"
                            if cStBanco == "MSSQL"
                                cRetorno += "TRIM(D_E_L_E_T_) AS D_E_L_E_T_, "
                            else
                                cRetorno += "'D_E_L_E_T_' VALUE NVL(TRIM(D_E_L_E_T_), ' '), "
                            endIf
                        else
                            cRetorno += aCmpsEsp[nI] + ", "
                        endIf
                    endIf
                next nI

                cRetorno := SubStr(cRetorno, 1, Len(cRetorno) - 2)
            endIf
        endIf

        oStCmpsEnv:set(cTabela, cRetorno)

        fwFreeArray(aTokens)
        fwFreeArray(aAux)
        fwFreeArray(aTcStruct)
        fwFreeArray(aCmpsEsp)
        fwFreeObj(oRegex)
    endIf

    LjGrvLog(/*cNumControl*/, "Campos que serão utilizados na consulta do registros publicado:", cRetorno)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} getSqlVersao
Retornar a versão do banco de dados MSSQL

@author  Rafael Tenorio da Costa
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Static Function getSqlVersao()

    Local nVersao := 0
    Local cTabela := ""
    
    cTabela := mpSysOpenQuery("SELECT CONVERT(VARCHAR,SERVERPROPERTY('PRODUCTVERSION')) VERSAO", /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)
    nVersao := val( (cTabela)->VERSAO )
    (cTabela)->( dbCloseArea() )

Return nVersao

//-------------------------------------------------------------------
/*/{Protheus.doc} carStaticas
Carrega variáveis estáticas utilizadas no processo de publicação.

@type    Static Function
@param   aProcesso, Array, Dados do processo corrente de publicação
@return  Nil, Nulo
@author  Rafael Tenorio da Costa
@since   17/06/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Static Function carStaticas(aProcesso)

    //Carrega staticas
    aStProcesso := aProcesso
    cStProcesso := padR( aStProcesso[MHNCOD], tamSx3("MHN_COD")[1] )
    oStCmpsEnv  := tHashMap():New()
    oStRelMih   := tHashMap():New()
    lStCargaIni := MIN->( columnPos("MIN_CARGA") ) > 0
    cStBanco    := allTrim( upper( tcGetDB() ) )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} geraJsonSql
Gera o Json de publicação por SQL, considerando tabela principal e secundárias.

@type    Static Function
@param   nRecno, Numerico, Recno do registro da tabela principal
@return  Caracter, Json da publicação
@author  Rafael Tenorio da Costa
@since   06/08/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Static Function geraJsonSql(nRecno)

    Local cQuery        := ""
    Local cTabela       := ""
    Local cJson         := ""
    Local cTabelaPri    := aStProcesso[MHNTABELA]
    Local aTabelaSec    := ""
    Local cTabelaSec    := ""
    Local cAliasSec     := ""
    Local cCamposSec    := ""
    Local cTipoSec      := ""
    Local nCont         := 1

    //Incluindo a tabela PRINCIPAL (MHNTABELA)    
    if cStBanco == "MSSQL"
        cQuery += "SELECT TRIM( CONVERT( VARCHAR(MAX), (SELECT "
    else
        cQuery += "SELECT JSON_OBJECT( "
    endIf
    cQuery += camposEnviados(cTabelaPri, .T.) + ", "
    
    //Incluindo as tabelas SECUNDARIAS (MHSTABSECUNDARIAS)
    for nCont:=1 to len( aStProcesso[MHSTABSECUNDARIAS] )

        aTabelaSec  := aStProcesso[MHSTABSECUNDARIAS][nCont]
        cTabelaSec  := aTabelaSec[MHSTABELA]
        cTipoSec    := allTrim( aTabelaSec[MHSTIPO] )
        cAliasSec   := cTabelaSec + iif( !empty(cTipoSec), "_" + cTipoSec, "" )
        cCamposSec  := camposEnviados(cTabelaSec, .T.)

        //"*" quer dizer que não existe campo da tabela no layout de envio, então não precisa montar a subquery
        if cCamposSec <> "*"

            if cStBanco == "MSSQL"

                cQuery += " ISNULL( ("
                cQuery +=       " SELECT " + cCamposSec

                //Campos adicionais para o FECP da tabela MIH campo json MIH_CONFIG
                if cTipoSec == "FECP"
                    cQuery += mihCfgFecp("1")
                endIf

                cQuery +=       " FROM " + retSqlName(cTabelaSec) + " " + cTabelaSec
                
                //Tratamento para extrair campos adicionais para o FECP da tabela MIH campo json MIH_CONFIG
                if cTipoSec == "FECP"
                    cQuery += mihCfgFecp("2")
                endIf

                cQuery +=       " WHERE " + retFiltroSec(cTabelaPri, aTabelaSec)
                cQuery +=           " AND " + retJoin(aTabelaSec, /*cCab*/, /*cSec*/, cTabelaPri, /*cTabSec*/)
                cQuery +=       " FOR JSON PATH), '[]') AS '" + cAliasSec + "', "
            else

                cQuery += " '" + cAliasSec + "' VALUE NVL( ("
                cQuery +=       " SELECT JSON_ARRAYAGG( JSON_OBJECT( " + cCamposSec
                
                //Campos adicionais para o FECP da tabela MIH campo json MIH_CONFIG
                if cTipoSec == "FECP"
                    cQuery += mihCfgFecp("1") + " FORMAT JSON"
                endIf
                
                cQuery +=           " ) )"
                cQuery +=       " FROM " + retSqlName(cTabelaSec) + " " + cTabelaSec

                //Tratamento para extrair campos adicionais para o FECP da tabela MIH campo json MIH_CONFIG
                if cTipoSec == "FECP"
                    cQuery += mihCfgFecp("2")
                endIf

                cQuery +=       " WHERE " + retFiltroSec(cTabelaPri, aTabelaSec)
                cQuery +=           " AND " + retJoin(aTabelaSec, /*cCab*/, /*cSec*/, cTabelaPri, /*cTabSec*/)
                cQuery +=       " ), '[]' ) FORMAT JSON, "
            endIf
        endIf
                
    next nCont
    cQuery := subStr(cQuery, 1, len(cQuery) - 2)
    
    //Fechamento da função para gerar JSON do ORACLE
    if cStBanco == "ORACLE"
	    cQuery += " ) AS JSON_RETORNO"
    endIf

    cQuery += " FROM " + retSqlName(cTabelaPri) + " " + cTabelaPri
    cQuery += " WHERE " + cTabelaPri + ".R_E_C_N_O_ = " + cValToChar(nRecno)

    //Fechamento da função para gerar JSON do SQL
    if cStBanco == "MSSQL"
        cQuery += " FOR JSON PATH, WITHOUT_ARRAY_WRAPPER) ) ) AS JSON_RETORNO"
    endIf
    
    ljGrvLog(/*cNumControl*/, "Consulta que retorna o json da publicação:", cQuery)
    cTabela := mpSysOpenQuery(cQuery, /*cAlias*/, /*aSetField*/, /*cDriver*/, /*aBindParam*/)
    
    if !(cTabela)->( eof() )
        cJson := allTrim( (cTabela)->JSON_RETORNO )
    endIf
    
    (cTabela)->( dbCloseArea() )
    
Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} retFiltroSec
Retorna o filtro SQL aplicado na tabela secundária para geração do Json.

@type    Static Function
@param   cTb, Caracter, Tabela principal
@param   aTb, Array, Estrutura da tabela secundária no processo
@return  Caracter, Filtro SQL da tabela secundária
@author  Rafael Tenorio da Costa
@since   06/08/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Static Function retFiltroSec(cTb, aTb)

    Local cFiltroSec    := ""
    Local aAux          := {}
    Local cFilter       := ""
    Local cTabelaSec    := aTb[MHSTABELA]

    //Concatena na query o filtro da tabela filha
    If !empty(aTb[MHSFILTRO])
        //Tratamento de macro execução
        cFilter := aTb[MHSFILTRO]
        If SubStr(cFilter, 1, 1) == "&"
            cFilter := &( AllTrim( SubStr(cFilter, 2) ) )
        EndIf
        cFiltroSec := AllTrim( cFilter) + " AND "
    EndIf

    If "D_E_L_E_T_" $ cFiltroSec
        cFiltroSec := StrTran(cFiltroSec, "D_E_L_E_T_", cTabelaSec + ".D_E_L_E_T_")
    Else
        cFiltroSec += cTabelaSec + ".D_E_L_E_T_ = ' ' AND "
    EndIf

    cFiltroSec := subStr(cFiltroSec, 1, len(cFiltroSec) - 5)

    fwFreeArray(aAux)

return cFiltroSec

//-------------------------------------------------------------------
/*/{Protheus.doc} mihCfgFecp
Retorna os campos adicionais para o FECP da tabela MIH campo json MIH_CONFIG 
e modo para extração destes campos

@type    Static Function
@param   cTipo, Caracter, Tipo de configuração
@return  Caracter, Parte da query SQL para extração dos campos adicionais do FECP da tabela MIH campo json MIH_CONFIG
@author  Rafael Tenorio da Costa
@since   20/08/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
function mihCfgFecp(cTipo)

    Local cQuery := ""

    //Campos
    if cTipo == "1"

        if cStBanco == "MSSQL"

            cQuery += ","
            cQuery += " ISNULL(MIH_CONFIG.IT_ALIQFECP, 0 ) AS IT_ALIQFECP,"
            cQuery += " ISNULL(MIH_CONFIG.IT_BASFECP , 0 ) AS IT_BASFECP,"
            cQuery += " ISNULL(MIH_CONFIG.IT_CODDECL , '') AS IT_CODDECL,"
            cQuery += " ISNULL(MIH_CONFIG.LF_MOTICMS , '') AS LF_MOTICMS,"
            cQuery += " ISNULL(MIH_CONFIG.descontaDesoneracaoNf, CAST(0 AS BIT)) AS descontaDesoneracaoNf"

        else

            cQuery += ","
            cQuery += " 'IT_ALIQFECP'           VALUE NVL(MIH_CONFIG.IT_ALIQFECP, 0  ),"
            cQuery += " 'IT_BASFECP'            VALUE NVL(MIH_CONFIG.IT_BASFECP , 0  ),"
            cQuery += " 'IT_CODDECL'            VALUE NVL(MIH_CONFIG.IT_CODDECL , ' '),"
            cQuery += " 'LF_MOTICMS'            VALUE NVL(MIH_CONFIG.LF_MOTICMS , ' '),"
            cQuery += " 'descontaDesoneracaoNf' VALUE NVL(MIH_CONFIG.descontaDesoneracaoNf, 'false')"
        endIf

    //From
    else

        if cStBanco == "MSSQL"

            cQuery += " OUTER APPLY ("
            cQuery +=   " SELECT"
            cQuery +=       " CAST(MAX(CASE WHEN JSON_VALUE(comp.value, '$.IdComponent') = 'IT_ALIQFECP' THEN JSON_VALUE(comp.value, '$.ComponentContent') END) AS FLOAT) AS IT_ALIQFECP,"
            cQuery +=       " CAST(MAX(CASE WHEN JSON_VALUE(comp.value, '$.IdComponent') = 'IT_BASFECP' THEN JSON_VALUE(comp.value, '$.ComponentContent') END) AS FLOAT) AS IT_BASFECP,"
            cQuery +=       " MAX(CASE WHEN JSON_VALUE(comp.value, '$.IdComponent') = 'IT_CODDECL' THEN JSON_VALUE(comp.value, '$.ComponentContent') END) AS IT_CODDECL,"
            cQuery +=       " MAX(CASE WHEN JSON_VALUE(comp.value, '$.IdComponent') = 'LF_MOTICMS' THEN JSON_VALUE(comp.value, '$.ComponentContent') END) AS LF_MOTICMS,"
            cQuery +=       " CAST(MAX(CASE WHEN JSON_VALUE(comp.value, '$.IdComponent') = 'descontaDesoneracaoNf' THEN"
            cQuery +=                   " CASE WHEN JSON_VALUE(comp.value, '$.ComponentContent') = 'true' THEN 1 ELSE 0 END"
            cQuery +=               " END) AS BIT) AS descontaDesoneracaoNf"
            cQuery += " FROM " + retSqlName("MIHT10") + " MIH"
            cQuery +=       " CROSS APPLY OPENJSON(MIH.MIH_CONFIG, '$.Components') comp"
            cQuery += " WHERE MIH.D_E_L_E_T_ = ' '"
            cQuery +=       " AND MIH.MIH_FILIAL = '" + xFilial("MIH") + "'"
            cQuery +=       " AND MIH.MIH_TIPCAD = 'FECP'"
            cQuery +=       " AND MIH.MIH_ID     = MIL.MIL_SAIDA"
            cQuery += " ) MIH_CONFIG"
            
        else

            cQuery += " LEFT JOIN ("
            cQuery +=   " SELECT"
            cQuery +=       " MIH.MIH_ID,"
            cQuery +=       " MAX(CASE WHEN comp.IdComponent = 'IT_ALIQFECP' THEN TO_NUMBER(comp.ComponentContent) END) AS IT_ALIQFECP,"
            cQuery +=       " MAX(CASE WHEN comp.IdComponent = 'IT_BASFECP'  THEN TO_NUMBER(comp.ComponentContent) END) AS IT_BASFECP,"
            cQuery +=       " MAX(CASE WHEN comp.IdComponent = 'IT_CODDECL'  THEN comp.ComponentContent END) AS IT_CODDECL,"
            cQuery +=       " MAX(CASE WHEN comp.IdComponent = 'LF_MOTICMS'  THEN comp.ComponentContent END) AS LF_MOTICMS,"
            cQuery +=       " MAX(CASE WHEN comp.IdComponent = 'descontaDesoneracaoNf' THEN "
            cQuery +=               " CASE WHEN comp.ComponentContent = 'true' THEN 'true' ELSE 'false' END"
            cQuery +=           " END) AS descontaDesoneracaoNf"
            cQuery +=   " FROM " + retSqlName("MIHT10") + " MIH"
            cQuery +=   " CROSS JOIN JSON_TABLE(MIH.MIH_CONFIG, '$.Components[*]'"
            cQuery +=       " COLUMNS ("
            cQuery +=           " IdComponent      VARCHAR2(100) PATH '$.IdComponent',"
            cQuery +=           " ComponentContent VARCHAR2(100) PATH '$.ComponentContent'"
            cQuery +=       " )"
            cQuery +=   " ) comp"
            cQuery +=   " WHERE MIH.D_E_L_E_T_ = ' '"
            cQuery +=       " AND MIH.MIH_FILIAL = '" + xFilial("MIH") + "'"
            cQuery +=       " AND MIH.MIH_TIPCAD = 'FECP'"
            cQuery +=   " GROUP BY MIH.MIH_ID"
            cQuery += " ) MIH_CONFIG ON MIH_CONFIG.MIH_ID = MIL.MIL_SAIDA"

        endIf
    endIf

return cQuery
