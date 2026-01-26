#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLMAPPEDIDOS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapPedidos
Browser de Pedidos da Integração

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapPedidos()

	Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("B7F")
	oBrowse:SetDescription(STR0001) // "Pedidos da Integração"

    If IsInCallstack("PLMapIntegra")
        oBrowse:SetDescription(STR0001+" - "+Alltrim(B7E->B7E_DESCRI)) // "Pedidos da Integração"
        oBrowse:SetFilterDefault("B7F_CODIGO == '"+B7E->B7E_CODIGO+"'")
    Else
        oBrowse:SetDescription(STR0001) // "Pedidos da Integração"
    EndIf

    oBrowse:AddLegend("B7F_STATUS == '0'", "WHITE", STR0002) // "Pendente de Envio"
    oBrowse:AddLegend("B7F_STATUS == '1'", "GREEN", STR0003) // "Envio Realizado"
    oBrowse:AddLegend("B7F_STATUS == '2'", "BLACK", STR0004) // "Erro de Envio"
    oBrowse:AddLegend("B7F_STATUS == '3'", "RED", STR0005) // "Envio Cancelado"

    oBrowse:SetMenuDef("PLMapPedidos")
    
	oBrowse:Activate()
		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Pedidos da Integração

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.PLMapPedidos" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.PLMapPedidos" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0010 ACTION "FwMsgRun(,{|| PLMapConnect(.T.)},,'"+STR0011+"')" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Comunicar" ; "Comunicando com a Integração..." 
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.PLMapPedidos" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.PLMapPedidos" OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir" 

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo dos Pedidos da Integração

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel := Nil
    Local oStruB7F := FWFormStruct(1, "B7F")
    Local oStruB7E := FWFormStruct(1, "B7E")

    oStruB7E:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
    oStruB7E:SetProperty("*", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, ""))

	oModel := MPFormModel():New("PLMapPedidos")
	oModel:SetDescription(STR0012) // "Cadastro de Pedidos da Integração"

	oModel:AddFields("MASTERB7F",, oStruB7F)
    oModel:AddFields("DETAILB7E", "MASTERB7F", oStruB7E)

    oModel:SetRelation("DETAILB7E", {{"B7E_FILIAL", "xFilial('B7E')"},;
                                     {"B7E_CODOPE", "B7F_CODOPE" },;
                                     {"B7E_CODIGO", "B7F_CODIGO" },;
                                     {"B7E_ALIAS", "B7F_ALIAS" }},;
                                     B7E->(IndexKey(1)))

    oModel:GetModel("DETAILB7E"):SetOnlyView(.T.)
    oModel:GetModel("DETAILB7E"):SetOnlyQuery(.T.)

    oModel:GetModel("MASTERB7F"):SetDescription(STR0013) // "Dados do Pedido"
    oModel:GetModel("DETAILB7E"):SetDescription(STR0014) // "Dados da Integração" 
    		
	oModel:SetPrimaryKey({})                                                                                                                                                                                                                              
	 
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View dos Pedidos da Integração

