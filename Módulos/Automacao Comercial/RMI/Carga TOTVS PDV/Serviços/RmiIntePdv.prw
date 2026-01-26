#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RMIINTEPDV.CH'
#INCLUDE "TRYEXCEPTION.CH"

Static oJson            := Nil
Static oJsonRet         := Nil
Static cMsgErro         := ""
Static lContinua        := .T.
Static cTabela          := ""
Static cChave           := ""
Static cAlias           := ""
Static aConfig          := {}
Static lLogInteg        := .F.
Static lExclusao        := .F.
Static nTimeOutRest     := 60
Static lLogCliCfg       := !Empty(AllTrim(GetPvProfString( "LogClient"  , "server", "", GetAdv97() )))
Static aStStruc         := {}

/*/{Protheus.doc} RmiIntePdv
    Função principal do JOB que faz a integração dos dados com a retaguarda.
    @type  Function
    @author Bruno Almeida
    @since 29/02/2024
    @version P12
    @param cEmp, caractere, Empresa
    @param cFil, caractere, Filial
    @param cPontoCarg, caractere, Código do ponto de integração
    @param cGrupo, caractere, Código dos grupos de tabelas
    @param cLog, caractere, Parâmetro para habilitar o log da integração no recebimento dos dados
    @param cTempoMax, caractere, Tempo que a thread permanece ativa
    @return Nil
/*/
Function RmiIntePdv(cEmp, cFil, cPontoCarg, cGrupo, cLog, cTempoMax)

Local cHoraInicio   := Time()
Local cTime         := ""
Local cSemaforo     := ""

Default cEmp        := ""
Default cFil        := ""
Default cPontoCarg  := ""
Default cGrupo      := ""
Default cLog        := "0"
Default cTempoMax   := "00:10:00"

lLogInteg := cLog == "1"

If !Empty(cEmp) .AND. !Empty(cFil) .AND. !Empty(cPontoCarg) .AND. !Empty(cGrupo) 

    //Limita a 15m para a thread não ficar muito tempo sem desativar e limpar a memoria
    if cTempoMax > "00:15:00"
        cTempoMax := "00:15:00"
    endIf

    RPCSetType(3)
    RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")

    //Trava a execução para evitar mais de uma sessão ao mesmo tempo
    cSemaforo := "RMIINTEPDV" +"_"+ cFil +"_"+ cPontoCarg +"_"+ cGrupo
    if !lockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
        ljxjMsgErr( I18n(STR0049, {cSemaforo}) )    //"Serviço #1 já esta sendo utilizado por outra instância."
        rpcClearEnv()
        return Nil
    endIf

    While ElapTime(cHoraInicio, Time()) <= cTempoMax

        LogIntegra(STR0023 + cPontoCarg + STR0045 + cGrupo + STR0027 + FWTimeStamp(2)) //"Inicio da rotina de integração de dados Central PDV / TOTVS PDV - Ponto de Integração: " # " - Grupos: " # " - Data e Hora: "

        lContinua   := .T.
        cMsgErro    := ""
        oJsonRet    := JsonObject():New()
        oJson       := JsonObject():New()
        aConfig     := Array(6)
        lExclusao   := .F.

        getToken()

        If lContinua
            cTime := Time()
            // -- Acessa a API de Integração e faz um Get para trazer os registros que serão atualizados no ambiente.
            getInteg(cEmp, cFil, cPontoCarg, cGrupo)

            If lContinua
                If oJson["CodigoRetorno"] == "01"
                    
                    oJsonRet["EmpresaPC"]   := cEmp
                    oJsonRet["FilialPC"]    := cFil
                    oJsonRet["CodigoPC"]    := cPontoCarg
                    oJsonRet["RegistrosErro"]    := {} 
                    oJsonRet["RegistrosSucesso"]  := ""                

                    // -- Primeiro processo importa todos os registros de inclusão/alteração
                    LogIntegra("RmiIntePdv | Antes da chamada da função ImportaDados | " + FWTimeStamp(2))
                    ImportaDados()
                    LogIntegra("RmiIntePdv | Depois da chamada da função ImportaDados | " + FWTimeStamp(2))

                    // -- Por último atualiza o status dos registros na retaguarda.
                    LogIntegra("RmiIntePdv | Antes da chamada da função AtlzStatus | " + FWTimeStamp(2))
                    AtlzStatus()
                    LogIntegra("RmiIntePdv | Depois da chamada da função AtlzStatus | " + FWTimeStamp(2))                    
 
                Else                
                    Iif(ValType(oJson["Erro"]) == "C",LogIntegra(STR0001 + oJson["Erro"]),LogIntegra(STR0001)) //"Retorno da API - "
                EndIf

            Else
                LogIntegra(cMsgErro)
            EndIf

            LogIntegra("RmiIntePdv: Tempo do processo getInteg + ImportaDados + AtlzStatus : " + ElapTime(cTime, Time()))
        Else
            LogIntegra(cMsgErro)
        EndIf

        LogIntegra(STR0024 + cPontoCarg + STR0045 + cGrupo + STR0027 + FWTimeStamp(2)) //"Final da rotina de integração de dados Central PDV / TOTVS PDV - Ponto de Integração: " # " - Grupos: " # " - Data e Hora: "

        FwFreeObj(oJsonRet)
        FwFreeObj(oJson)
        FwFreeArray(aConfig)

        oJsonRet    := Nil
        oJson       := Nil

        sleep(1000)
    EndDo

    //Libera semaforo de controle
    unLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

    LogIntegra("RmiIntePdv | Fim  da rotina de integração de dados Central PDV / TOTVS PDV - Ponto de Integração: " + cPontoCarg + " Grupo " + cGrupo + " | " + FWTimeStamp(2))
    RpcClearEnv()
    
