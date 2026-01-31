#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"
#INCLUDE "RMIDADOSAMBIENTE.ch"

Static aDados       := {}
Static jJson        := Nil
Static cEndPoint    := ""

/*/{Protheus.doc} RmiDadAmbi
    Função principal para a integração dos dados de ambiente
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @param cEmp, caractere, Empresa
    @param cFil, caractere, Filial
    @param cPontoCarg, caractere, Código do ponto de integração
    @param aConfig, array, Contém as informações do cadastro de assinante MHO_CONFIG
    @return Nil
/*/
Function RmiDadAmbi(cEmp, cFil, cPontoCarg, aConfig)

Local cSemaforo := "RMIDADAMBI"

RPCSetType(3)
RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")

//-- Trava a execução para evitar que mais de uma sessão faça a execução.
If !LockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)
    RpcClearEnv()
    Return Nil
EndIf

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " RmiDadAmbi - Inicio")

jJson       := JsonObject():New()
aDados      := {cEmp, cFil, cPontoCarg, aConfig}
cEndPoint   := AllTrim(aDados[4][5])

If SubStr(cEndPoint, Len(cEndPoint), 1) == "/"
    cEndPoint := SubStr(cEndPoint, 1, Len(cEndPoint) - 1)
EndIf

If DelDadAmb()
    FontesRpo()
    Binario()
    Dicionario()

    //-- Atualiza o assinante
    AtlzData()
    Sleep(9000)
EndIf

UnLockByName(cSemaforo, .T./*lEmpresa*/, .F./*lFilial*/)

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " RmiDadAmbi - Inicio")

RpcClearEnv()

Return Nil

/*/{Protheus.doc} PostDadAmb
    Função para enviar os dados de ambiente para serem gravados na retaguarda.
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @param cBody, json, Json contendo os dados de ambiente
    @return lRet, logico, .T. se conseguiu gravar ou .F. se houve algum erro na gravação
/*/
Static Function PostDadAmb(cBody)

Local oPost     := Nil 
Local nContador := 1
Local cPath     := ""
Local lRet      := .T.

oPost := FWRest():New(cEndPoint)
cPath := "/api/retail/v1/integrapdv/ambiente/"

oPost:SetPath( cPath )
oPost:SetPostParams( cBody )

LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), "POST na API: " + cEndPoint + cPath)

While nContador <= 3

    If oPost:Post({"Content-Type: application/json", "Authorization: Bearer " + aDados[4][1]})                
        nContador := 4
    Else
        If "Unauthorized" $ AllTrim(FwCutOff(oPost:GetLastError()))
            LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), STR0003 + oPost:GetLastError()) //"Erro pois o token pode estar vencido, sera consultado um novo token! Erro: "
            aDados[4][1] := getRmiToke()[1]
            nContador++
            Sleep(5000)
        ElseIf AllTrim(FwCutOff(oPost:GetLastError())) $ "500 InternalServerError"
            nContador++
            Sleep(1000)
            If nContador == 4
                lRet := .F.
                LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), STR0001 + oPost:GetLastError()) //"Não foi possivel incluir os dados do ambiente na retaguarda, as informações sobre o ambiente não foram atualizadas. Erro: "
            EndIf
        Else
            nContador   := 4
            lRet        := .F.
            LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), STR0001 + oPost:GetLastError()) //"Não foi possivel incluir os dados do ambiente na retaguarda, as informações sobre o ambiente não foram atualizadas. Erro: "
        EndIf
    EndIf

End

FwFreeObj(oPost)
oPost := Nil

Return lRet

/*/{Protheus.doc} DelDadAmb
    Função para exclusão dos dados de ambiente antes de serem enviados os novos registros.
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return lRet, logico, Se conseguiu excluir .T. caso contrario .F.
/*/
Static Function DelDadAmb()

Local oDel      := Nil 
Local nContador := 1
Local cPath     := ""
Local lRet      := .T.

oDel    := FWRest():New(cEndPoint)
cPath   := "/api/retail/v1/integrapdv/ambiente?filial=" + StrTran(AllTrim(aDados[2])," ", "+") + "&empPtIn=" + aDados[1] + "&codPtIn=" + aDados[3]

oDel:SetPath( cPath )

LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), "DELETE na API: " + cEndPoint + cPath)