@author Vinicius Queiros Teixeira
@since 16/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("PLMapPedidos")
	Local oView := Nil
    Local oStruB7F := FWFormStruct(2, "B7F")
    Local oStruB7E := FWFormStruct(2, "B7E")
    
    oStruB7E:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
    oStruB7E:SetProperty("*", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, ""))

    oStruB7E:RemoveField("B7E_CODOPE")
    oStruB7E:RemoveField("B7E_CODIGO")
    oStruB7E:RemoveField("B7E_ALIAS")
    oStruB7E:RemoveField("B7E_PASAUT")
    oStruB7E:RemoveField("B7E_BEAAUT")
    oStruB7E:RemoveField("B7E_COOAUT")
    oStruB7E:RemoveField("B7E_TMPAUT")

	oView := FWFormView():New()
	oView:SetModel(oModel)

    oView:AddField("FORM_PEDIDO", oStruB7F, "MASTERB7F") 
    oView:AddField("FORM_INTEGRACAO", oStruB7E, "DETAILB7E") 
	
    oView:EnableTitleView("FORM_PEDIDO", STR0013) // "Dados do Pedido"
	oView:EnableTitleView("FORM_INTEGRACAO", STR0014) // "Dados da Integração"

    oView:CreateHorizontalBox("BOX_FORM_PEDIDO", 60)
	oView:CreateHorizontalBox("BOX_FORM_INTEGRACAO", 40)
    
    oView:SetOwnerView("FORM_PEDIDO", "BOX_FORM_PEDIDO")
	oView:SetOwnerView("FORM_INTEGRACAO", "BOX_FORM_INTEGRACAO")
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLMapConnect
Realiza a Conexão com a Integração via Rest do Pedido posicionado  

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLMapConnect(lMsg, lPositionIntegra, aAutomacao)

    Local lConnect := .T.
    Local cMensagem := ""
    Local aPedidoEmpre := {}
    Local cMsgValidacao := ""
    Local oMontaJson := Nil
    Local oConnect := Nil
    Local cClasse := ""
    Local cChave := ""
    Local cChaveEmpre := ""
    Local cJson := ""
    Local aAreaB7E := B7E->(GetArea())
    local nStatusPost := 0

    Default lMsg := .F. 
    Default lPositionIntegra := .F.
    Default aAutomacao := {}

    If lMsg
        If !MsgYesNo(STR0027, STR0028) // "Deseja realizar a comunicação com a Integração para o pedido selecionado?" - "Comunicação"
            Return
        EndIf
    EndIf

    If !IsInCallstack("PLMapIntegra") .Or. lPositionIntegra
        B7E->(DBSetOrder(1))
        If !B7E->(MsSeek(xFilial("B7E")+B7F->(B7F_CODOPE+B7F_CODIGO+B7F_ALIAS)))
            lConnect := .F.
            cMensagem := STR0015 // "A Integração do Pedido não foi Encontrado."
        EndIf
    EndIf

    If lConnect
        cMsgValidacao := ValidConnect()
        If !Empty(cMsgValidacao)
            lConnect := .F.
            cMensagem := cMsgValidacao
        EndIf
    EndIf 
    
    If lConnect
        cClasse := Alltrim(B7E->B7E_CLACOM)
        cChave := Alltrim(B7F->B7F_CHAVE)

        // Endpoint de Beneficiário, Obrigatório o Envio da Empresa antes.(caso não tenha enviado)
        If cClasse == "PLMapJsBenef" .And. B7F->B7F_ALIAS == "BA1"
            cChaveEmpre := SubStr(cChave, 1, 8)

            If !CheckEnvPedido(cChaveEmpre, "BG9")
                aPedidoEmpre := GrvPedEmpBenef(cChaveEmpre, "PLMapStpEmpre")

                If Len(aPedidoEmpre) >= 3 
                    If !ComunPedido(aPedidoEmpre, aAutomacao)
                        lConnect := .F.
                        cMensagem := STR0029 // "Falha ao Enviar o Pedido da Empresa do Beneficiário, verifique o Pedido na Integração da Empresa"
                    EndIf               
                Else
                    lConnect := .F.
                    cMensagem := STR0030 // "Falha ao Gerar Pedido para a Empresa do Beneficiário, verifique a Integração do Cadastro de Empresas."                  
                EndIf
            EndIf
        EndIf

        If lConnect 
            oMontaJson := &(cClasse+"():New('"+cChave+"')")
            cJson := oMontaJson:GetJson()

            oConnect := PLMapComPed():New(cJson, aAutomacao)
            oConnect:Setup(B7F->B7F_CODOPE, B7F->B7F_CODIGO, B7F->B7F_CODPED, cClasse)

            nStatusPost := oConnect:PostApi()
            If  nStatusPost == 1
                cMensagem := STR0016 // "Pedido Enviado com sucesso para a Integração!"
            Else
                If oConnect:GetAuthentication()
                    cMensagem := STR0017 // "Falha no Envio do Pedido, verifique o JSON de Retorno."
                Else
                    cMensagem := STR0026 // "Falha ao Realizar a Autenticação com a Integração." 
                EndIf
                lConnect := .F.
            Endif

            FreeObj(oMontaJson)
            FreeObj(oConnect)
            oMontaJson := Nil
            oConnect := Nil
        EndIf

        If lMsg
            MsgInfo(cMensagem, STR0018) // "Comunicação com a Integração"
        EndIf      
    Else
        If lMsg
            MsgInfo(cMensagem, STR0019) // "Atenção"
        EndIf 
    EndIf

    RestArea(aAreaB7E)