Else
    LogIntegra(STR0002) //"Por favor, verifique se foram informados os parâmetros do JOB RmiIntePdv: Empresa, Filial, Ponto de Integração e Grupo de tabelas"
EndIf

fwFreeArray(aStStruc)

Return Nil


/*/{Protheus.doc} getInteg
    Função que faz um Get na API da integração para retornar todos os registros pendentes de atualização/inclusão/exclusão
    @type  Function
    @author Bruno Almeida
    @since 29/02/2024
    @version P12
    @param cEmp, caractere, Empresa
    @param cFil, caractere, Filial
    @param cPontoCarg, caractere, Código do ponto de integração
    @param cGrupo, caractere, Código dos grupos de tabelas
    @return Nil
/*/
Static Function getInteg(cEmp, cFil, cPontoCarg, cGrupo)

Local oGet      := Nil 
Local cEndPoint := AllTrim(aConfig[5])
Local nContador := 1
Local cPath     := ""
Local cTime     := ""

If !Empty(cEndPoint)

    If SubStr(cEndPoint, Len(cEndPoint), 1) == "/"
        cEndPoint := SubStr(cEndPoint, 1, Len(cEndPoint) - 1)
    EndIf

    If !Empty(aConfig[1])
        oGet    := FWRest():New(cEndPoint)
        cPath   := "/api/retail/v1/integrapdv/IntegracaoTotvsPdv?CodPontoInteg=" + AllTrim(cPontoCarg) + "&EmpresaPC=" + AllTrim(cEmp) + "&FilialPC=" + StrTran(AllTrim(cFil)," ", "+") + "&GruposInteg=" + AllTrim(cGrupo)

        oGet:SetPath( cPath )
        oGet:SetTimeOut(nTimeOutRest)

        LogIntegra("GET na API: " + cEndPoint + cPath + STR0027 + FWTimeStamp(2))
        cTime := Time()

        While nContador <= 3

            If oGet:Get({"Content-Type: application/json", "Authorization: Bearer " + aConfig[1]})                
                oJson:FromJson(oGet:GetResult())
                nContador := 4
            Else
                If AllTrim(FwCutOff(oGet:GetLastError())) $ "Unauthorized"
                    //Se deu algum erro de autorização, pode ser problema no token, forço a geração de um novo token
                    GeraToken(1, cEndPoint, aConfig[3], aConfig[4], aConfig[2])
                    nContador := 4
                ElseIf AllTrim(FwCutOff(oGet:GetLastError())) $ "500 InternalServerError"
                    nContador++
                    Sleep(1000)
                    If nContador == 4
                        lContinua   := .F.
                        cMsgErro    := STR0003 + oGet:GetLastError() //"Não foi possivel fazer a busca dos dados da integração na retaguarda acessando a API. Erro: "                    
                    EndIf
                Else
                    nContador   := 4
                    lContinua   := .F.
                    cMsgErro    := STR0003 + oGet:GetLastError() + IIF(ValType(oGet:GetResult()) == "C", " - " + oGet:GetResult(),"") //"Não foi possivel fazer a busca dos dados da integração na retaguarda acessando a API. Erro: "
                EndIf
            EndIf

        End

        LogIntegra("Operacao: GET - Api: " + cPath + " - Tempo: " + ElapTime(cTime, Time()))
    Else
        GeraToken(0, cEndPoint, aConfig[3], aConfig[4], aConfig[2])
    EndIf
Else
    lContinua   := .F.
    cMsgErro    := STR0004 //"Não foi informado o endereço do serviço REST nas configurações do assinante TOTVS PDV."
EndIf

FwFreeObj(oGet)
oGet := Nil

Return Nil

/*/{Protheus.doc} ImportaDados
    Função para fazer a leitura do Json e atualizar/incluir os dados na tabela do PDV
    @type  Function
    @author Bruno Almeida
    @since 04/03/2024
    @version P12
    @param
    @return Nil
/*/
Static Function ImportaDados()

Local nI        := 0
Local nX        := 0
Local nU        := 0
Local lInsert   := .T.
Local aStruct   := {}
Local cChaveTab := ""
Local oError    := Nil
Local cTime     := ""
Local lCtlRecno := .F.              // Controla por recno
Local nRecLocal := 0
Local cHoraIni  := TimeFull()
Local nStru     := 0