While nContador <= 3

    If oDel:Delete({"Content-Type: application/json", "Authorization: Bearer " + aDados[4][1]})                
        nContador := 4
    Else
        If AllTrim(FwCutOff(oDel:GetLastError())) $ "500 InternalServerError"
            nContador++
            Sleep(1000)
            If nContador == 4
                lRet := .F.
                LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), STR0002 + oDel:GetLastError()) //"Não foi possivel excluir os dados do ambiente na retaguarda, as informações sobre o ambiente não serão atualizadas. Erro: "
            EndIf
        Else
            nContador   := 4
            lRet        := .F.
            LjGrvLog("IntegPdv - Thread: " + cValToChar(ThreadID()), STR0002 + oDel:GetLastError()) //"Não foi possivel excluir os dados do ambiente na retaguarda, as informações sobre o ambiente não serão atualizadas. Erro: "
        EndIf
    EndIf

End

FwFreeObj(oDel)
oDel := Nil

Return lRet

/*/{Protheus.doc} ObjJson
    Função para montagem do objeto Json com os dados de ambiente
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @param nAcao, numerico, 0 para destruir o objeto, 1 para criar o objeto Json, 2 para gravar dados no objeto, caso contrario para retornar os dados do objeto
    @param cFilPt, caracter, filial do ponto de integração
    @param cEmpPtIn, caracter, empresa do ponto de integração
    @param cCodPtIn, caracter, código do ponto de integração
    @param cTpDado, caracter, recebe a informação: Fonte, Dicionario ou Binario
    @param cNomeDado, caracter, recebe a informação: Nome do Fonte, SIX, SX2, SX3, SX6 ou Binario
    @param cConteudo, caracter, recebe data do fonte ou do binario
    @param cConteudoDic, caracter, json das tabelas de dicionario
    @return cRet, caracter, retorna o Json que esta no objeto jJson
/*/
Static Function ObjJson(nAcao, cFilPt, cEmpPtIn, cCodPtIn, cTpDado, cNomeDado, cConteudo, cConteudoDic)

Local cRet := ""

Default cConteudoDic := "{}"

Do Case
    Case nAcao == 0
        FwFreeObj(jJson)
        jJson := Nil
    Case nAcao == 1
        jJson := JsonObject():New()
        jJson["itens"] := {} 
    Case nAcao == 2
        aAdd(jJson["itens"],JsonObject():New())
        jJson["itens"][Len(jJson["itens"])]["filial"]        := cFilPt
        jJson["itens"][Len(jJson["itens"])]["empPtIn"]       := cEmpPtIn
        jJson["itens"][Len(jJson["itens"])]["codPtIn"]       := cCodPtIn
        jJson["itens"][Len(jJson["itens"])]["tpDado"]        := cTpDado
        jJson["itens"][Len(jJson["itens"])]["nomeDado"]      := cNomeDado
        jJson["itens"][Len(jJson["itens"])]["conteudo"]      := cConteudo
        jJson["itens"][Len(jJson["itens"])]["conteudoDic"]   := JsonObject():New()
        jJson["itens"][Len(jJson["itens"])]["conteudoDic"]:FromJson(cConteudoDic)
    OtherWise
        cRet := jJson:ToJson()
EndCase

Return cRet


/*/{Protheus.doc} FontesRpo
    Função que recupera a data de todos os fontes e envia para a retaguarda
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function FontesRpo()
Local aFontes   := GetSrcArray( "*" )
Local aInfo     := {}
Local nX        := 0

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " FontesRpo - Inicio")

ObjJson(1)

For nX := 1 To Len(aFontes)
    aInfo := GetApoInfo( aFontes[nX] )
    If Len(aInfo) >= 5
        ObjJson(2, aDados[2], aDados[1], aDados[3], "Fonte", aFontes[nX], DToS(aInfo[4]) + " - " + aInfo[5])
    EndIf

    aSize(aInfo, 0)

    If (Len(jJson["itens"]) == 100) .OR. (nX == Len(aFontes))
        PostDadAmb(ObjJson(3))   
        ObjJson(0)
        ObjJson(1)
    EndIf
Next nX

ObjJson(0)

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " FontesRpo - Fim")

Return Nil

/*/{Protheus.doc} Dicionario
    Função para fazar a chamada de cada tabela de dicionario SX2, SX3, SIX e SX6
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function Dicionario()