Return {lConnect, cMensagem}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLLtConnect
Realiza a Conexão com a Integração via Rest do Lote

@author Gabriel Mucciolo
@since 18/01/2023
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLLtConnect(lMsg, aAutomacao)

    Local cMensagem := ""
    Local oMontaJson := Nil
    Local oConnect := Nil
    Local cClasse := ""
    Local aJson := {}
    Local aPedidos := {}
    Local aResposta := {}
    Local aAreaB7E := B7E->(GetArea())
    Local cAliasTemp := ""
    Local cQuery := ""
    Local nQtdMaxLote := IIF(FieldPos("B7E_QTLOTE") > 0, B7E->B7E_QTLOTE, 1)
    Local nAux := 0
    Local nX := 0
    Local lConnect := .T.

    Default lMsg := .F. 
    Default aAutomacao := {}

    Do Case
        Case Empty(B7E->B7E_ENDPOI)
            cMensagem := STR0021 // "Não Informado o EndPoint da Integração."
        Case Empty(B7E->B7E_CLACOM) .Or. !FindClass(B7E->B7E_CLACOM)
            cMensagem := STR0022 // "Não Encontrado a Classe de Comunicação da Integração."
    EndCase

    If !Empty(cMensagem)
        lConnect := .F.
    EndIf
     
    If lConnect .AND. nQtdMaxLote > 0
        cClasse := Alltrim(B7E->B7E_CLACOM)
        //Realiza a consulta com todas as solicitações da Integração posicionada
        cAliasTemp := GetNextAlias()
        cQuery := "SELECT B7F.B7F_CHAVE CHAVE, B7F.B7F_CODPED CODPED FROM "+RetSQLName("B7F")+" B7F "
        //Join com a B7E - Integrações
        cQuery += " INNER JOIN "+RetSQLName("B7E")+" B7E " 	
        cQuery += "	    ON B7E.B7E_FILIAL = '"+xFilial("B7E")+"'" 
        cQuery += "	    AND B7E.B7E_CODOPE =  '"+Alltrim(B7E->B7E_CODOPE)+"' "
        cQuery += "	    AND B7E.B7E_CODIGO = '"+Alltrim(B7E->B7E_CODIGO)+"' "
        cQuery += "	    AND B7E.B7E_ALIAS = '"+Alltrim(B7E->B7E_ALIAS)+"' " 
        cQuery += "	    AND B7E.B7E_CLACOM = '"+Alltrim(B7E->B7E_CLACOM)+"' " 
        cQuery += "	    AND B7E.D_E_L_E_T_ = ' ' "
        //Where
        cQuery += " WHERE B7F.B7F_FILIAL = '"+xFilial("B7F")+"'"
        cQuery += "	  AND B7F.B7F_CODOPE = B7E.B7E_CODOPE"
        cQuery += "	  AND B7F.B7F_CODIGO = B7E.B7E_CODIGO"
        cQuery += "	  AND (B7F.B7F_STATUS = '0' OR B7F.B7F_STATUS = '2')" // Pendente de Envio e Erro de Envio
        cQuery += "   AND B7F.D_E_L_E_T_ = ' ' "

        dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

        If !(cAliasTemp)->(Eof())
            oMontaJson := &(cClasse+"():New()")
            While !(cAliasTemp)->(Eof())
                //Incrementa a variavel auxiliar e percorre o array até o numero maximo permitido no lote
                nAux++
                If nAux <= nQtdMaxLote
                    oMontaJson:AddListaBenef((cAliasTemp)->CHAVE)
                    aadd(aPedidos,{(cAliasTemp)->CODPED,(cAliasTemp)->CHAVE})
                Else
                    aadd(aJson,{oMontaJson:GetJson(), aPedidos})
                    nAux := 0
                    aPedidos := {}
                EndIf
                (cAliasTemp)->(DbSkip())
            EndDo
        EndIf

        For nX:= 1 to Len(aJson)
            oConnect := PLMapComPed():New(aJson[nX][1], aAutomacao)
            oConnect:Setup(B7E->B7E_CODOPE, B7E->B7E_CODIGO,'', cClasse)
            aadd(aResposta,{oConnect:PostApi(aJson[nX][2]) })
        Next

        cMensagem := IIF( Len(aResposta) > 0 .AND. Ascan(aResposta,{ |x| x[1] == 0 }) > 0, "Lote enviado, porem houveram pendências em um ou mais registros, verifique o JSON de Retorno.", IIF(Len(aResposta) > 0, "Lote enviado com Sucesso.", "Lote sem dados disponiveis."))
       
        FreeObj(oMontaJson)
        FreeObj(oConnect)
        oMontaJson := Nil
        oConnect := Nil

        If lMsg
            MsgInfo(cMensagem, STR0018) // "Comunicação com a Integração"
        EndIf      
    Else
        If lMsg
            MsgInfo(cMensagem, STR0019) // "Atenção"
        EndIf 
    EndIf

    RestArea(aAreaB7E)

