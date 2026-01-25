#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLINCBENMODEL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLIncBenEvent
Classe de Eventos do MVC para validar/commit o modelo PLIncBenModel
(Inclusão cadastral do beneficiário)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Class PLIncBenEvent From FWModelEvent

    Data aAnexos As Array
    Data lGeraGrupoFamiliar As Boolean

    Method New() CONSTRUCTOR

    Method After(oSubModel, cModelId, cAlias, lNewRecord)
    Method Before(oSubModel, cModelId, cAlias, lNewRecord)
    Method AfterTTS(oModel, cModelId)                                                       
    Method BeforeTTS(oModel, cModelId)                                                     
    Method InTTS(oModel, cModelId)                                                          
    Method Activate(oModel, lCopy)
    Method DeActivate(oModel)   
    Method VldActivate(oModel, cModelId)
    Method ModelPreVld(oModel, cModelId)
    Method ModelPosVld(oModel, cModelId)
    Method GridPosVld(oSubModel, cModelID)
    Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
    Method GridLinePosVld(oSubModel, cModelID, nLine)                                       
    Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue)
    Method FieldPosVld(oSubModel, cModelID)                  

    // Métodos auxiliares
    Method CheckPlanoEmpresa(oSubModel, cTipo, cPlano, cVersao)
    Method GetDadosValidANS(oSubModel, oModelBBA)
    Method ValidCmpObrigat(oSubModel, nItem) 
    Method GetCamposObrigat()
    Method DownloadAnexos()
    Method AnexarArquivos(cAlias, cChaveDocument)
    Method VerificaFamilia(cMatric)
    Method GetVersaoPlano(cOperadora, cPlano)
    Method GravaBeneficiarios(oModel)
    Method SetGrvGrupoFamiliar()
    Method ReplicBancoConhecimento(oModel, aBeneficiarios)
    Method CheckDadosCliente(cCodCli, cLoja)
    Method VerInfoSIB(oModelBBA)
 
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PLIncBenEvent

    Self:aAnexos := {}
    Self:lGeraGrupoFamiliar := .F.

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do commit 
depois da gravação de cada submodelo (field ou cada linha de uma grid)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PLIncBenEvent

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Before
Método que é chamado pelo MVC quando ocorrer as ações do commit antes 
da gravação de cada submodelo (field ou cada linha de uma grid)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PLIncBenEvent    

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a 
transação. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method AfterTTS(oModel, cModelId) Class PLIncBenEvent


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes 
da transação. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method BeforeTTS(oModel, cModelId) Class PLIncBenEvent
    
    Local cChaveDocument := xFilial("BBA")+oModel:GetValue("MASTERBBA", "BBA_CODSEQ")

    If Len(Self:aAnexos) > 0
        If Self:AnexarArquivos("BBA", cChaveDocument)

            If oModel:GetValue("MASTERBBA", "BBA_STATUS") == "1" // 1 = Pendente de Documentação
                oModel:LoadValue("MASTERBBA", "BBA_STATUS", "2") // 2 = Em Analise
            EndIf
        EndIf
    EndIf

    If Self:lGeraGrupoFamiliar
        Self:GravaBeneficiarios(oModel)
    EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após 