Local aArea := GetArea()
Local cJsonSX2 := ""
Local cJsonSX3 := ""
Local cJsonSIX := ""

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " Dicionario - Inicio")

FuncSx6()

DbSelectArea( "SX2" )
SX2->(DbGoTop())

While !SX2->(EOF())
    cJsonSX2 := FuncSx2()
    cJsonSX3 := FuncSx3()
    cJsonSIX := FuncSix()

    ObjJson(1)
    ObjJson(2, aDados[2], aDados[1], aDados[3], "SX2", FWX2CHAVE(), "", cJsonSX2)
    ObjJson(2, aDados[2], aDados[1], aDados[3], "SX3", FWX2CHAVE(), "", cJsonSX3)
    ObjJson(2, aDados[2], aDados[1], aDados[3], "SIX", FWX2CHAVE(), "", cJsonSIX)   
    PostDadAmb(ObjJson(3))
    ObjJson(0)

    cJsonSX2 := ""
    cJsonSX3 := ""
    cJsonSIX := ""

	SX2->(DbSkip())
End

RestArea(aArea)

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " Dicionario - Fim")

Return Nil

/*/{Protheus.doc} FuncSx2
    Função para envio dos dados da SX2
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function FuncSx2()

Local jSX2 := JsonObject():New()
Local aSX2 := FwSX2Util():GetSX2data(FWX2CHAVE(), {"X2_CHAVE","X2_ARQUIVO","X2_NOME","X2_MODO","X2_MODOUN","X2_MODOEMP","X2_UNICO"})
Local cRet := ""

jSX2["X2_CHAVE"]    := aSX2[1][2]
jSX2["X2_ARQUIVO"]  := AllTrim(aSX2[2][2])
jSX2["X2_NOME"]     := AllTrim(aSX2[3][2])
jSX2["X2_MODO"]     := aSX2[4][2]
jSX2["X2_MODOUN"]   := aSX2[5][2]
jSX2["X2_MODOEMP"]  := aSX2[6][2]
jSX2["X2_UNICO"]    := AllTrim(aSX2[7][2])

cRet := jSX2:ToJson()

aSize(aSX2, 0)
FwFreeObj(jSX2)
jSX2 := Nil

Return cRet

/*/{Protheus.doc} FuncSx3
    Função para envio dos dados da SX3
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function FuncSx3()

Local jSX3  := JsonObject():New()
Local aSX3  := FWSX3Util():GetAllFields(FWX2CHAVE())
Local aConf := {}
Local nX    := 0
Local cRet  := ""

jSX3["campos"] := {}

For nX := 1 To Len(aSX3)
    aConf := FWSX3Util():GetFieldStruct( aSX3[nX] )
    
    aAdd(jSX3["campos"],JsonObject():New())
    jSX3["campos"][nX]["X3_CAMPO"]  := aConf[1]
    jSX3["campos"][nX]["X3_TIPO"]   := aConf[2]
    jSX3["campos"][nX]["X3_TAMANHO"]:= aConf[3]
    jSX3["campos"][nX]["X3_DECIMAL"]:= aConf[4]
    jSX3["campos"][nX]["X3_DESCRIC"]:= FWSX3Util():GetDescription( aSX3[nX] )
    
    aSize(aConf, 0)    

Next nX

cRet := jSX3:ToJson()

aSize(aSX3, 0)
FwFreeObj(jSX3)
jSX3 := Nil

Return cRet

/*/{Protheus.doc} FuncSx3
    Função para envio dos dados da SIX
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function FuncSix()

Local jSIX      := JsonObject():New()
Local aSIX      := FWSIXUtil():GetAliasIndexes(FWX2CHAVE())
Local nX        := 0
Local nI        := 0
Local cIndice   := ""
Local cRet      := ""

jSIX["indices"] := {}

For nX := 1 To Len(aSIX)

    For nI := 1 To Len(aSIX[nX])
        cIndice += aSIX[nX][nI] + "+"
    Next nI

    cIndice := SubStr(cIndice, 1, Len(cIndice) - 1)

    aAdd(jSIX["indices"],JsonObject():New())
    jSIX["indices"][nX]["INDICE"]  := FWX2CHAVE()
    jSIX["indices"][nX]["ORDEM"]   := nX
    jSIX["indices"][nX]["CHAVE"]   := cIndice

    cIndice := ""   

Next nX

cRet := jSIX:ToJson()

aSize(aSIX, 0)
FwFreeObj(jSIX)
jSIX := Nil

Return cRet

/*/{Protheus.doc} FuncSx3
    Função para envio dos dados da SX6
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function FuncSx6()