For nI := 1 To Len(oJson["Tabelas"])

    cTabela := oJson["Tabelas"][nI]["Tabela"]
    cChave  := oJson["Tabelas"][nI]["Chave"]

    LogIntegra(STR0047 + AllTrim(cTabela) + STR0048 + AllTrim(cChave) + STR0027 + FWTimeStamp(2)) //"Iniciando validação da tabela " # " e da chave " # " - Data e Hora: "

    If ValidChvTa("1", nI, cChave) .AND. ValidChvTa("2", nI, cChave)

        If !(cTabela $ 'SX6|SX5')

            lCtlRecno := AliasInDic("MIZ") .AND. AllTrim(cChave) == "R_E_C_N_O_"
            
            LogIntegra(STR0025 + cTabela + STR0026 + cValToChar(Len(oJson["Tabelas"][nI]["Registro"])) + STR0027 + FWTimeStamp(2)) //"Inicio da importação da tabela " # ", quantidade de registros para importar " # " - Data e Hora: "
            cTime := Time()

            dbSelectArea(cTabela)
        
            // -- Inclui dados ao campos com base na estrutura do array aStruct
            if ( nStru := aScan(aStStruc, {|x| x[1] == cTabela}) ) == 0
                aAdd( aStStruc, {cTabela, (cTabela)->( DbStruct() )} )
                nStru := len(aStStruc)
            endIf
            aStruct := aClone( aStStruc[nStru][2] )

            // -- Percorre cada registro da tabela
            For nX := 1 To Len(oJson["Tabelas"][nI]["Registro"])

                nRecLocal   := 0
                lInsert     := .T.
                cChaveTab   := ""
                cAlias      := ""

                TRY EXCEPTION

                    If lCtlRecno
                        // -- Controle pelo recno
                        nRecLocal   := 0
                        lInsert     := CtrlRecno(cTabela, oJson["Tabelas"][nI]["Registro"][nX]["Recno"], @nRecLocal)
                        cChaveTab   := " RECNO " + oJson["Tabelas"][nI]["Registro"][nX]["Recno"]

                        If !lInsert
                            // -- Se já existe, posiciona no registro
                            (cTabela)->(dbGoto( nRecLocal ))
                        EndIf
                    Else
                        // -- Pesquisa o registro para saber se existe ou não na base
                        cChaveTab := MontaQuery(oJson["Tabelas"][nI]["Registro"][nX])
                                    
                        If !(cAlias)->( Eof() )
                            lInsert := .F.
                            (cTabela)->(dbGoto((cAlias)->REC))
                        Else
                            lInsert := .T.
                        EndIf
                    EndIf

                    If !oJson["Tabelas"][nI]["Registro"][nX]["Del"]
                        If (cTabela)->(RecLock(cTabela,lInsert,,,IsBlind()))
                            LogIntegra(STR0028 + cChaveTab + STR0029 + cTabela + STR0027 + FWTimeStamp(2)) //"Inicio da inclusão/alteração do registro (" # ") da tabela " # " - Data e Hora: "
                            For nU := 1 To Len(aStruct)
                                If oJson["Tabelas"][nI]["Registro"][nX]:HasProperty(aStruct[nU][1])
                                    Do Case
                                        Case aStruct[nU][2] == "D"
                                            (cTabela)->&(aStruct[nU][1]) := SToD(oJson["Tabelas"][nI]["Registro"][nX][aStruct[nU][1]])
                                        OtherWise
                                            (cTabela)->&(aStruct[nU][1]) := oJson["Tabelas"][nI]["Registro"][nX][aStruct[nU][1]]
                                    EndCase                                    
                                EndIf
                            Next nU
                            (cTabela)->( MsUnLock() )

                            If lLogCliCfg .AND. oJson["Tabelas"][nI]["Registro"][nX]:HasProperty('STAMP')
                                LogMsg('RMIIntePDV', 23, 6, 1, '', '', '|Priority=23|Severity=6|Empresa=' + cEmpAnt + '|Filial=' + cFilAnt + '|Rotina=RMIIntePDV|Funcao=ImportaDados|Tabela=' + cTabela + '|Chave=' + StrTran( cChaveTab, " = ", ":" ) + '|HoraAlteracao=' + oJson["Tabelas"][nI]["Registro"][nX]['STAMP'] + '|HoraAtualizacao=' + FwTimeStamp(3) + '|Versao=' + GetRPORelease() + '|')
                            EndIf

                            If lCtlRecno .AND. lInsert
                                // Grava o recno na tabela de controle
                                CtrlRecno(cTabela, oJson["Tabelas"][nI]["Registro"][nX]["Recno"], (cTabela)->(Recno()))
                            EndIf
                            JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"2","")
                            LogIntegra(STR0030 + cChaveTab + STR0029 + cTabela + STR0027 + FWTimeStamp(2)) //"Final da inclusão/alteração do registro (" # ") da tabela " # " - Data e Hora: "
                        Else
                            JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"3",STR0013) //"Não foi possivel fazer o Lock no registro/tabela para efetuar a atualização/inclusão!"
                        EndIf
                    Else
                        lExclusao := .T.
                        LogIntegra(STR0034 + cChaveTab + STR0035) //"O registro ( " # " ) chegou com a TAG Del igual a True, sera excluído pela função ExcluiDados."
                    EndIf

                    If !lCtlRecno .or. ( !empty(cAlias) .and. select(cAlias) > 0 )
                        (cAlias)->( DbCloseArea() )
                        cAlias := ""
                    EndIf

                CATCH EXCEPTION USING oError
                    trataErro(oError, oJson["Tabelas"][nI]["Registro"][nX], cChaveTab)

                ENDTRY

            Next nX

            // -- Só entra na rotina de exclusão se no pacote existe algum registro para excluir.
            If lExclusao
                // -- Depois processa todas as exclusões de registros
                ExcluiDados(nI)
            EndIf

            LogIntegra(STR0031 + cTabela + STR0027 + FWTimeStamp(2)) //"Final da importação da tabela " # " - Data e Hora: "
            LogIntegra("Operacao: Incluir/Alterar/Excluir - Tabela: " + cTabela + " - Total de Registros: " + cValToChar(Len(oJson["Tabelas"][nI]["Registro"])) + " - Tempo: " + ElapTime(cTime, Time()))
            lExclusao := .F.
            (cTabela)->(DbCloseArea())


        Else
            If cTabela == "SX6"
                For nX := 1 To Len(oJson["Tabelas"][nI]["Registro"])
                    TRY EXCEPTION
                        LogIntegra(STR0037 + oJson["Tabelas"][nI]["Registro"][nX]["X6_VAR"] + STR0046 + oJson["Tabelas"][nI]["Registro"][nX]["X6_CONTEUD"] + STR0027 + FWTimeStamp(2)) //"Inicio da atualização do parâmetro " # " - Conteúdo: " # " - Data e Hora: "
                        PutMv(oJson["Tabelas"][nI]["Registro"][nX]["X6_VAR"],oJson["Tabelas"][nI]["Registro"][nX]["X6_CONTEUD"])
                        JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"2","")
                        LogIntegra(STR0038 + oJson["Tabelas"][nI]["Registro"][nX]["X6_VAR"] + STR0046 + oJson["Tabelas"][nI]["Registro"][nX]["X6_CONTEUD"] + STR0027 + FWTimeStamp(2)) //"Fim da atualização do parâmetro " # " - Conteúdo: " # " - Data e Hora: "
                    CATCH EXCEPTION USING oError
                        JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"3",oError:Description)
                        LogIntegra(STR0039 + oJson["Tabelas"][nI]["Registro"][nX]["X6_VAR"] + STR0040 + oError:Description + STR0027 + FWTimeStamp(2)) //"Erro na atualização do parâmetro " # " - Erro: " # " - Data e Hora: "
                    ENDTRY
                Next nX
            Else
                For nX := 1 To Len(oJson["Tabelas"][nI]["Registro"])
                    TRY EXCEPTION
                        LogIntegra(STR0041 + oJson["Tabelas"][nI]["Registro"][nX]["X5_TABELA"] + STR0042 + oJson["Tabelas"][nI]["Registro"][nX]["X5_CHAVE"] + STR0027 + FWTimeStamp(2)) //"Inicio da atualização da tabela SX5 - Tabela: " # " - Chave: " # " - Data e Hora: "
                        FwPutSX5(,oJson["Tabelas"][nI]["Registro"][nX]["X5_TABELA"],oJson["Tabelas"][nI]["Registro"][nX]["X5_CHAVE"],oJson["Tabelas"][nI]["Registro"][nX]["X5_DESCRI"],oJson["Tabelas"][nI]["Registro"][nX]["X5_DESCENG"],oJson["Tabelas"][nI]["Registro"][nX]["X5_DESCSPA"])
                        JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"2","")
                        LogIntegra(STR0043 + oJson["Tabelas"][nI]["Registro"][nX]["X5_TABELA"] + STR0042 + oJson["Tabelas"][nI]["Registro"][nX]["X5_CHAVE"] + STR0027 + FWTimeStamp(2)) //"Fim da atualização da tabela SX5 - Tabela: " # " - Chave: " # " - Data e Hora: "
                    CATCH EXCEPTION USING oError
                        JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"3",oError:Description)
                        LogIntegra(STR0044 + oJson["Tabelas"][nI]["Registro"][nX]["X5_TABELA"] + STR0042 + oJson["Tabelas"][nI]["Registro"][nX]["X5_CHAVE"] + STR0040 + oError:Description + STR0027 + FWTimeStamp(2)) //"Erro na atualização da tabela SX5 - Tabela: " # " - Chave: " # " - Erro: " # " - Data e Hora: "
                    ENDTRY
                Next nX
            EndIf
        EndIf
        
        fwFreeArray(aStruct)
    EndIf
    