as gravações porém antes do final da transação. Esse evento ocorre 
uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method InTTS(oModel, cModelId) Class PLIncBenEvent

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model. 
Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method Activate(oModel, lCopy) Class PLIncBenEvent


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a desativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method DeActivate(oModel) Class PLIncBenEvent

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação 
do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method VldActivate(oModel, cModelId) Class PLIncBenEvent

    Local lOK := .T.

    If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
        Do Case 
            Case !(BBA->BBA_STATUS == "1" .Or. (BBA->BBA_STATUS == "2" .And. !ExistCpo("B5G", BBA->(BBA_CODINT+BBA_CODSEQ), 3))) // 1 = Pendente de Documentação ; B5G = Passos da Analise
                Help("", 1, "VALID", Nil, STR0004,  1, 0) // "Não é permitido excluir ou alterar protocolo de solicitação quando estiver em analise ou finalizado."
                lOk := .F.
            
            Case BBA->BBA_TIPMAN == "2" // 2 = Alteração
                Help("", 1, "VALID", Nil, STR0031,  1, 0) // "Não é permitido alterar ou excluir um protocolo de solicitação de alteração cadastral."
                lOk := .F.
        EndCase
    EndIf

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method ModelPreVld(oModel, cModelId) Class PLIncBenEvent

    Local lOK := .T.

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method ModelPosVld(oModel, cModelId) Class PLIncBenEvent

    Local lOK := .T.
    Local cNumeroProtocolo := ""
    Local oModelBBA := oModel:GetModel("MASTERBBA")
    
    If Empty(oModelBBA:GetValue("BBA_NROPRO"))

        cNumeroProtocolo := Posicione("BA0", 1, xFilial("BA0")+oModelBBA:GetValue("BBA_CODINT"), "BA0_SUSEP") + DToS(dDataBase) + oModelBBA:GetValue("BBA_CODSEQ")
        oModelBBA:SetValue("BBA_NROPRO", cNumeroProtocolo)

    EndIf

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GridPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós validação 
do Grid.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method GridPosVld(oSubModel, cModelID) Class PLIncBenEvent

    Local lOK := .T.
    Local nX := 0
    Local nQtdTitular := 0
    Local cCpfTitular := ""
    Local cNomeTitular := ""
    Local cPlanoTitular := ""
    Local cGrauTititular := GetNewPar("MV_PLCDTGP", "01")
    Local oModel := FWModelActive() 
    Local oModelBBA := oModel:GetModel("MASTERBBA")   
    Local aCriticasANS := {}
    Local oDadosAnexos := Nil
    Local aSaveLines := FWSaveRows()
    local dFamilyIncDate := ctod(" / / ") as date
    local lFldPosDatInc := B2N->(fieldPos("B2N_DATINC")) > 0 as logical
    local dHolderIncDate := ctod(" / / ") as date
    local nLenModel as numeric

    Do Case
        Case cModelID == "DETAILB2N"
            // Obtém a data de inclusão da família
            if lFldPosDatInc .and. !empty(oModelBBA:getValue("BBA_MATRIC"))
                BA3->(dbSetOrder(1))
                if BA3->(msSeek(xFilial("BA3") + substr(oModelBBA:getValue("BBA_MATRIC"), 1 , 14)))
                    dFamilyIncDate := BA3->BA3_DATBAS
                endif
            endif

            nLenModel := oSubModel:Length()
            For nX := 1 To nLenModel
                oSubModel:GoLine(nX)

                If oSubModel:IsDeleted()
                    Loop
                EndIf

                // Valida campos obrigatorios
                If !Self:ValidCmpObrigat(oSubModel, nX)
                    lOk := .F.
                    Exit
                EndIf

                If cGrauTititular == oSubModel:GetValue("B2N_GRAUPA") .And. !Empty(oModelBBA:GetValue("BBA_MATRIC"))
                    Help("", 1, "VALID", Nil,  STR0005+"["+STR0006+cValToChar(nX)+"]",  1, 0) // "Não é permitido incluir o títular quando a matricula do protocolo (BBA_MATRIC) estiver preenchida." ; "Item: " 
                    lOk := .F.
                    Exit
                EndIf
                
                If cGrauTititular == oSubModel:GetValue("B2N_GRAUPA")
                    nQtdTitular++

                    If nQtdTitular > 1
                        Help("", 1, "VALID", Nil, STR0007,  1, 0) // "Não é permitido incluir mais de um títular na familia."
                        lOk := .F.
                        Exit
                    EndIf
                EndIf

                // Valida críticas para atender a ANS (SIB)
                aCriticasANS := PLSVLMBEN(Self:GetDadosValidANS(oSubModel,oModelBBA))

                If !aCriticasANS[1]
                    Help("", 1, "VALID", Nil, aCriticasANS[2]+"["+STR0006+cValToChar(nX)+"]",  1, 0) // "Item: "
                    lOk := .F.
                    Exit
                EndIf
            
                oSubModel:LoadValue("B2N_CODEMP", oModelBBA:GetValue("BBA_CODEMP"))
                oSubModel:LoadValue("B2N_CONEMP", oModelBBA:GetValue("BBA_CONEMP"))
                oSubModel:LoadValue("B2N_SUBCON", oModelBBA:GetValue("BBA_SUBCON"))
                
                If Empty(oSubModel:GetValue("B2N_CODPRO"))
                    lOK := oSubModel:SetValue("B2N_CODPRO", oModelBBA:GetValue("BBA_CODPRO"))
                Else
                    lOK := oSubModel:SetValue("B2N_CODPRO", oSubModel:GetValue("B2N_CODPRO")) // Força chamada para validar o campo
                EndIf

                If !lOK
                    Exit
                EndIf

                If cGrauTititular == oSubModel:GetValue("B2N_GRAUPA")
                    cCpfTitular := Alltrim(oSubModel:GetValue("B2N_CPFUSR"))
                    cNomeTitular := Alltrim(oSubModel:GetValue("B2N_NOMUSR"))
                    cPlanoTitular := Alltrim(oSubModel:GetValue("B2N_CODPRO"))

                    if lFldPosDatInc .and. !empty(oSubModel:getValue("B2N_DATINC"))
                        dHolderIncDate := oSubModel:getValue("B2N_DATINC")
                    endif 
                EndIf

                If !Empty(oModelBBA:GetValue("BBA_MATRIC"))

                    If Self:VerificaFamilia(oModelBBA:GetValue("BBA_MATRIC"))
                        Help("", 1, "VALID", Nil, STR0032,  1, 0) // Familia Bloqueada! Não é possível realizar a inclusão de um novo beneficiário.
                        lOk := .F.   
                        Exit           
                    EndIf

                    if lFldPosDatInc .and. !empty(oSubModel:getValue("B2N_DATINC"))
                        if cGrauTititular <> oSubModel:getValue("B2N_GRAUPA") .and. oSubModel:getValue("B2N_DATINC") < dFamilyIncDate
                            help("", 1, "VALID", nil, STR0036,  1, 0) // "A data de inclusão do dependente não pode ser anterior à data de inclusão da família ou do titular."
                            lOk := .F.   
                            exit   
                        endif
                    endif
                EndIf
        
            Next nX

            // Validações do Títular na Inclusão de uma nova Familia
            If lOK .And. Empty(oModelBBA:GetValue("BBA_MATRIC"))
                Do Case
                    Case nQtdTitular == 0 
                        Help("", 1, "VALID", Nil, STR0008,  1, 0) // "Não foi informado nenhum beneficiário títular na Familia."
                        lOk := .F.
                    
                    Case cCpfTitular <> Alltrim(oModelBBA:GetValue("BBA_CPFTIT"))
                        Help("", 1, "VALID", Nil, STR0009,  1, 0) // "CPF do beneficiário títular diferente do CPF informado no protocolo (BBA_CPFTIT)."
                        lOk := .F.
                    
                    Case Upper(cNomeTitular) <> Upper(Alltrim(oModelBBA:GetValue("BBA_EMPBEN")))
                        Help("", 1, "VALID", Nil, STR0010,  1, 0) // "Nome do beneficiário títular diferente do nome informado no protocolo (BBA_EMPBEN)."
                        lOk := .F.
                    
                    Case cPlanoTitular <> Alltrim(oModelBBA:GetValue("BBA_CODPRO"))
                        Help("", 1, "VALID", Nil, STR0011,  1, 0) // "Codigo do plano do beneficiário títular diferente do plano informado no protocolo (BBA_CODPRO)."
                        lOk := .F.
                    
                    case lFldPosDatInc
                        for nX := 1 to nLenModel
                            oSubModel:goLine(nX)

                            if oSubModel:isDeleted() .or. (empty(oSubModel:getValue("B2N_DATINC")) .and. empty(dHolderIncDate))
                                loop
                            endif

                            if cGrauTititular <> oSubModel:getValue("B2N_GRAUPA") .and. oSubModel:getValue("B2N_DATINC") < dHolderIncDate
                                help("", 1, "VALID", nil, STR0036,  1, 0) // "A data de inclusão do dependente não pode ser anterior à data de inclusão da família ou do titular."
                                lOk := .F. 
                            endif
                        next nX
                EndCase
            EndIf

        Case cModelID == "DETAILANEXO"
            Self:aAnexos := {}

            For nX := 1 To oSubModel:Length()
                oSubModel:GoLine(nX)

                If !oSubModel:IsInserted() .And. !oSubModel:IsUpdated()
                    Loop
                EndIf

                if !empty(oSubModel:getValue("FILENAME"))
                    do case
                        case !empty(oSubModel:getValue("DIRECTORY"))
                            oDadosAnexos := JsonObject():new()

                            oDadosAnexos["userDirectory"] := alltrim(oSubModel:getValue("DIRECTORY"))
                            oDadosAnexos["fileName"] := alltrim(oSubModel:getValue("FILENAME"))
                            oDadosAnexos["serverDirectory"] := "" // Server será preenchido no DownloadAnexos

                            aAdd(self:aAnexos, oDadosAnexos)

                        case !empty(oSubModel:getValue("BASE64"))
                            oDadosAnexos := JsonObject():new()

                            oDadosAnexos["base64"] := alltrim(oSubModel:getValue("BASE64"))
                            oDadosAnexos["fileName"] := alltrim(oSubModel:getValue("FILENAME"))
                            oDadosAnexos["serverDirectory"] := "" // Server será preenchido no DownloadAnexos

                            aAdd(self:aAnexos, oDadosAnexos)

                    endcase
                endif
            Next nX

            If Len(Self:aAnexos) > 0
                If !Self:DownloadAnexos()
                    lOk := .F.
                EndIf
            EndIf
    EndCase

    FWRestRows(aSaveLines)

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação 
da linha do Grid.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class PLIncBenEvent

    Local lOK := .T.
    Local cTipoEmpresa := ""
    Local oModel := FWModelActive()
    Local oModelBBA := oModel:GetModel("MASTERBBA")

    Do Case
        Case cAction == "SETVALUE" .And. cModelID == "DETAILB2N" 
            Do Case
                Case Empty(oModelBBA:GetValue("BBA_CODEMP"))
                    Help("", 1, "VALID", Nil, STR0012,  1, 0) // "Para preencher os dados dos beneficiários é necessário informar os dados da empresa no protocolo."
                    lOK := .F.
                
                Case cId == "B2N_CODPRO" .And. !Empty(xValue)
                    cTipoEmpresa := IIf(Empty(oModelBBA:GetValue("BBA_SUBCON")), "1", "2") // 1 = Pessoa Fisica; 2 = Pessoa Juridica

                    If !Self:CheckPlanoEmpresa(cTipoEmpresa, xValue)
                        Help("", 1, "VALID", Nil, STR0013,  1, 0) // "Plano informado para o beneficiário não encontrado ou inválido na empresa."
                        lOk := .F.
                    EndIf
            EndCase
        
        Case cModelID == "DETAILANEXO" 
            Do Case
                Case cAction == "SETVALUE" .And. !oSubModel:IsInserted() .And. !Empty(xCurrentValue) .And. !oSubModel:IsUpdated()
                    Help("", 1, "VALID", Nil, STR0026,  1, 0) // "Não é permitido alterar um anexo já cadastrado."
                    lOk := .F.
                
                Case cAction == "DELETE" .And. !oSubModel:IsInserted() .And. !oSubModel:IsUpdated()
                    Help("", 1, "VALID", Nil, STR0027,  1, 0) // "Não é permitido excluir um anexo já cadastrado." 
                    lOk := .F.
            EndCase
    EndCase

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação 
da linha do Grid.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method GridLinePosVld(oSubModel, cModelID, nLine) Class PLIncBenEvent 

    Local lOK := .T.
    
Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação 
do Field.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class PLIncBenEvent

    Local lOK := .T.

    If cModelID == "MASTERBBA"
        Do Case
            Case cAction == "SETVALUE" .And. cId == "BBA_MATRIC" .And. !Empty(xValue)
                BA1->(DBSetOrder(2))
                If BA1->(MsSeek(xFilial("BA1")+xValue))
                    If BA1->BA1_TIPUSU <> SuperGetMv("MV_PLCDTIT", .F., "T") .And. BA1->BA1_RESFAM == "0" // 0 = Não
                        Help("", 1, "VALID", Nil, STR0014+" ["+xValue+"]",  1, 0) // "Informe a matricula do títular da familia ou do responsavel familiar."
                        lOk := .F.
                    EndIf
                EndIf
        EndCase
    EndIf

