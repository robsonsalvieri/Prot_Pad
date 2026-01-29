#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGDP060.CH"

#DEFINE PropriedadeRuralService agd.propriedadeRuralService.agdPropriedadeRuralService

/*/{Protheus.doc} AGDP060
Cadastro de Propriedade Rural
Relaciona a tabela NEP (Propriedade Rural) ao SA1.
@author  rodrigo.nsoledade
@since   16/09/2025
@version 1.0
/*/
Function AGDP060()
    Local oBrowse := Nil

    If (.Not. TableInDic('NEV')) .Or. (.Not. TableInDic('NEX'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

    setFunName("AGDP060")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('NEP')
    oBrowse:SetDescription(STR0001) //"Dados Agronegócio"
    oBrowse:DisableDetails()
    oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}
    Local cAction := "VIEWDEF.AGDP060"

    ADD OPTION aRotina TITLE STR0002 ACTION cAction OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE STR0003 ACTION cAction OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE STR0004 ACTION cAction OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE STR0005 ACTION cAction OPERATION 5 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel
    Local oStruNEP := FWFormStruct(1, 'NEP')
    Local oEvent   := AGDP060EVT():New()

    // Criação do modelo com validações (se especificadas)
    oModel := MPFormModel():New('AGDP060')
    If !(oModel:GetOperation() != MODEL_OPERATION_UPDATE .AND. Type("A1_COD")=="U")
        oStruNEP:SetProperty('NEP_CODCLI', MODEL_FIELD_WHEN, {|| .F.})
        oStruNEP:SetProperty('NEP_LOJCLI', MODEL_FIELD_WHEN, {|| .F.})
    Endif
    // Adição dos componentes ao modelo
    oModel:AddFields('AGDP060_NEP', /*cOwner*/, oStruNEP)

    oModel:SetDescription(STR0001) // Descrições dos componentes
    oModel:GetModel('AGDP060_NEP'):SetDescription(STR0006) //"Cadastro Agronegócio"
    oModel:SetPrimaryKey({"NEP_FILIAL", "NEP_CODCLI", "NEP_LOJCLI"})
    
    oModel:InstallEvent("AGDP060EVT", /*cOwner*/, oEvent)

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel := FWLoadModel('AGDP060')
    Local oStruNEP := FWFormStruct(2, 'NEP')
    Local oView := FWFormView():New()

    oView:SetModel(oModel)
    oStruNEP:RemoveField("NEP_FILIAL")
    // Adição dos componentes da interface
    oView:AddField('VIEW_NEP', oStruNEP, 'AGDP060_NEP')

    // Criação da estrutura de layout
    oView:CreateHorizontalBox('TELA', 100)
    oView:SetOwnerView('VIEW_NEP', 'TELA')

    oView:AddUserButton(STR0012,"",{|| AGDP070CRM(SA1->A1_COD,SA1->A1_LOJA)},,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT ,MODEL_OPERATION_UPDATE} ) //"Grupo Familiar"

    // Habilitação de títulos
    oView:EnableTitleView('VIEW_NEP')

Return oView

/*/{Protheus.doc} IntegDef
IntegDef
@type function
@version 12
@author jc.maldonado
@since 20/10/2025
@param xEnt, variant, xml/obj para envio/recebimento
@param cTypeTrans, character, "0"=TRANS_SEND, "1"=TRANS_RECEIVE
@param cTypeMessage, character, Tipo Mensagem '20'=DEFINE EAI_MESSAGE_BUSINESS, '21'=DEFINE EAI_MESSAGE_RESPONSE, '22'=DEFINE EAI_MESSAGE_RECEIPT, '23'=DEFINE EAI_MESSAGE_WHOIS
@param cVersion, character, Versão
@param cTransaction, character, Nome mensagem unica
@param lEAIObj, logical, EAI Object
@return array, {lResult, xValue(oFWEAIobj ou cMsgErr)}
/*/
Static Function IntegDef(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransaction, lEAIObj)
	Default lEAIObj := .F.
Return AGDIP060(xEnt, cTypeTrans, cTypeMessage, cVersion, cTransaction, lEAIObj)

/*/{Protheus.doc} AGDP060
Tela chamada no cadastro de Cliente para alterar os Dados Agronegócio
@type function
@version 12
@author rodrigo.nsoledade
@since 17/09/2025
@return variant, nil
/*/
Function AGDP060CRM(cCodCli,cCodLoja)
	Local aArea     := GetArea()
    Local aAreaSA1  := SA1->(GetArea())
	Local oModel := nil
    Local oModelNEP := nil

    If .Not. TableInDic('NEP')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

    oModel := FwLoadModel('AGDP060')

    DbSelectArea("NEP")
    DbSetOrder(1)
    If NEP->(DBSeek(FWxFilial("NEP")+cCodCli+cCodLoja))
        FWExecView(oModel:GetDescription(), "AGDP060", MODEL_OPERATION_UPDATE, , , ,)
    Else
        oModelNEP := oModel:GetModel("AGDP060_NEP")
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        If oModel:Activate()
            oModelNEP:LoadValue('NEP_CODCLI', cCodCli)
            oModelNEP:LoadValue('NEP_LOJCLI', cCodLoja)
            oModelNEP:LoadValue('NEP_NOMCLI', Posicione("SA1",1,xFilial("SA1")+cCodCli+cCodLoja,"A1_NOME"))

            FWExecView(oModel:GetDescription(), "AGDP060", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)
        Endif
    Endif

	RestArea(aArea)
    RestArea(aAreaSA1)

Return .T.

/*/{Protheus.doc} ValidaGeoLoc
Função para validar coordenadas de Latitude/Longitude 
em graus decimais (ex.: -12.1234).
@author rodrigo.nsoledade
@since 23/09/2025
@return .T. se válido, .F. caso contrário
/*/
Function AgdValGeoLoc()
    Local lRet         := .T.
    Local cReadVar     := ReadVar()
    Local oPropService := PropriedadeRuralService():New()

    If "NEP_LATIT" $ cReadVar
        If !oPropService:validaGeoLocal(M->NEP_LATIT, "LAT")
            AGDHELP(STR0007, STR0008, STR0009) //"Ajuda"#"Latitude inválida."#"Informe um valor entre -90.0000 e 90.0000 graus."
            Return .F.
        EndIf
    ElseIf "NEP_LONGI" $ cReadVar
        If !oPropService:validaGeoLocal(M->NEP_LONGI, "LON")
            AGDHELP(STR0007, STR0010, STR0011) //"Ajuda"#"Longitude inválida."#"Informe um valor entre -180.0000 e 180.0000 graus."
            Return .F.
        EndIf
    EndIf

Return lRet


/*/{Protheus.doc} AGDP060REL
Carrega o init Padrao (X3_RELACAO)
@author carlos.augusto
@since 10/10/2025
@return cRetorno, posicione de acordo com a tela aberta
/*/
Function AGDP060REL()
	Local cRetorno := ""

    //Acesso via CRMA980 (cadastro de clientes). Tabela SA1 sempre posicionada
	If FWIsInCallStack("AGDP060CRM")
		cRetorno := POSICIONE("NEX",2,XFILIAL("NEX")+SA1->A1_COD+SA1->A1_LOJA,"NEX_CODGRP")
	Else
        cRetorno := IIF(!INCLUI,POSICIONE("NEX",2,XFILIAL("NEX")+NEP->NEP_CODCLI+NEP->NEP_LOJCLI,"NEX_CODGRP"),"")
	EndIf
Return cRetorno




