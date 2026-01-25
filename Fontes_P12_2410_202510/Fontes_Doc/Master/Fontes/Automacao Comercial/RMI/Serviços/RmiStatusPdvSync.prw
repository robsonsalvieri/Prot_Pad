#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"

Static aEntity := {} //Código e nome de cada entidade do PDV Sync

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiStsPdvS
Atualiza o MHR_STATUS dos registros enviados para o PDV Sync

@author  Bruno Almeida
@Date    22/06/2021
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiStsPdvS(cEmpAnt, cFilAnt)

    Local cSemaforo := "STATUSPDVSYNC" //Variavel de semaforo
    Local cQuery    := "" //Variavel que guarda a query
    Local cAlias    := GetNextAlias() //Proximo alias disponivel
    Local oError    := Nil //Objeto que guarda o erro

    RpcSetType(3)
    RpcSetEnv(cEmpAnt, cFilAnt, , ,"LOJ")

    nModulo := 12

    If !AmIIn(12)
        LjGrvLog("RmiStatusPdvSync", "Não foi encontrado Licença para o Varejo-SIGALOJA")
        ConOut("RmiStatusPdvSync - Não foi encontrado Licença para o Varejo-SIGALOJA")
        Return(.F.)
    EndIf  

    If !LockByName(cSemaforo, .T., .T.)
        LjxjMsgErr("Já existe uma thread de consulta status lote (PDV Sync) em execução")
        Return Nil
    EndIf

    TRY EXCEPTION

        cQuery := "SELECT MHR_LOTE"
        cQuery += "  FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_STATUS = '6'"
        cQuery += "   AND MHR_CASSIN = 'PDVSYNC'"
        cQuery += "   AND MHR_FILIAL = '" + xFilial("MHR") + "'"
        cQuery += "   AND D_E_L_E_T_ = ' '" 
        cQuery += " GROUP BY MHR_LOTE"

        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        If !(cAlias)->( Eof() )

            GetEntity()

            While !(cAlias)->( Eof() )
                ConsLote(AllTrim((cAlias)->MHR_LOTE))
                (cAlias)->( DbSkip() )
            EndDo
        EndIf

        (cAlias)->( DbCloseArea() )

        UnLockByName(cSemaforo, .T., .T.)

    CATCH EXCEPTION USING oError

        UnLockByName(cSemaforo, .T., .T.)
        LjGrvLog("RmiStatusPdvSync", "Ocorreu erro na consulta de lotes ->  " + AllTrim(oError:Description))

    ENDTRY

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ConsLote
Chama o metodo GET para retornar a consulta do lote

@author  Bruno Almeida
@Date    22/06/2021
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConsLote(cLote)

    Local oConfAssin := JsonObject():New() //Recebe o Json de configuração do assinante
    Local cQuery := "" //Recebe a query para consulta do assinante
    Local cAlias := GetNextAlias() //Proximo alias disponivel
    Local oRest := FWRest():New("") //Objeto que faz a comunicação via Rest com PDVSync
    Local cPath := "" //EndPoint da consulta de status

    cQuery := "SELECT R_E_C_N_O_"
    cQuery += "  FROM " + RetSqlName("MHO")
    cQuery += " WHERE MHO_COD = 'PDVSYNC'"
    cQuery += "   AND MHO_FILIAL = '" + xFilial("MHO") + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    If !(cAlias)->( Eof() )
        MHO->(DbGoTo((cAlias)->R_E_C_N_O_))
        oConfAssin:FromJson( AllTrim(MHO->MHO_CONFIG) )

        cPath := AllTrim(oConfAssin["url_consultalote"])

        If SubStr(cPath,Len(cPath),1) == "/"
            cPath := SubStr(cPath, 1, Len(cPath) - 1)
        EndIf

        If !Empty(cPath)
            //Seta a url do lote
            oRest:SetPath( cPath + "/" + AllTrim(oConfAssin["inquilino"]) + "/" + AllTrim(cLote) )

            //Fecha o lote
            If oRest:Get( {"Content-Type:application/json"} )
                TrataRet(oRest:cResult)
            Else
                If oRest:oResponseH:cStatusCode == "404"
                    LjGrvLog("RmiStatusPdvSync", "Lote " + cLote + " não validado no PDVSync, os registros desse lote permanecerão com status 6 até a próxima consulta do lote.")
                Else
                    LjGrvLog("RmiStatusPdvSync", "Não foi possivel consultar o lote " + cLote + ". Erro: " + oRest:GetLastError())
                EndIf
            EndIf

        Else
            LjGrvLog("RmiStatusPdvSync", "A tag url_consultalote não foi informada/preenchida no cadastro de assinante do PDVSYNC, sendo assim não foi possivel efetuar a consulta do lote - " + cLote)
        EndIf

    EndIf

    FreeObj(oConfAssin)
    FreeObj(oRest)
    (cAlias)->( DbCloseArea() )

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRet
Trata o retorno da consulta do lote

@author  Bruno Almeida
@Date    22/06/2021
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TrataRet(cJson)

    Local oRetorno := JsonObject():New()

    Default cJson := ""

    If !Empty(cJson)

        LjGrvLog("RmiStatusPdvSync", "Retorno da consulta de lote:", cJson)

        oRetorno:FromJson(cJson)
        If oRetorno["data"][1]["status"] == 3
            AtlzAll(oRetorno["data"][1]["loteOrigem"])
        ElseIf oRetorno["data"][1]["status"] == 4
            //Primeiro atualiza os registros que contém no retorno da consulta para o status 3
            AtlzParcial(oRetorno)
            //Os registros que sobraram, atualiza para 2 porém não contém erros
            AtlzAll(oRetorno["data"][1]["loteOrigem"])
        Else
            LjGrvLog("RmiStatusPdvSync", "Status desconhecido na consulta do lote.")
        EndIf
    EndIf

    FreeObj(oRetorno)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtlzAll
Atualiza os status da MHR conforme o lote

@author  Bruno Almeida
@Date    22/06/2021
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtlzAll(cLote)

    Local cQuery := "" //Query para consulta do lote
    Local cAlias := GetNextAlias() //Proximo alias disponivel

    cQuery := "SELECT R_E_C_N_O_ "
    cQuery += "  FROM " + RetSqlName("MHR")
    cQuery += " WHERE MHR_LOTE = '" + cLote + "'"
    cQuery += "   AND MHR_FILIAL = '" + xFilial("MHR") + "'"
    cQuery += "   AND MHR_STATUS = '6'"
    cQuery += "   AND D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    While !(cAlias)->( Eof() )
        MHR->(DbGoTo((cAlias)->R_E_C_N_O_))
        RecLock("MHR", .F.)   
        MHR->MHR_STATUS := "2"
        MHR->MHR_TENTAT := cValToChar(Val(MHR->MHR_TENTAT) + 1)
        MHR->(MsUnLock())
        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->( DbCloseArea() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtlzParcial
Atualiza parcialmente os status da MHR conforme o lote e idRetaguarda

@author  Bruno Almeida
@Date    22/06/2021
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtlzParcial(oJson)

    Local nI        := 0 //Variavel de loop
    Local cQuery    := "" //Armazena a query
    Local nPos      := "" //Posicao do array
    Local cAlias    := "" //Proximo alias disponivel

    For nI := 1 To Len(oJson["data"][1]["errosIdentificados"])   
        
        nPos    := aScan(aEntity, {|x| x[2] == cValToChar(oJson["data"][1]["errosIdentificados"][nI]["tipoLote"]) })
        cAlias  := GetNextAlias()

        cQuery := ""
        cQuery := "SELECT R_E_C_N_O_ "
        cQuery += "  FROM " + RetSqlName("MHR")
        cQuery += " WHERE MHR_FILIAL = '" + xFilial("MHR") + "'"
        cQuery += "   AND MHR_LOTE = '" + AllTrim(oJson["data"][1]["loteOrigem"]) + "'"
        cQuery += "   AND MHR_IDRET = '" + AllTrim(oJson["data"][1]["errosIdentificados"][nI]["idRetaguarda"]) + "'"
        cQuery += "   AND MHR_CPROCE = '" + IIF(nPos > 0, AllTrim(aEntity[nPos][1]), "") + "'"
        cQuery += "   AND D_E_L_E_T_ = ' '"
  
        DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

        While !(cAlias)->( Eof() )
            MHR->(DbGoTo((cAlias)->R_E_C_N_O_))
            LjGrvLog("RmiStatusPdvSync", "O registro idRetaguarda: " + AllTrim(oJson["data"][1]["errosIdentificados"][nI]["idRetaguarda"]) + ", esta com o seguinte erro no PDV Sync: " + AllTrim(oJson["data"][1]["errosIdentificados"][nI]["erro"])) 
            
            //Grava o Log na MHL e atualiza o Status na MHR
            RmiGrvLog("IR", "MHR" , MHR->(Recno()), "ENVIA", AllTrim(oJson["data"][1]["errosIdentificados"][nI]["erro"]),,, 'MHR_STATUS', .T., 3, MHR->MHR_FILIAL+"|"+MHR->MHR_UIDMHQ+"|"+MHR->MHR_CASSIN+"|"+MHR->MHR_CPROCE, MHR->MHR_CPROCE, MHR->MHR_CASSIN, MHR->MHR_UIDMHQ)

            RecLock("MHR", .F.)   
                MHR->MHR_TENTAT := cValToChar(Val(MHR->MHR_TENTAT) + 1)
            MHR->(MsUnLock())

            (cAlias)->( DbSkip() )
        EndDo

        (cAlias)->( DbCloseArea() )

    Next nI 

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Recupera todos os códigos das entidades de cada processo na tabela MHP

@author  Bruno Almeida
@Date    28/06/2021
@since   
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetEntity()

    Local cQuery    := "" //Query a ser armazenada da MHP
    Local cAlias    := GetNextAlias() //Proximo alias disponivel
    Local oJson     := Nil //Objeto Json com a configuração do processo

    aEntity := {}

    cQuery := "SELECT R_E_C_N_O_"
    cQuery += "  FROM " + RetSqlName("MHP")
    cQuery += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "'"
    cQuery += "   AND MHP_CASSIN = 'PDVSYNC'"
    cQuery += "   AND MHP_CONFIG <> ''"
    cQuery += "   AND MHP_ATIVO = '1'"
    cQuery += "   AND D_E_L_E_T_ = ' '"

    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .F.)

    While !(cAlias)->( Eof() )
        MHP->(DbGoTo((cAlias)->R_E_C_N_O_))

        oJson := JsonObject():New()
        oJson:FromJson(MHP->MHP_CONFIG)

        If !Empty(oJson['codigotipo'])
            aAdd(aEntity,{MHP->MHP_CPROCE,oJson['codigotipo'],oJson['descricaotipo']})
        EndIf

        FreeObj(oJson)
       
        (cAlias)->( DbSkip() )
    EndDo

    (cAlias)->( DbCloseArea() )

Return Nil