Return {lConnect, cMensagem}


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidConnect
Valida a Integração e o Pedido para Comunicar com a Integração 

@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ValidConnect()

    Local cMsgValidacao := ""
    
    Do Case
        Case B7E->B7E_ATIVO == "0"
            cMsgValidacao := STR0020 // "A Integração não está Ativa no Momento."
        
        Case Empty(B7E->B7E_ENDPOI)
            cMsgValidacao := STR0021 // "Não Informado o EndPoint da Integração."
        
        Case Empty(B7E->B7E_CLACOM) .Or. !FindClass(B7E->B7E_CLACOM)
            cMsgValidacao := STR0022 // "Não Encontrado a Classe de Comunicação da Integração."

        Case B7F->B7F_STATUS == "1" 
            cMsgValidacao := STR0023 // "O Pedido já foi Enviado para a Integração."
        
        Case B7F->B7F_STATUS == "3" 
            cMsgValidacao := STR0024 // "Pedido Cancelado, não é Permitido Comunicar."

        Case B7F->B7F_TENVIO >= B7E->B7E_MAXENV
            cMsgValidacao := STR0025 // "Já foi Realizado a Quantidade Máxima de Envio para o Pedido."
        
        Case B7F->B7F_DATINC > dDataBase
            cMsgValidacao := STR0031 + DtoC(B7F->B7F_DATINC) // "O Pedido foi Programado para ser Comunicado Somente na Data Posterior a "

    EndCase  

Return cMsgValidacao


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckEnvPedido
Verifica se já possue pedido para a Chave e Alias

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckEnvPedido(cChaveBusca, cAliasPedido)

    Local cQuery := ""
    Local cCodOperadora := ""
    Local lPedidoEmpre := .F.

    Default cChaveBusca := ""
    Default cAliasPedido := ""

    If Len(cChaveBusca) >= 4
        cCodOperadora := Substr(cChaveBusca, 1, 4)
    EndIf

    cQuery := "SELECT COUNT(B7F_CODIGO) CONTADOR FROM "+RetSQLName("B7F")+" B7F "
	cQuery += " WHERE B7F.B7F_FILIAL = '"+xFilial("B7F")+"'"
	cQuery += "	  AND B7F.B7F_CODOPE = '"+cCodOperadora+"' "
    cQuery += "	  AND B7F.B7F_ALIAS = '"+cAliasPedido+"' "
	cQuery += "	  AND B7F.B7F_CHAVE LIKE '"+cChaveBusca+"%' "
	cQuery += "   AND B7F.D_E_L_E_T_ = ' ' "

	nQuant := MPSysExecScalar(cQuery, "CONTADOR")

    lPedidoEmpre := IIF(nQuant > 0, .T., .F.)