Return lOK



//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPosVld
Método que é chamado pelo MVC quando ocorrer a ação de pós validação 
do Field.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Method FieldPosVld(oSubModel, cModelID) Class PLIncBenEvent 

    Local lOK := .T.
    Local cOperadora := ""
    Local cEmpresa := ""
    Local cContrato := ""
    Local cVerContrato := ""
    Local cSubContrato := ""
    Local cVerSubContrato := ""
    Local cCodPlano := ""
    Local cVerPlano := ""
    Local cCodCli := ""
    Local cLoja := ""
  
    If cModelID == "MASTERBBA"

        cOperadora := oSubModel:GetValue("BBA_CODINT")
        cEmpresa := oSubModel:GetValue("BBA_CODEMP")
        cContrato := oSubModel:GetValue("BBA_CONEMP")
        cVerContrato := oSubModel:GetValue("BBA_VERCON")
        cSubContrato := oSubModel:GetValue("BBA_SUBCON")
        cVerSubContrato := oSubModel:GetValue("BBA_VERSUB")
        cCodPlano := oSubModel:GetValue("BBA_CODPRO")
        cVerPlano := oSubModel:GetValue("BBA_VERSAO")
        
        if BBA->(FieldPos("BBA_CODCLI")) > 0 .and. BBA->(FieldPos("BBA_LOJA")) > 0
            cCodCli := oSubModel:GetValue("BBA_CODCLI")
            cLoja := oSubModel:GetValue("BBA_LOJA")
        endif

        BG9->(DbSetOrder(1))
        If BG9->(MsSeek(xFilial("BG9")+cOperadora+cEmpresa))
            If BG9->BG9_TIPO == "2" // 2 = Pessoa Juridica
                Do Case
                    Case Empty(cContrato) .Or. Empty(cVerContrato) .Or. Empty(cSubContrato) .Or. Empty(cVerSubContrato)
                        Help("", 1, "VALID", Nil, STR0015+" ["+cOperadora+cEmpresa+"]",  1, 0) // "Obrigatório informar o contrato e subcontrato em empresas do tipo pessoa juridica."
                        lOk := .F.

                    Case !ExistCpo("BQC", cOperadora+cEmpresa+cContrato+cVerContrato+cSubContrato+cVerSubContrato, 1)
                        Help("", 1, "VALID", Nil, STR0016+" ["+cOperadora+cEmpresa+"]",  1, 0) // "Contrato e subcontrato não encontrato na empresa."
                        lOk := .F.

                    Case !Self:CheckPlanoEmpresa("2", cCodPlano, cVerPlano)
                        Help("", 1, "VALID", Nil, STR0017+" ["+cOperadora+cEmpresa+"]",  1, 0) // "Plano informado não encontrado na empresa."
                        lOk := .F.
                EndCase          
            Else
                If !Self:CheckPlanoEmpresa("1", cCodPlano, cVerPlano)
                    Help("", 1, "VALID", Nil, STR0018+" ["+cOperadora+cEmpresa+"]",  1, 0) // "Plano informado não encontrato ou inválido."
                    lOk := .F.
                EndIf
            EndIf
        Else
            Help("", 1, "VALID", Nil, STR0019+" ["+cOperadora+cEmpresa+"]",  1, 0) // "Empresa informada não encontrada no cadastro da operadora."
            lOK := .F.
        EndIf

        if !empty(cCodCli) .And. !empty(cLoja) .And. !Self:CheckDadosCliente(cCodCli, cLoja)
            Help("", 1, "VALID", Nil, STR0034+" ["+cCodCli+cLoja+"]",  1, 0) // "Cadastro de Cliente não encontrado"
            lOk := .F.
        endif
        
    EndIf