Local jSX6      := JsonObject():New()
Local nPos      := 0
Local nContador := 0
Local cQuery    := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("SX6") + " WHERE D_E_L_E_T_ = ''"
Local nTotal    := 0

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " FuncSx6 - Inicio")

cQuery := ChangeQuery(cQuery)
ConOut(cQuery)
TCQuery cQuery New Alias "QRY_SX6"
Count To nTotal
QRY_SX6->(DbGoTop())

ObjJson(1)
jSX6["parametros"] := {}

While !QRY_SX6->( Eof() )
    SX6->(dbGoto(QRY_SX6->REC))

    aAdd(jSX6["parametros"],JsonObject():New())

    nPos := Len(jSX6["parametros"])

    jSX6["parametros"][nPos]["X6_FIL"]      := SX6->X6_FIL
    jSX6["parametros"][nPos]["X6_VAR"]      := SX6->X6_VAR
    jSX6["parametros"][nPos]["X6_TIPO"]     := SX6->X6_TIPO
    jSX6["parametros"][nPos]["X6_CONTEUD"]  := AllTrim(SX6->X6_CONTEUD)

    ObjJson(2, aDados[2], aDados[1], aDados[3], "SX6", AllTrim(SX6->X6_VAR), "", jSX6["parametros"][nPos]:ToJson())

    nContador++
    
    If (Len(jSX6["parametros"]) == 100) .OR. (nTotal == nContador)
        PostDadAmb(ObjJson(3))   
        ObjJson(0)
        ObjJson(1)

        FwFreeObj(jSX6)
        jSX6 := Nil
        jSX6 := JsonObject():New()

        jSX6["parametros"] := {}
    EndIf

	QRY_SX6->(DbSkip())
End

QRY_SX6->(DbCloseArea())
ObjJson(0)

LjGrvLog("RmiDadAmbi - Thread: " + cValToChar(ThreadID()), " FuncSx6 - Fim")

Return Nil

/*/{Protheus.doc} Binario
    Função para envio da data do binario
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function Binario()

ObjJson(1)
ObjJson(2, aDados[2], aDados[1], aDados[3], "Binario", "Binario", GetSrvVersion())
PostDadAmb(ObjJson(3))
ObjJson(0)

Return Nil

/*/{Protheus.doc} AtlzData
    Atualiza no assinante a data da última atualização dos dados do ambiente
    @type  Function
    @author Bruno Almeida
    @since 04/10/2024
    @version P12
    @return Nil
/*/
Static Function AtlzData()

Local jConfig := JsonObject():New()

MHO->(dbSetOrder(1)) //MHO_FILIAL+MHO_COD
If MHO->(dbSeek(xFilial("MHO") + PadR("TOTVS PDV",TamSx3("MHO_COD")[1]," ")))
    jConfig:FromJson(MHO->MHO_CONFIG)
    jConfig["dadosambiente"] := FWTimeStamp(2)

    If MHO->(RecLock("MHO",.F.,,,IsBlind()))
        MHO->MHO_CONFIG := jConfig:ToJson()
        MHO->(MsUnLock())
    EndIf
EndIf

FwFreeObj(jConfig)
jConfig := Nil

Return Nil

/*/{Protheus.doc} getRmiToke
    Retorna o novo token que foi gerado na rotina dentro do fonte RmiIntePdv.prw (GeraToken)
    @type  Function
    @author Bruno Almeida
    @since 14/10/2024
    @version P12
    @return Nil
/*/
Static Function getRmiToke()

Local jConfig   := JsonObject():New()
Local aRet      := Array(1)

MHO->(dbSetOrder(1)) //MHO_FILIAL+MHO_COD
If MHO->(dbSeek(xFilial("MHO") + PadR("TOTVS PDV",TamSx3("MHO_COD")[1]," ")))
    If !Empty(MHO->MHO_CONFIG)
        jConfig:FromJson(MHO->MHO_CONFIG)
        aRet[1] := jConfig["access_token"]
    EndIf
EndIf

FwFreeObj(jConfig)
jConfig := Nil

Return aRet