Return lPedidoEmpre


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvPedEmpBenef
Grava Empresa do Beneficiário para Integração

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GrvPedEmpBenef(cChaveEmpre, cClasseStamp)

    Local cCodOperadora := Substr(cChaveEmpre, 1, 4)
    Local cCodEmpresa := Substr(cChaveEmpre, 5, 4)
    Local cCodIntegra := ""
    Local oIntegration := Nil
    Local aRetorno := {}
    Local aAreaB7E := B7E->(GetArea())
    Local aAreaB7F := B7F->(GetArea())

    cCodIntegra := GetCodIntegEmp(cCodOperadora, "BG9", cClasseStamp)

    B7E->(DBSetOrder(1))
    If !Empty(cCodIntegra) .And. B7E->(MsSeek(xFilial("B7E")+cCodOperadora+cCodIntegra))

        oIntegration := &(cClasseStamp+"():New()")
        oIntegration:Setup(cCodOperadora, cCodIntegra,, .F.)
        oIntegration:SetDadosEsp(.F., cCodEmpresa, cCodEmpresa)
        oIntegration:ProcessDados()            
        
        If oIntegration:GetResult()[1] > 0
            lRetorno := .T.

            aAdd(aRetorno, B7F->B7F_CODOPE)
            aAdd(aRetorno, B7F->B7F_CODIGO)
            aAdd(aRetorno, B7F->B7F_CODPED)
        EndIf

        FreeObj(oIntegration)
        oIntegration := Nil

    EndIf

    RestArea(aAreaB7E)
    RestArea(aAreaB7F)

Return aRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodIntegEmp
Retorna o Codigo da Integração 

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GetCodIntegEmp(cCodOperadora, cAliasIntegra, cClasseStamp)

    Local cCodIntegra := ""
    Local cQuery := ""
    Local cAliasTemp := ""

    cAliasTemp := GetNextAlias()
    cQuery := "SELECT B7E.B7E_CODIGO FROM "+RetSQLName("B7E")+" B7E "
	cQuery += " WHERE B7E.B7E_FILIAL = '"+xFilial("B7E")+"'"
	cQuery += "	  AND B7E.B7E_CODOPE = '"+cCodOperadora+"'"
    cQuery += "	  AND B7E.B7E_ALIAS = '"+cAliasIntegra+"'"
    cQuery += "	  AND B7E.B7E_ATIVO = '1'"
    cQuery += "	  AND B7E_CLASTP = '"+cClasseStamp+"' "
	cQuery += "   AND B7E.D_E_L_E_T_= ' ' "

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(Eof()) 

        cCodIntegra := (cAliasTemp)->B7E_CODIGO

    EndIf

    (cAliasTemp)->(DBCloseArea())

Return cCodIntegra


//-------------------------------------------------------------------
/*/{Protheus.doc} ComunPedido
Realiza a Comunicação do Pedido 

@author Vinicius Queiros Teixeira
@since 09/09/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ComunPedido(aPedidoEnv, aAutomacao)

    Local lConnect := .F.
    Local cCodOperadora := ""
    Local cCodIntegra := ""
    Local cCodPedido := ""
    Local aAreaB7E := B7E->(GetArea())
    Local aAreaB7F := B7F->(GetArea())

    Default aPedidoEnv := {}
    Default aAutomacao := {}

    If Len(aPedidoEnv) >= 3
        cCodOperadora := aPedidoEnv[1]
        cCodIntegra := aPedidoEnv[2]
        cCodPedido := aPedidoEnv[3]
    EndIf

    B7F->(DBSetOrder(1))
    If B7F->(MsSeek(xFilial("B7F")+cCodOperadora+cCodIntegra+cCodPedido))

        If PLMapConnect(.F., .T., aAutomacao)[1]
            lConnect := .T.
        EndIf

    EndIf

    RestArea(aAreaB7E)
    RestArea(aAreaB7F)

Return lConnect