Return lOK


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckPlanoEmpresa
Verifica se o plano informado existe para a Empresa

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/05/2022
/*/
//------------------------------------------------------------------- 
Method CheckPlanoEmpresa(cTipo, cCodPlano, cVerPlano) Class PLIncBenEvent

    Local lOk := .T.
    Local cOperadora := ""
    Local cEmpresa := ""
    Local cContrato := ""
    Local cVerContrato := ""
    Local cSubContrato := ""
    Local oModel := FWModelActive()
    Local oModelBBA := oModel:GetModel("MASTERBBA")

    Default cCodPlano := ""
    Default cVerPlano := ""

    cOperadora := oModelBBA:GetValue("BBA_CODINT")

    If cTipo == "2" // Pessoa Juridica 
        cEmpresa := oModelBBA:GetValue("BBA_CODEMP")
        cContrato := oModelBBA:GetValue("BBA_CONEMP")
        cVerContrato := oModelBBA:GetValue("BBA_VERCON")
        cSubContrato := oModelBBA:GetValue("BBA_SUBCON")
        cVerSubContrato := oModelBBA:GetValue("BBA_VERSUB")

        lOk := ExistCpo("BT6", cOperadora+cEmpresa+cContrato+cVerContrato+cSubContrato+cVerSubContrato+cCodPlano+cVerPlano, 1)
    Else // Pessoa Fisica

        lOk := ExistCpo("BI3", cOperadora+cCodPlano+cVerPlano, 1)
    EndIf

Return lOk


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckPlanoEmpresa
Retorna os dados do modelo para utilizar na função PLSVLMBEN

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 31/05/2022
/*/
//------------------------------------------------------------------- 
Method GetDadosValidANS(oSubModel,oModelBBA) Class PLIncBenEvent

    Local aDados := {}

    aAdd(aDados, {"B2N", "cB2N_NOMUSR", oSubModel:GetValue("B2N_NOMUSR"), "", .F., "B2N_NOMUSR", 0})
    aAdd(aDados, {"B2N", "dB2N_DATNAS", DToC(oSubModel:GetValue("B2N_DATNAS")), "", .F., "B2N_DATNAS", 0})
    aAdd(aDados, {"B2N", "cB2N_CPFUSR", oSubModel:GetValue("B2N_CPFUSR"), "", .F., "B2N_CPFUSR", 0})
    
    if Self:VerInfoSIB(oModelBBA)
        aAdd(aDados, {"B2N", "cB2N_MAE", oSubModel:GetValue("B2N_MAE"), "", .F., "B2N_MAE", 0})
    endif

    aAdd(aDados, {"B2N", "cB2N_NRCRNA", oSubModel:GetValue("B2N_NRCRNA"), "", .F., "B2N_NRCRNA", 0})
    aAdd(aDados, {"B2N", "cB2N_TIPUSU", oSubModel:GetValue("B2N_TIPUSU"), "", .F., "B2N_TIPUSU", 0})

