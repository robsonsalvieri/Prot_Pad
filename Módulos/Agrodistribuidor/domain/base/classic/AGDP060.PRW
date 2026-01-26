#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
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

    If .Not. TableInDic('NEP')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

    setFunName("AGDP060")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('NEP')
    oBrowse:SetDescription(STR0001) //"Cadastro de Propriedade Rural"
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
    oModel:GetModel('AGDP060_NEP'):SetDescription(STR0006) //"Dados do Cadastro de Propriedade Rural"
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

    // Habilitação de títulos
    oView:EnableTitleView('VIEW_NEP')

Return oView

/*/{Protheus.doc} AGDP060
Tela chamada no cadastro de Cliente para alterar os Dados Agronegócio
@type function
@version 12
@author rodrigo.nsoledade
@since 17/09/2025
@return variant, nil
/*/
Function AGDP060CRM(cCodCli,cCodLoja)
	Local aArea  := GetArea()
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