Next nI

LogIntegra("RMIIntePDV | ImportaDados | Hora Inicial: " + cHoraIni + " Hora Final: " +  TimeFull())

Return Nil

/*/{Protheus.doc} MontaQuery
    Faz a montagem da query para consultar no banco de dados o registro que esta sendo importado
    @type  Function
    @author Bruno Almeida
    @since 07/03/2024
    @version P12
    @param jRegistro, objeto, Json com a tabela e chave a serem pesquisados 
    @return cWhere, caractere, Campos da chave com seus determinados registros
/*/
Static Function MontaQuery(jRegistro)

Local cQuery := ""
Local cWhere := RetCampChv(jRegistro)

cQuery := "SELECT R_E_C_N_O_ REC"
cQuery += "  FROM " + RetSqlName(cTabela)
cQuery += " WHERE " + cWhere
cQuery += "   AND D_E_L_E_T_ = ' '"

cAlias := GetNextAlias()
cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry2( , , cQuery,{}), cAlias, .T., .F.)

Return cWhere

/*/{Protheus.doc} RetCampChv
    Para cada campo da chave retorna o valor que esta no Json
    @type  Function
    @author Bruno Almeida
    @since 07/03/2024
    @version P12
    @param jRegistro, objeto, Json com a tabela e chave a serem pesquisados 
    @return cRet, caractere, complemento da query na clausula WHERE
/*/
Static Function RetCampChv(jRegistro)

Local cRet      := ""
Local aCampos   := StrTokArr(cChave, "+")
Local nI        := 0
Local cField    := ""

For nI := 1 To Len(aCampos)
    cField  := TrataCampo(aCampos[nI])
    cRet    += cField + " = " + IIF(TamSx3(cField)[3] $ "C|D", "'" + jRegistro[cField] + "'", jRegistro[cField]) + " AND "