Return aDados


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCmpObrigat
Valida os campos obrigatorios no modelo de acordo com o Layout
Generico

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 31/05/2022
/*/
//------------------------------------------------------------------- 
Method ValidCmpObrigat(oSubModel, nItem) Class PLIncBenEvent

    Local lValid := .T.
    Local aCmpObrigat := Self:GetCamposObrigat() // Campos definidos como Obrigatório no Layout Generico
    Local nX := 0

    For nX := 1 To Len(aCmpObrigat)

        If Empty(oSubModel:GetValue(aCmpObrigat[nX]))
            Help("", 1, "VALID", Nil, STR0020+"("+aCmpObrigat[nX]+")"+STR0021+"["+STR0006+cValToChar(nItem)+"]",  1, 0) // "O campo " ; " não foi preenchido." ; "Item: "
            lValid := .F.
            Exit
        EndIf

    Next Nx

Return lValid


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCamposObrigat
Retornar os campos que estão definidos como obrigatório no layout
generico web de Inclusão de beneficiários.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Method GetCamposObrigat() Class PLIncBenEvent

    Local cLayoutWeb := GetNewPar("MV_PLLAYIN", "") // Parametro que define o Layout utilizado na API de inclusão cadastral dos beneficiários
    Local cAliasTemp := GetNextAlias()
    Local aCampos := {"B2N_NOMUSR", "B2N_DATNAS", "B2N_SEXO", "B2N_GRAUPA", "B2N_ESTCIV"}

    BeginSQL Alias cAliasTemp

        SELECT B91_CAMPO FROM %Table:B91% B91
            INNER JOIN %Table:B7C% B7C
                ON B7C.B7C_FILIAL = %XFilial:B7C% 
               AND B7C.B7C_SEQB90 = B91.B91_SEQUEN
               AND B7C.B7C_ORDEM = B91.B91_GRUPO
               AND B7C_ALIAS = 'B2N'
               AND B7C.%notDel%

            INNER JOIN %Table:B90% B90
                ON B90.B90_FILIAL = %XFilial:B90% 
               AND B90.B90_SEQUEN = B91.B91_SEQUEN
               AND B90.B90_CHAVE = %exp:cLayoutWeb% 
               AND B90.%notDel%
               
            WHERE B91.B91_FILIAL = %XFilial:B91% 
              AND B91.B91_OBRIGA = 'T'
              AND B91.%notDel%

    EndSQL

    While !(cAliasTemp)->(EoF())
        
        aAdd(aCampos, Alltrim((cAliasTemp)->B91_CAMPO))

        (cAliasTemp)->(DbSkip())
    EndDo

    (cAliasTemp)->(DbCloseArea())

Return aCampos


//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadAnexos
Realiza o download dos anexos recebidos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/06/2022
/*/
//------------------------------------------------------------------- 
Method DownloadAnexos() Class PLIncBenEvent

    Local lDownload := .T.
	Local nX := 0
	Local cNomeArquivo := ""
	Local cDiretorio := ""
	Local cExtensao := ""
    Local lStatus := .F.
    Local cError := ""
	Local nStatusCode := 0
	Local nCodError := 0
	Local lWrite := .F.
	Local cPathWeb := GetNewPar("MV_PLURDOW", "")
    local nLenArray := 0
    local cBase64 := ""
	
	Default aDownload := {}
	Default cLocalFile := ""

    ACB->(DbSetOrder(2))

    nLenArray := len(Self:aAnexos)

	For nX := 1 To nLenArray
        do case 
            case self:aAnexos[nX]:hasProperty("userDirectory")

                cDiretorio := Self:aAnexos[nX]["userDirectory"]
                cNomeArquivo := Self:aAnexos[nX]["fileName"]

                splitPath(cDiretorio, Nil, Nil, Nil, @cExtensao)

                If At("?", cExtensao) > 0
                    cExtensao := Substr(cExtensao, 1, At("?", cExtensao)-1)
                EndIf

                If Empty(cPathWeb)
                    cPathWeb := PLSMUDSIS(GetWebDir()+GetSkinPls()+"\relatorios\")
                EndIf

                If !File(cPathWeb+cNomeArquivo+cExtensao)
                
                    If ACB->(MsSeek(xFilial("ACB")+Upper(cNomeArquivo+cExtensao)))
                        Help("", 1, "VALID", Nil, STR0030+" ["+cNomeArquivo+cExtensao+"]",  1, 0) // "Nome do arquivo ja existe no banco de conhecimento, altere o nome e tente novamente!"
                        lDownload := .F.
                        Exit
                    EndIf

                    If "HTTPS:" $ Upper(cDiretorio) .Or. "HTTP:" $ Upper(cDiretorio) // Arquivo Web
                        lWrite :=  MemoWrite(cPathWeb+cNomeArquivo+cExtensao, HttpGet(cDiretorio))
                        nStatusCode := HTTPGetStatus(@cError)

                        If !lWrite
                            nCodError := FError()
                        EndIf

                        lStatus := nStatusCode == 200
                    Else
                        lStatus := CpyT2S(cDiretorio, cPathWeb)

                        If lStatus
                            lStatus := fRename(cPathWeb+Lower(AllTrim(SubStr(cDiretorio, Rat(PLSMUDSIS('\'), cDiretorio)+1))), cPathWeb+cNomeArquivo+cExtensao) == 0 // Renomeia Arquivo
                        EndIf
                    EndIf

                    If lStatus .And. File(cPathWeb+cNomeArquivo+cExtensao)
                        Self:aAnexos[nX]["serverDirectory"] := cPathWeb+cNomeArquivo+cExtensao
                    Else    
                        Help("", 1, "VALID", Nil, STR0028+"["+cDiretorio+"]",  1, 0) // "Não foi possivel localizar o anexo informado."
                        lDownload := .F.
                        Exit
                    EndIf
                Else
                    Help("", 1, "VALID", Nil, STR0029,  1, 0) // "Já existe um anexo com esse nome de arquivo."
                    lDownload := .F.
                    Exit
                EndIf

            case self:aAnexos[nX]:hasProperty("base64")
                cBase64 := self:aAnexos[nX]["base64"]
                cNomeArquivo := self:aAnexos[nX]["fileName"]

                MemoWrite(cPathWeb + cNomeArquivo, decode64(cBase64))
    
                if file(cPathWeb + cNomeArquivo)
                    self:aAnexos[nX]["serverDirectory"] := cPathWeb + cNomeArquivo
                else
                    help("", 1, "VALID", nil, STR0028 + " [" + cNomeArquivo + "]",  1, 0) // "Não foi possivel localizar o anexo informado."
                    lDownload := .F.
                    exit
                endif
        endcase

	Next nX

Return lDownload


//-------------------------------------------------------------------
/*/{Protheus.doc} AnexarArquivos
Anexa os arquivos no protocolo - Banco de conhecimento

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/06/2022
/*/
//------------------------------------------------------------------- 
Method AnexarArquivos(cAlias, cChaveDocument) Class PLIncBenEvent

	Local nX := 0
	Local lAnexo := .F.

    If !Empty(cAlias) .And. !Empty(cChaveDocument)
        For nX := 1 To Len(Self:aAnexos)

            PLSINCONH(Self:aAnexos[nX]["serverDirectory"], cAlias, cChaveDocument, .T.)

            fErase(Self:aAnexos[nX]["serverDirectory"])
            lAnexo := .T.
        Next nX
    EndIf

Return lAnexo

//-------------------------------------------------------------------
/*/{Protheus.doc} VerificaFamilia
Verifica se da familia esta com bloqueio.

@author Cesar Almeida
@version Protheus 12
@since 05/072022
/*/
//------------------------------------------------------------------- 
Method VerificaFamilia(cMatric) Class PLIncBenEvent

    Local lRetorno := .f.
    Local cCodInt := SUBSTR(cMatric, 1, 4)
    Local cCodEmp := SUBSTR(cMatric, 5, 4)
    Local cMat := SUBSTR(cMatric, 9, 6)
    Local cAliasAux := GetNextAlias()
    Local cQuery := " "
    
    cQuery := " SELECT BA3_DATBLO "  
    cQuery += " FROM " + RetSQLName("BA3") + " 
    cQuery += " WHERE BA3_FILIAL ='" + xFilial("BA3") + " '
    cQuery += " AND BA3_CODINT = '"+cCodInt+"' "
    cQuery += " AND BA3_CODEMP = '"+cCodEmp+"' "
    cQuery += " AND BA3_MATRIC = '" + cMat + "' "
    cQuery += " AND D_E_L_E_T_ = '' "
    cQuery += " ORDER BY R_E_C_N_O_ DESC "

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasAux,.F.,.T.)

    If ! (cAliasAux)->(EMPTY(BA3_DATBLO))
        lRetorno  := .t.
    EndIf

    (cAliasAux)->(DbCloseArea())

Return lRetorno


//--------------------------------------------------------------------
/*/ {Protheus.doc} GetVersaoPlano
Retorna a Versão do Produto Saúde (Plano) Vigente

@author Vinicius Queiros Teixeira
@since 11/08/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Method GetVersaoPlano(cOperadora, cPlano) Class PLIncBenEvent

	Local cVersao := ""
	Local cQuery := ""
	Local cAliasTemp := ""

	Default cOperadora := PlsIntPad()
	Default cPlano := ""

	cAliasTemp := GetNextAlias()
	cQuery := " SELECT BIL.BIL_VERSAO FROM " + RetSQLName("BIL") + " BIL "
	cQuery += " WHERE BIL.BIL_FILIAL = '"+xFilial("BIL")+"' "
	cQuery += "   AND BIL.BIL_CODIGO = '"+cOperadora+cPlano+"' "
	cQuery += "   AND BIL.BIL_DATFIN = ' ' "
	cQuery += "   AND BIL.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTemp, .F., .T.) 

	While !(cAliasTemp)->(Eof())
		cVersao := (cAliasTemp)->BIL_VERSAO

		(cAliasTemp)->(DbSkip())
	EndDo

	(cAliasTemp)->(DbCloseArea())

Return cVersao


//--------------------------------------------------------------------
/*/ {Protheus.doc} GravaBeneficiarios
Realiza a gravação dos beneficiário solicitados no Grupo Familiar

@author Vinicius Queiros Teixeira
@since 11/08/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Method GravaBeneficiarios(oModel) Class PLIncBenEvent

    Local lGrava := .F.
    Local nX := 0
    Local nY := 0
    Local oModelBBA := Nil
    Local oModelB2N := Nil
    Local aDadosAux := {}
    Local aDadosBenef := {}
    Local aDadosFam := {}
    Local aRetFamilia := {}
    Local aCamposB2N := {}
    Local aCamposBA1 := {}
    Local cTipoTitular := GetNewPar("MV_PLCDTIT", "T")
    Local lTitularSolic := .F.
    Local cMatricFamilia := ""
    Local cCampo := ""
    Local oBeneficiaries := Nil
    Local nPosBenef := 0
    Local aSaveLines := FWSaveRows()
    Local lOriInc := .T.
    Local aRetRsOpc := {}
    Local nLnOpc := 0
    Local nLnOpcGrv := 0

    oModelBBA := oModel:GetModel("MASTERBBA")
    oModelB2N := oModel:GetModel("DETAILB2N")

    Inclui   := .T.
    lPrim260 := .F.

    If !Empty(oModelBBA:GetValue("BBA_MATRIC"))
        cMatricFamilia := Substr(oModelBBA:GetValue("BBA_MATRIC"), 1, 14)
    endIf

    if BBA->(FieldPos("BBA_CODCLI")) > 0 .and. BBA->(FieldPos("BBA_LOJA")) > 0 .and. !Empty(oModelBBA:GetValue("BBA_CODCLI")) .And. !Empty(oModelBBA:GetValue("BBA_LOJA"))
        aAdd(aDadosFam, {"BA3_CODCLI", oModelBBA:GetValue("BBA_CODCLI")})
        aAdd(aDadosFam, {"BA3_LOJA", oModelBBA:GetValue("BBA_LOJA")})
    endIf

    aCamposB2N := FWSX3Util():GetListFieldsStruct("B2N", .F.)
    aCamposBA1 := FWSX3Util():GetListFieldsStruct("BA1", .F.)

    For nX := 1 To oModelB2N:Length()

        oModelB2N:GoLine(nX)

        aDadosAux := {}

        If oModelB2N:GetValue("B2N_TIPUSU") == cTipoTitular
            lTitularSolic := .T. 
        EndIf

        aAdd(aDadosAux, {"BA1_CODINT", oModelBBA:GetValue("BBA_CODINT")})
        aAdd(aDadosAux, {"BA1_CODEMP", oModelBBA:GetValue("BBA_CODEMP")})
        aAdd(aDadosAux, {"BA1_CONEMP", oModelBBA:GetValue("BBA_CONEMP")})
        aAdd(aDadosAux, {"BA1_VERCON", oModelBBA:GetValue("BBA_VERCON")})
        aAdd(aDadosAux, {"BA1_SUBCON", oModelBBA:GetValue("BBA_SUBCON")})
        aAdd(aDadosAux, {"BA1_VERSUB", oModelBBA:GetValue("BBA_VERSUB")})

        If cTipoTitular == oModelB2N:GetValue("B2N_TIPUSU")
            aAdd(aDadosAux, {"BA1_CODPLA", oModelBBA:GetValue("BBA_CODPRO")})
            aAdd(aDadosAux, {"BA1_VERSAO", oModelBBA:GetValue("BBA_VERSAO")})
        Else
            aAdd(aDadosAux, {"BA1_CODPLA", oModelB2N:GetValue("B2N_CODPRO")})
            aAdd(aDadosAux, {"BA1_VERSAO", Self:GetVersaoPlano(oModelBBA:GetValue("BBA_CODINT"), oModelB2N:GetValue("B2N_CODPRO"))})
        EndIf

        aAdd(aDadosAux, {"BA1_LOCATE", "1"})
        aAdd(aDadosAux, {"BA1_LOCEMI", "1"})
        aAdd(aDadosAux, {"BA1_LOCANS", "1"})
        aAdd(aDadosAux, {"BA1_LOCSIB", "0"})
        aAdd(aDadosAux, {"BA1_REEWEB", "0"})

        For nY := 1 To Len(aCamposB2N)

            cCampo := "BA1_"+Substr(aCamposB2N[nY][1], 5)

            If aScan(aCamposBA1, {|x| x[1] == cCampo }) > 0
                aAdd(aDadosAux, {cCampo, oModelB2N:GetValue(aCamposB2N[nY][1])})
            EndIf

        Next nY

        aAdd(aDadosBenef, aDadosAux)

    Next nX

    aRetFamilia := PLSINCGFAM(aDadosBenef, Nil, cMatricFamilia, lOriInc, aDadosFam)

    If aRetFamilia[1]
        lGrava := .T.

        oModel:loadValue("MASTERBBA", "BBA_STATUS", "7") // 7 = Aprovado Automaticamente

        oBeneficiaries := PLGetBenFields(aRetFamilia[4])

        For nX := 1 To oModelB2N:length()
            oModelB2N:goLine(nX)

            oModelB2N:loadValue("B2N_FLGCTR", "1") // 1 = Sim
            oModelB2N:loadValue("B2N_STATUS", "2") // 2 = Aprovado

            If B2N->(fieldPos("B2N_MATGRF")) > 0 .And. oBeneficiaries["found"]
                // Realiza a busca do beneficiário pelo CPF ou Nome e Data de Nascimento (Quando não houver CPF - Situação para menores de 18 anos)
                nPosBenef := AsCan(oBeneficiaries["beneficiaries"], {|x|;
                                   (alltrim(x["cpf"]) == alltrim(oModelB2N:getValue("B2N_CPFUSR")) .And. !empty(oModelB2N:getValue("B2N_CPFUSR"))) .Or.;
                                   (alltrim(upper(x["name"])) == alltrim(upper(oModelB2N:getValue("B2N_NOMUSR"))) .And. x["birthDate"] == oModelB2N:getValue("B2N_DATNAS"));
                                   })
                If nPosBenef > 0
                    oModelB2N:loadValue("B2N_MATGRF", oBeneficiaries["beneficiaries"][nPosBenef]["subscriberId"])
                EndIf
            EndIf
        Next nX

        If Len(Self:aAnexos) > 0
            Self:ReplicBancoConhecimento(oModel, aRetFamilia[4])
        EndIf

        //grava o resultado dos opcionais na tabela temporaria que sera utilizada
        //no fonte PLIncRestModel para retornar as informacoes dos opcionais
        //no padrao de retorno da API
        If Len(aRetFamilia) >= 5 .AND. Select("INCOP") > 0
           
            aRetRsOpc := aRetFamilia[5]
            nLnOpcGrv := LEN(aRetRsOpc)
           
            For nLnOpc := 1 To nLnOpcGrv
               
                INCOP->(RecLock("INCOP",.T.))
                INCOP->MATRICULA := aRetRsOpc[nLnOpc]["beneficiaryRegister"]
                INCOP->RESULT    := aRetRsOpc[nLnOpc]["resultOptionalAdditions"]:toJSON()
                INCOP->(MsUnLock())
            Next
        EndIf
    EndIf

    FWRestRows(aSaveLines)

Return lGrava


//--------------------------------------------------------------------
/*/ {Protheus.doc} SetGrvGrupoFamiliar
Define que irá gerar o grupo familiar automaticamente sem passar pela
analise

@author Vinicius Queiros Teixeira
@since 11/08/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Method SetGrvGrupoFamiliar() Class PLIncBenEvent

    Self:lGeraGrupoFamiliar := .T.

Return


//--------------------------------------------------------------------
/*/ {Protheus.doc} ReplicBancoConhecimento
Replica os anexos do banco de conhecimento do protocolo para os cadastro
dos beneficiários no grupo/familiar

@author Vinicius Queiros Teixeira
@since 16/08/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Method ReplicBancoConhecimento(oModel, aBeneficiarios) Class PLIncBenEvent

    Local lRetorno := .F.
    Local nX := 0
    Local aAreaBA1 := BA1->(GetArea())
    Local cCodSeqProtocolo := oModel:GetValue("MASTERBBA", "BBA_CODSEQ")

    Default aBeneficiarios := {}

    If len(aBeneficiarios) > 0
		BA1->(DbSetOrder(2))

        For nX := 1 To Len(aBeneficiarios)

            If BA1->(MsSeek(xFilial("BA1")+aBeneficiarios[nX]))
                PLSREPDOC("BBA", cCodSeqProtocolo, "BA1", BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPUSU+BA1_TIPREG+BA1_DIGITO), Nil, .T., .F.)
            EndIf

        Next nX 
    EndIf

    RestArea(aAreaBA1)

Return lRetorno

//--------------------------------------------------------------------
/*/ {Protheus.doc} getBenefFields
Retorna os dados (campos) dos beneficiários incluidos no Grupo Familiar

@author Vinicius Queiros Teixeira
@since 01/02/2023
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLGetBenFields(aBeneficiaries)

    Local oBeneficiaries := JsonObject():new()
    Local nX := 0
    Local nY := 0
    Local aAreaBA1 := BA1->(GetArea())

    Default aBeneficiaries := {}

    oBeneficiaries["found"] := .F.
    oBeneficiaries["beneficiaries"] := {}
    
    If len(aBeneficiaries) > 0
        BA1->(DbSetOrder(2))
        For nX := 1 To len(aBeneficiaries)       
            If BA1->(MsSeek(FWxFilial("BA1")+aBeneficiaries[nX]))
                aAdd(oBeneficiaries["beneficiaries"], JsonObject():new())
                nY := len(oBeneficiaries["beneficiaries"])

                oBeneficiaries["beneficiaries"][nY]["subscriberId"] := alltrim(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))
                oBeneficiaries["beneficiaries"][nY]["name"] := alltrim(BA1->BA1_NOMUSR)
                oBeneficiaries["beneficiaries"][nY]["birthDate"] := BA1->BA1_DATNAS
                oBeneficiaries["beneficiaries"][nY]["cpf"] := alltrim(BA1->BA1_CPFUSR)

                oBeneficiaries["found"] := .T.
            EndIf
        Next nX
    EndIf

    RestArea(aAreaBA1)

Return oBeneficiaries

//--------------------------------------------------------------------
/*/ {Protheus.doc} VerInfoSIB
Retorna do SubContrato a informação do campo BQC_INFANS

@author Guilherme Carreiro da Silva
@since 01/02/2023
@version Protheus 12
/*/
//--------------------------------------------------------------------
Method VerInfoSIB(oModelBBA) Class PLIncBenEvent

    Local cCodigo := oModelBBA:GetValue("BBA_CODINT") + oModelBBA:GetValue("BBA_CODEMP")
    Local cNumCont := oModelBBA:GetValue("BBA_CONEMP")
    Local cNumSub := oModelBBA:GetValue("BBA_SUBCON")
    Local cVerCon := oModelBBA:GetValue("BBA_VERCON")
    Local cVerSub := oModelBBA:GetValue("BBA_VERSUB")
    Local lInfANS := .T.

    if !empty(cNumCont) .And. !empty(cNumSub)
        
        BQC->(DbSetOrder(1))

        If BQC->(MsSeek(xFilial("BQC")+cCodigo+cNumCont+cVerCon+cNumSub+cVerSub))
            lInfANS := iif(BQC->BQC_INFANS == "1", .T., .F.)
        EndIf
            
    endif
    
Return lInfANS

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckDadosCliente
Verifica se o Cliente informado existe

@author Guilherme Carreiro da Silva
@since 01/02/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Method CheckDadosCliente(cCodCli, cLoja) Class PLIncBenEvent

    Local lOk := .T.
    
    lOk := ExistCpo("SA1", cCodCli+cLoja, 1)

Return lOk
