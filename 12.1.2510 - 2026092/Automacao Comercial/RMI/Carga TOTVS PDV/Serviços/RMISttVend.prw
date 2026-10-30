#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} IntSttVend
Envia o status das vendas pendentes para a Retaguarda
@type  Function
@author joao.marcos
@since 20/09/2024
@version v1.0
@param  cPontoCarg, character, codigo do Ponto de Integraçao
        aConfig, array, configuraçoes do Assinante
/*/
Function RMISttVend(cPontoCarg, aConfig)
Local cEndPoint     := ""
Local oConexaoApi   := Nil
Local oJDadosApi    := JsonObject():New()
Local oJRetornoApi  := JsonObject():New()
Local oJSttvenda    := JsonObject():New()
Local cPath         := "/api/retail/v1/integrapdv/integracaoVendas"
Local lConectApi    := .F.
Local cKeyRC4       := "0123456789*!@#$%&"
Local lExecuta      := .T.
Local cAssinante    := "TOTVS PDV"

Default cPontoCarg  := MV_PAR01
Default aConfig     := Iif(ExistFunc("RMICfgAss"),RMICfgAss(), lExecuta := .F.)

LjGrvLog(,"RMISttVend | Inicio | " , FWTimeStamp(2))
LjGrvLog(,"RMISttVend | lExecuta: ", AllToChar(lExecuta) )

If Empty(aConfig[1])
    lExecuta := .F.
    LjGrvLog(,"RMISttVend | aConfig[1] | Token de acesso não configurado no Assinante TOTVS PDV, não é possível acessar a API.", )
EndIf

If lExecuta
    Pergunte("RMISTTVEND",.T.)

    cEndPoint := AllTrim(aConfig[5])

    oJSttvenda['empPtoInteg']   := cEmpAnt
    oJSttvenda['filPtoInteg']   := cFilAnt
    oJSttvenda['codPtoInteg']   := cPontoCarg
    oJSttvenda['vendas']        := GetSttVda()

    LjGrvLog(,"RMISttVend | cEndPoint | EndPoint", cEndPoint )
    LjGrvLog(,"RMISttVend | cPath | cPath", cPath )
    LjGrvLog(,"RMISttVend | oJSttvenda | Status das vendas que serão enviadas", oJSttvenda:ToJson() )

    oJDadosApi['usuario']       := aConfig[3]
    oJDadosApi['senha']         := Rc4Crypt(aConfig[4], cKeyRC4, .T.)
    oJDadosApi['endpoint']      := cEndPoint
    oJDadosApi['enderecoApi']   := cPath
    oJDadosApi['tipoMetodoApi'] := "PUT"
    oJDadosApi['bodyParam']     := oJSttvenda

    oConexaoApi := RMIConexaoAPI():New(cAssinante,oJDadosApi, .F., aConfig[1])

    If oConexaoApi:lVldDadosAcesso
        oConexaoApi:ConectaApi()
        If oConexaoApi:GetComunicouApi()
            oJRetornoApi := oConexaoApi:RetornoApi()

            If oJRetornoApi['CodigoRetorno'] == "01"
                LjGrvLog(,"RMISttVend | Envio de status de venda realizado | ", FWTimeStamp(2))
                lConectApi := .T.
            EndIf
        Else
            lConectApi := .F.          
        EndIf

        If !lConectApi .OR. oJRetornoApi['CodigoRetorno'] <> "01"
            LjGrvLog(,"RMISttVend | Falha ao enviar o stauts das vendas erro: ", oJRetornoApi['Erro'] )
        EndIf
    EndIf

    FwFreeObj(oJDadosApi)
    oJDadosApi  := Nil

EndIf

LjGrvLog(,"RMISttVend | Fim | ", FWTimeStamp(2))

Return

/*/{Protheus.doc} GetSttVda
Retorna a relaçao de status das vendas que ainda nao foram integradas com a Retaguarda
@type  Static Function
@author joao.marcos
@since 20/09/2024
@version 1.0
@return aJSttvenda, array, relaçao dos status das vendas pendente integraçao
/*/
Static Function GetSttVda()
Local oJSttvenda    := JsonObject():New()
Local cQuery        := ""
Local cAliasSL1     := ""
Local aJSttvenda    := {}
Local nCont         := 0

cQuery += " SELECT L1_FILIAL, L1_EMISNF, L1_DOC,  L1_SERIE, L1_CLIENTE, L1_LOJA, L1_SITUA "
cQuery += " FROM " + RetSqlName("SL1") + " "
cQuery += " WHERE L1_FILIAL = '" + xFilial("SL1") + "' " 
cQuery += " AND L1_SITUA IN('00','ER','CP') "
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY L1_EMISNF, L1_DOC, L1_SERIE "

cQuery := ChangeQuery(cQuery)
cAliasSL1 := MPSysOpenQuery(cQuery)

While (cAliasSL1)->(!Eof())
    nCont++
    oJSttvenda    := JsonObject():New()
    
    oJSttvenda['data']      := Iif(ValType((cAliasSL1)->L1_EMISNF)=="C", (cAliasSL1)->L1_EMISNF , DtoS( (cAliasSL1)->L1_EMISNF )) 
    oJSttvenda['documento'] := (cAliasSL1)->L1_DOC
    oJSttvenda['serie']     := (cAliasSL1)->L1_SERIE
    oJSttvenda['cliente']   := (cAliasSL1)->L1_CLIENTE
    oJSttvenda['lojacli']   := (cAliasSL1)->L1_LOJA
    oJSttvenda['status']    := (cAliasSL1)->L1_SITUA

    Aadd( aJSttvenda , JsonObject():New() )
    aJSttvenda[nCont] := oJSttvenda

    (cAliasSL1)->(dbSkip())

EndDo
    
Return aJSttvenda

/*/{Protheus.doc} SchedDef
Funçao obrigatoria para rotinas que serao executadas via Schedule
@type  Static Function
@author joao.marcos
@since 30/07/2024
@version v1.0
/*/
Static Function SchedDef()

Local aParam  := {}

aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
            "RMISTTVEND"        ,;  //Pergunte do relatorio, caso nao use passar ParamDef
            /*Alias*/           ,;	
            /*Array de ordens*/ ,;
            /*Titulo*/          }

Return aParam