Next nI

cRet := SubStr(cRet, 1, Len(cRet) - 5)

Return cRet

/*/{Protheus.doc} ValidChvTa
    Função responsavel apenas em validar se existem os campos da chave e a tabela no dicionario do ambiente local.
    @type  Function
    @author Bruno Almeida
    @since 07/03/2024
    @version P12
    @param cTipo, caractere, Se for tipo 1 então valida a tabela, se não valida a chave.
    @param nPos, numerico, Posição do registro da tabela no Json que chegou da API
    @return lContinua, logico, Retorna .F. se encontrou algum erro.
/*/
Static Function ValidChvTa(cTipo, nPos, cChave)

Local aCampos   := {}
Local nI        := 0
Local cErro     := ""
Local cField    := ""
Local lRet      := .T.

If !(cTabela $ "SX5|SX6") .AND. AllTrim(cChave) <> "R_E_C_N_O_"
    If cTipo == "1"
        If !FwSX2Util():SeekX2File( Upper(cTabela) )
            cErro   := STR0005 + cTabela + STR0006 //"A tabela " # " não existe na base, registros não foram atualizados!"
            lRet    := .F.
            LogIntegra(cErro) //"A tabela " # " não existe na base, registros não foram atualizados!"
            JsonRet("","3", cErro, nPos)
        EndIf
    Else
        If !Empty(cChave)
            aCampos := StrTokArr(cChave, "+")
            
            dbSelectArea(cTabela)
            For nI := 1 To Len(aCampos)
                cField := TrataCampo(aCampos[nI])
                If (cTabela)->(ColumnPos(cField)) == 0
                    cErro   := STR0007 + AllTrim(cField) + STR0008 + cTabela + STR0009 //"O campo " # " da tabela " # " não consta no dicionario."
                    lRet    := .F.
                    LogIntegra(cErro)
                    JsonRet("","3",cErro, nPos)
                    Exit
                EndIf 
            Next nI
            (cTabela)->(DbCloseArea())
        Else
            cErro   := STR0010 + cTabela + STR0011 //"Não foram enviados os campos que pertencem a chave da tabela " # ", registros não atualizados!"
            lRet    := .F.
            LogIntegra(cErro)
            JsonRet("","3",cErro, nPos)
        EndIf
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} JsonRet
    Função responsavel apenas em montar o Json de retorno para a API com o status de cada registro.
    @type  Function
    @author Bruno Almeida
    @since 07/03/2024
    @version P12
    @param cUuid, caractere, Uuid do registro que esta sendo atualizado
    @param cStatus, caractere, Status de sucesso 2 ou erro 3
    @param cErro, caractere, Motivo do erro na atualização
    @param nPos, numerico, Posição do registro da tabela no Json que chegou da API
    @return Nil
/*/
Static Function JsonRet(cUuid,cStatus,cErro,nPos)

Local nI := 0

Default nPos := 0

If AllTrim(cStatus) == "2"
    oJsonRet["RegistrosSucesso"]   := oJsonRet["RegistrosSucesso"] + "'" + cUuid + "',"
ElseIf AllTrim(cStatus) == "3"

    If nPos == 0
        Aadd(oJsonRet["RegistrosErro"], JsonObject():New())
        oJsonRet["RegistrosErro"][Len(oJsonRet["RegistrosErro"])]["UUID"]     := cUuid
        oJsonRet["RegistrosErro"][Len(oJsonRet["RegistrosErro"])]["Status"]   := cStatus
        oJsonRet["RegistrosErro"][Len(oJsonRet["RegistrosErro"])]["Motivo"]   := cErro
    Else
        /* 
            Invalida todos os registros de uma determinada tabela.
            Pode acontecer pois as vezes a tabela não existe na base do PDV ou a chave que foi informado no Json é invalida.
        */
        For nI := 1 To Len(oJson["Tabelas"][nPos]["Registro"])
            Aadd(oJsonRet["RegistrosErro"], JsonObject():New())
            oJsonRet["RegistrosErro"][Len(oJsonRet["RegistrosErro"])]["UUID"]     := oJson["Tabelas"][nPos]["Registro"][nI]["UUID"]
            oJsonRet["RegistrosErro"][Len(oJsonRet["RegistrosErro"])]["Status"]   := cStatus
            oJsonRet["RegistrosErro"][Len(oJsonRet["RegistrosErro"])]["Motivo"]   := cErro
        Next nI
    EndIf

EndIf

Return Nil

/*/{Protheus.doc} AtlzStatus
    Função responsavel em chamar a API para atualizar o status dos registros que foram atualizados.
    @type  Function
    @author Bruno Almeida
    @since 07/03/2024
    @version P12
    @param 
    @return Nil
/*/
Static Function AtlzStatus()

Local oPut      := Nil
Local jStatus   := JsonObject():New() 
Local cEndPoint := AllTrim(aConfig[5])
Local nContador := 0
Local cPath     := "/api/retail/v1/integrapdv/AtuStatusIntegPDV/"
Local cTime     := ""
Local cHoraIni      := TimeFull()

If SubStr(cEndPoint, Len(cEndPoint), 1) == "/"
    cEndPoint := SubStr(cEndPoint, 1, Len(cEndPoint) - 1)
EndIf

oPut := FWRest():New(cEndPoint)
oPut:SetPath( cPath )
oPut:SetTimeOut(nTimeOutRest)

LogIntegra("PUT na API: " + cEndPoint + cPath + STR0027 + FWTimeStamp(2))
cTime := Time()

oJsonRet["RegistrosSucesso"] := SubStr(oJsonRet["RegistrosSucesso"],1,Len(oJsonRet["RegistrosSucesso"])-1)

While nContador <= 3
    If oPut:Put({"Content-Type: application/json", "Authorization: Bearer " + aConfig[1]},oJsonRet:ToJson())
        jStatus:FromJson(oPut:GetResult())
        nContador := 4
    Else
        If AllTrim(FwCutOff(oPut:GetLastError())) $ "500 InternalServerError"
            nContador++
            Sleep(1000)
            If nContador == 4
                LogIntegra(STR0012 + oPut:GetLastError()) //"Não foi possivel fazer a atualização de status dos registros atualizados. Erro: "
            EndIf    
        Else
            nContador := 4            
            LogIntegra(STR0012 + oPut:GetLastError()) //"Não foi possivel fazer a atualização de status dos registros atualizados. Erro: "
        EndIf
    EndIf
End
LogIntegra("Operacao: PUT - Api: " + cPath + " - Tempo: " + ElapTime(cTime, Time()))

FwFreeObj(oPut)
FwFreeObj(jStatus)

oPut    := Nil
jStatus := Nil

LogIntegra("RMIIntePDV | AtlzStatus | Hora Inicial: " + cHoraIni + " Hora Final: " +  TimeFull())

Return Nil

/*/{Protheus.doc} ExcluiDados
    Função responsavel em processar apenas os registros que devem ser excluidos da base
    @type  Function
    @author Bruno Almeida
    @since 15/03/2024
    @version P12
    @param 
    @return Nil
/*/
Static Function ExcluiDados(nI)

Local nX        	:= 0
Local lInsert   	:= .T.
Local cChaveTab 	:= ""
Local oError    	:= Nil
Local lRecno        := AliasInDic("MIZ") .AND. AllTrim(cChave) == "R_E_C_N_O_"
Local nRecRegist    := 0

// -- Percorre cada registro da tabela
For nX := 1 To Len(oJson["Tabelas"][nI]["Registro"])

    lInsert     := .T.
    cChaveTab   := ""
    cAlias      := ""

    TRY EXCEPTION
        If oJson["Tabelas"][nI]["Registro"][nX]["Del"]

            If lRecno
                nRecRegist := GetRecno(cTabela, oJson["Tabelas"][nI]["Registro"][nX]["Recno"])

                If nRecRegist > 0
                    lInsert := .F.
                    (cTabela)->(dbGoto(nRecRegist))
                Else
                    lInsert := .T.
                EndIf
            Else
                // -- Pesquisa o registro para saber se existe ou não na base
                cChaveTab := MontaQuery(oJson["Tabelas"][nI]["Registro"][nX])
            
                If !(cAlias)->( Eof() )
                    lInsert := .F.
                    (cTabela)->(dbGoto((cAlias)->REC))
                Else
                    lInsert := .T.
                EndIf
            EndIf
        
            If !lInsert
                If (cTabela)->(RecLock(cTabela,.F.,,,IsBlind()))
                    LogIntegra(STR0032 + cChaveTab + STR0029 + cTabela + STR0027 + FWTimeStamp(2)) //"Inicio da exclusão do registro (" # ") da tabela " # " - Data e Hora: "
                    (cTabela)->( DbDelete() )
                    (cTabela)->( MsUnLock() )

                    JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"2","")
                    LogIntegra(STR0033 + cChaveTab + STR0029 + cTabela + STR0027 + FWTimeStamp(2)) //"Final da exclusão do registro (" # ") da tabela " # " - Data e Hora: "
                Else
                    JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"3",STR0014) //"Não foi possivel fazer o Lock no registro/tabela para efetuar a exclusão!"
                EndIf
            Else
                // -- Se o registro não existe na base, então não tem o que deletar, apenas retorna status de sucesso.
                JsonRet(oJson["Tabelas"][nI]["Registro"][nX]["UUID"],"2","")
            EndIf        

            If !lRecno .or. ( !empty(cAlias) .and. select(cAlias) > 0 )
                (cAlias)->( DbCloseArea() )
            EndIf

            cAlias := ""

        EndIf

    CATCH EXCEPTION USING oError
        trataErro(oError, oJson["Tabelas"][nI]["Registro"][nX], cChaveTab)

    ENDTRY

Next nX
    
Return Nil


/*/{Protheus.doc} getToken
    Função para fazer a leitura do token que esta gravado na tabela de assinante.
    @type  Function
    @author Bruno Almeida
    @since 05/04/2024
    @version P12
    @param 
    @return Nil
/*/
Static Function getToken()

Local jConfig   := JsonObject():New()

MHO->(dbSetOrder(1)) //MHO_FILIAL+MHO_COD
If MHO->(dbSeek(xFilial("MHO") + PadR("TOTVS PDV",TamSx3("MHO_COD")[1]," ")))
    If !Empty(MHO->MHO_CONFIG)
        jConfig:FromJson(MHO->MHO_CONFIG)
        aConfig[1] := jConfig["access_token"]
        aConfig[2] := jConfig["refresh_token"]
        aConfig[3] := AllTrim(jConfig["usuario"])
        aConfig[4] := AllTrim(Rc4Crypt(jConfig["senha"], "0123456789*!@#$%&", .F., .T.))
        aConfig[5] := jConfig["endpoint"]
        aConfig[6] := jConfig["dadosambiente"]
        
        If Empty(aConfig[3]) .OR. Empty(aConfig[4])
            lContinua   := .F.
            cMsgErro    := STR0015 //"Não foi informado o usuario ou senha no wizard de configuração da integração, não sera possivel continuar com a consulta dos dados!"
        EndIf
    Else
        lContinua   := .F.
        cMsgErro    := STR0016 //"Não foi realizado a configuração da integração pelo wizard de configuração, não sera possivel continuar com a consulta dos dados!"
    EndIf
Else
    lContinua   := .F.
    cMsgErro    := STR0016 //"Não foi realizado a configuração da integração pelo wizard de configuração, não sera possivel continuar com a consulta dos dados!"
EndIf

FwFreeObj(jConfig)
jConfig := Nil

Return Nil

/*/{Protheus.doc} GeraToken
    Essa função é responsavel em gerar o token pela primeira vez e regerar quando o token esta vencido.
    @type  Function
    @author Bruno Almeida
    @since 05/04/2024
    @version P12
    @param nTipo, numerico, Indica se é para gerar um token ou para atualizar o token
    @param cEndPoint, caractere, Url do serviço REST
    @param cUsuario, caractere, Usuario para a geração do token
    @param cSenha, caractere, Senha do usuario para geração do token
    @param cRefreshToken, caractere, Token para gerar um novo token quando estiver vencido
    @return Nil
/*/
Static Function GeraToken(nTipo, cEndPoint, cUsuario, cSenha, cRefreshToken)

Local oPost     := FWRest():New(cEndPoint)
Local cApi      := "/api/oauth2/v1/token" + IIF(nTipo == 0, "?grant_type=password&password=" + cSenha + "&username=" + cUsuario,"?grant_type=refresh_token&refresh_token=" + cRefreshToken)
Local cSemaforo := "GERATOKEN"
Local cTime     := ""
Local cHoraIni      := TimeFull()

If !LockByName(cSemaforo, .T./*lEmpresa*/, .T./*lFilial*/)
    lContinua   := .F.
    cMsgErro    := STR0020 //"O token esta sendo gerado por outra thread, os dados serão consultados e atualizados na proxima execução do JOB."
    Return Nil
Else
    LogIntegra(STR0021) //"Semaforo criado e geração do token em execução."
EndIf

LogIntegra("POST na API: " + cEndPoint + cApi + STR0027 + FWTimeStamp(2))
cTime := Time()

oPost:SetPath( cApi )
oPost:SetTimeOut(nTimeOutRest)

If oPost:Post({"Content-Type: application/json"})
    AtlzAssina(oPost:GetResult())
Else
    If nTipo == 1 .AND. AllTrim(FwCutOff(oPost:GetLastError())) $ "401 Unauthorized"
        //Se tentar atualizar o token pelo refresh_token e não conseguir, então limpo o access_token e o refresh_token para gerar um novo na próxima thread.
        AtlzAssina("", .T.)
    Else
        lContinua   := .F.
        cMsgErro    := STR0017 + oPost:GetLastError() + IIF(!Empty(oPost:cResult), " - " + oPost:cResult, "") //"Não foi possivel fazer a geração do token, erro: "
    EndIf
EndIf
LogIntegra("Operacao: POST - Api: " + cApi + " - Tempo: " + ElapTime(cTime, Time()))

FwFreeObj(oPost)
oPost := Nil

//Libera semaforo de controle
If UnLockByName(cSemaforo, .T./*lEmpresa*/, .T./*lFilial*/)
    LogIntegra(STR0022) //"Semaforo liberado após a geração do token."
EndIf

LogIntegra("RMIIntePDV | GeraToken | Hora Inicial: " + cHoraIni + " Hora Final: " +  TimeFull())

Return Nil

/*/{Protheus.doc} AtlzAssina
    Função para atualizar o Json na tabela de assinante depois que o token for gerado pela rotina.
    @type  Function
    @author Bruno Almeida
    @since 05/04/2024
    @version P12
    @param cJson, caractere, Json contendo o novo token
    @return Nil
/*/
Static Function AtlzAssina(cJson, lClear)

Local oJsonConfig   := JsonObject():New()
Local oJsonToken    := JsonObject():New()

Default lClear := .F.

MHO->(dbSetOrder(1)) //MHO_FILIAL+MHO_COD
If MHO->(dbSeek(xFilial("MHO") + PadR("TOTVS PDV",TamSx3("MHO_COD")[1]," ")))
    oJsonToken:FromJson(cJson)
    oJsonConfig:FromJson(MHO->MHO_CONFIG)

    oJsonConfig["access_token"]     := IIF(!lClear, oJsonToken["access_token"], "")
    oJsonConfig["refresh_token"]    := IIF(!lClear, oJsonToken["refresh_token"], "")

    If MHO->(RecLock("MHO",.F.,,,IsBlind()))
        MHO->MHO_CONFIG := oJsonConfig:ToJson()
        MHO->(MsUnLock())

        If !lClear
            lContinua   := .F.
            cMsgErro    := STR0018 //"Token gerado e atualizado com sucesso, em alguns minutos sera realizado nova tentativa de atualização das informações."
        Else
            lContinua   := .F.
            cMsgErro    := STR0019 //"Não foi possivel atualizar o token a partir do refresh_token, portanto, o token foi excluido das configurações e sera gerado um novo token na próxima thread."
        EndIf
    EndIf

EndIf

FwFreeObj(oJsonConfig)
FwFreeObj(oJsonToken)

oJsonConfig := Nil
oJsonToken  := Nil

Return Nil

/*/{Protheus.doc} LogIntegra
    Função responsavel apenas em escrever o log conforme o parâmetro lLogInteg
    @type  Function
    @author Bruno Almeida
    @since 05/04/2024
    @version P12
    @param cLogMsg, caractere, Log a ser escrito no LogLoja e Console.log
    @return Nil
/*/
Static Function LogIntegra(cLogMsg)

Local cThread := "IntegPdv - Thread: " + cValToChar(ThreadID())

If lLogInteg
    LjGrvLog(cThread, cLogMsg)
EndIf

Return Nil

/*/{Protheus.doc} TrataCampo
    Função para tratamento do campo chave
    @type  Function
    @author Bruno Almeida
    @since 06/05/2024
    @version P12
    @param cCampo, caractere, Nome do campo chave
    @return cRet, carectere, Retorno após o tratamento do campo
/*/
Static Function TrataCampo(cCampo)

Local cRet := ""

If At("(",cCampo) > 0
    cRet := StrTran(StrTran(SubStr(cCampo,At("(",cCampo)),"("),")")
Else
    cRet := cCampo
EndIf

Return cRet

/*/{Protheus.doc} CtrlRecno
Faz o controle de recno da retaguarda e da Central/PDV
@type  Static Function
@author joao.marcos
@since 12/08/2024
@version v1.0
@param  cTabela, character, nome da tabela
        cRecnoRet, character, recno do registro na retaguarda
        nRecnoLocal, Numerico, recno do registro na tabela local 
@return lInclui, logico, retorno indicando se vai ser uma inclusão ou alteraçao
/*/
Static Function CtrlRecno(cTabela, cRecnoRet, nRecnoLocal) 
Local lInclui  := .F.
Local aAreaMIZ  := MIZ->(GetArea())

Default nRecnoLocal := 0

MIZ->(dbSetOrder(1)) // MIZ_FILIAL+MIZ_TABELA+MIZ_RECRET+MIZ_RECLOC

lInclui := !(MIZ->( dbSeek(xFilial("MIZ") + cTabela + PadR(cRecnoRet, TamSx3("MIZ_RECRET")[1], " ") ) ))

If nRecnoLocal <> 0
    MIZ->( Reclock("MIZ",lInclui))
        MIZ->MIZ_FILIAL := xFilial("MIZ")
        MIZ->MIZ_TABELA := cTabela
        MIZ->MIZ_RECRET := cRecnoRet
        MIZ->MIZ_RECLOC := cValToChar(nRecnoLocal)
    MIZ->(MsUnLock())
EndIf

If !lInclui .AND. nRecnoLocal == 0
    nRecnoLocal := Val(MIZ->MIZ_RECLOC)
EndIf

RestArea(aAreaMIZ)

Return lInclui

/*/{Protheus.doc} ValidaHora
    Função que verifica as 24 horas para executar a atualização dos dados de ambiente
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return lRet, logico, .T. executa a atualização dos dados e .F. não executa.
/*/
Static Function ValidaHora()

Local lRet := .F.
Local nDif := 0

If Empty(aConfig[6])
    lRet := .T.
Else
    nDif := SubtHoras(CtoD(SubStr(aConfig[6],1,10)),SubStr(aConfig[6],12),Date(),Time())

    If nDif >= 24
		lRet := .T.
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} GetRecno
    Função para consultar se existe o recno do registro na tabela MIZ
    @type  Function
    @author Bruno Almeida
    @since 24/02/2025
    @version P12
    @return nRec, numerico, retorna o numero do recno encontrado na tabela MIZ
/*/
Static Function GetRecno(cTab, cRecRet)

Local nRec  := 0
Local aArea := GetArea()

dbSelectArea("MIZ")
MIZ->(dbSetOrder(1)) //MIZ_FILIAL+MIZ_TABELA+MIZ_RECRET+MIZ_RECLOC

If MIZ->(dbSeek(xFilial("MIZ") + cTab + PadR(cRecRet, TamSx3("MIZ_RECRET")[1], " ")))
    nRec := Val(MIZ->MIZ_RECLOC)
Else
    nRec := 0
EndIf

RestArea(aArea)

Return nRec

//-------------------------------------------------------------------
/*/{Protheus.doc} fechaAlias
Fecha a tabela caso esteja aberta

@type    function
@author  Rafael Tenorio da Costa
@since   20/02/2025
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function fechaAlias()

    If !empty(cAlias) .and. select(cAlias) > 0
        (cAlias)->( DbCloseArea() )
        cAlias := ""
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} trataErro
Funç~~ao com os tratamentos necessários para quando cair no EXCEPTION

@type    function
@author  Rafael Tenorio da Costa
@since   20/02/2025
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function trataErro(oError, oJson, cChaveTab)

    Local cErro := allTrim(oError:ErrorStack) + CRLF + varInfo("", oJson, nil, .F., .F.)

    fechaAlias()

    JsonRet(oJson["UUID"], "3", cErro)

    LogIntegra(STR0036 + cChaveTab + STR0029 + cTabela + STR0027 + FWTimeStamp(2))  //"Erro na inclusão/alteração do registro (" # ") da tabela " # " - Data e Hora: "

Return nil
