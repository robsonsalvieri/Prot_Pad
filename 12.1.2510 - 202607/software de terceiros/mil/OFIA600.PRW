#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA600.CH"

/*/ {Protheus.doc} OFIA600
	Contratos Scania

	@author  Luiz Pereira da Silva Junior
	@since   18/11/2025
	@version 12.1.2510
/*/

Function OFIA600()

    Local oBrowse
	
    Private aRotina := MenuDef()

    oBrowse := OA60001G_BrowseDef()
	oBrowse:Activate()

Return()


Function OA60001G_BrowseDef()

    Local oBrowse := Nil
    Local cCadastro := OemToAnsi(STR0001) //"Contratos Scania"


    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("VW4")
    oBrowse:SetDescription(cCadastro)
    oBrowse:DisableDetails()

Return(oBrowse)


/*/{Protheus.doc} MenuDef
Menu
@author Luiz Pereira da Silva Junior
@since 18/11/2025
@version 1.0

@type function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0007    ACTION 'VIEWDEF.OFIA600' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0008    ACTION 'VIEWDEF.OFIA600' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0009    ACTION 'VIEWDEF.OFIA600' OPERATION 5 ACCESS 0 // 'Alterar'
    ADD OPTION aRotina TITLE STR0002    ACTION 'OA600002N_ConsultarContratoChassi()' OPERATION 3 ACCESS 0 // 'Consultar Contrato Chassi'

Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef OFIA600
@author  Luiz Pereira da Silva Junior
@since   18/11/2025
@version 1.0
/*/

Static Function ModelDef()

	Local oStruVW4  := FWFormStruct(1, 'VW4' )
	Local oStruDesc := FWFormStruct(1, 'VW5', { |cField| (AllTrim(Upper(cField)) $ "VW5_SEQUEN/VW5_SEQVW4/VW5_IDDESC/VW5_DSID/VW5_TPDESC/VW5_DSTP/VW5_VLDESC") })
    Local oStruMail := FWFormStruct(1, 'VW5', { |cField| (AllTrim(Upper(cField)) $ "VW5_SEQUEN/VW5_SEQVW4/VW5_EMAILG") })
    Local oStruDeal := FWFormStruct(1, 'VW5', { |cField| (AllTrim(Upper(cField)) $ "VW5_SEQUEN/VW5_SEQVW4/VW5_DEALID/VW5_NMDEAL/VW5_RNMDEA") })
    Local oModel    := Nil
    
    // oModel := MPFormModel():New('OFIA600')
    oModel := MpFormModel():New("OFIA600", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oModel| OA600001N_CommitModel(oModel)}/*Commit*/, /*Cancel*/)

	oModel:SetDescription(STR0001) // 'Contratos Scania'

    oModel:AddFields('MODEL_VW4', /*cOwner*/ , oStruVW4, /* <bPre > */ , /* <bPost > */ , /* <bLoad> */)
    oModel:AddGrid('MODEL_DESC', 'MODEL_VW4', oStruDesc, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )
    oModel:AddGrid('MODEL_MAIL', 'MODEL_VW4', oStruMail, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )
    oModel:AddGrid('MODEL_DEAL', 'MODEL_VW4', oStruDeal, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* bLoad */ )

    oModel:GetModel('MODEL_VW4' ):SetDescription(STR0003)   //'Contratos Scania'
    oModel:GetModel('MODEL_DESC'):SetDescription(STR0004)   //'Desconto'
	oModel:GetModel('MODEL_MAIL'):SetDescription(STR0005)   //'E-Mail Gestores'
	oModel:GetModel('MODEL_DEAL'):SetDescription(STR0006)   //'Local Dealers'

    oModel:GetModel('MODEL_DESC'):SetOptional(.T.)
    oModel:GetModel('MODEL_MAIL'):SetOptional(.T.)
    oModel:GetModel('MODEL_DEAL'):SetOptional(.T.)

    oModel:SetRelation('MODEL_DESC', {{ 'VW5_FILIAL' , 'xFilial("VW5")' }, { 'VW5_SEQVW4', 'VW4_SEQUEN' } } , 'VW5_FILIAL+VW5_SEQVW4+VW5_SEQUEN' )
    oModel:SetRelation('MODEL_MAIL', {{ 'VW5_FILIAL' , 'xFilial("VW5")' }, { 'VW5_SEQVW4', 'VW4_SEQUEN' } } , 'VW5_FILIAL+VW5_SEQVW4+VW5_SEQUEN' )
    oModel:SetRelation('MODEL_DEAL', {{ 'VW5_FILIAL' , 'xFilial("VW5")' }, { 'VW5_SEQVW4', 'VW4_SEQUEN' } } , 'VW5_FILIAL+VW5_SEQVW4+VW5_SEQUEN' )

    //Filtros das Grids, isso DEVE sempre ser depois do SetRelation
    // //Foi implementado assim, pois a tabela foi feita para gravar as 3 informaï¿½ï¿½es.
    oModel:GetModel('MODEL_DESC'):SetLoadFilter( , "VW5_IDDESC <> '" + Space(Len(VW5->VW5_IDDESC)) + "'" )
    oModel:GetModel('MODEL_MAIL'):SetLoadFilter( , "VW5_EMAILG <> '" + Space(Len(VW5->VW5_EMAILG)) + "'" )
    oModel:GetModel('MODEL_DEAL'):SetLoadFilter( , "VW5_DEALID <> '" + Space(Len(VW5->VW5_DEALID)) + "'" )
    
    oModel:SetPrimaryKey({})

Return(oModel)


Static Function ViewDef()

	Local oView  := Nil
	Local oModel := FWLoadModel('OFIA600')

    Local oStruVW4  := FWFormStruct(2, 'VW4')
	Local oStruDesc := FWFormStruct(2, 'VW5', { |cField| (AllTrim(Upper(cField)) $ "VW5_IDDESC/VW5_DSID/VW5_TPDESC/VW5_DSTP/VW5_VLDESC") })
    Local oStruMail := FWFormStruct(2, 'VW5', { |cField| (AllTrim(Upper(cField)) $ "VW5_EMAILG") })
    Local oStruDeal := FWFormStruct(2, 'VW5', { |cField| (AllTrim(Upper(cField)) $ "VW5_DEALID/VW5_NMDEAL/VW5_RNMDEA") })

    oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VW4' , oStruVW4,  'MODEL_VW4' )
	oView:AddGrid( 'VIEW_DESC', oStruDesc, 'MODEL_DESC' )
	oView:AddGrid( 'VIEW_MAIL', oStruMail, 'MODEL_MAIL' )
	oView:AddGrid( 'VIEW_DEAL', oStruDeal, 'MODEL_DEAL' )

    oView:CreateFolder('TELA_FOLDER_PRINCIPAL')
	oView:AddSheet('TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL', 'Contrato') // 'Contrato'
	
    oView:CreateHorizontalBox( 'TELA_VW4'    , 60 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')
	oView:CreateHorizontalBox( 'TELA_FOLDER' , 40 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')

    oView:CreateFolder( 'TELA_FOLDER_ITENS', 'TELA_FOLDER')
	oView:AddSheet('TELA_FOLDER_ITENS','ABA_DESCONTO', STR0004) //'Descontos'
	oView:AddSheet('TELA_FOLDER_ITENS','ABA_EMAIL'   , STR0005) //'E-mails Gestores'
    oView:AddSheet('TELA_FOLDER_ITENS','ABA_DEALERS' , STR0006) //'Local Dealers'

    oView:CreateHorizontalBox( 'TELA_DESCONTO', 100, , .F. , 'TELA_FOLDER_ITENS', 'ABA_DESCONTO')
    oView:CreateHorizontalBox( 'TELA_EMAIL'   , 100, , .F. , 'TELA_FOLDER_ITENS', 'ABA_EMAIL')
    oView:CreateHorizontalBox( 'TELA_DEALERS' , 100, , .F. , 'TELA_FOLDER_ITENS', 'ABA_DEALERS')

    oView:SetOwnerView( 'VIEW_VW4',  'TELA_VW4' )
    oView:SetOwnerView( 'VIEW_DESC', 'TELA_DESCONTO' )
    oView:SetOwnerView( 'VIEW_MAIL', 'TELA_EMAIL' )
    oView:SetOwnerView( 'VIEW_DEAL', 'TELA_DEALERS')

    oView:SetNoInsertLine('VIEW_DESC')
    oView:SetNoInsertLine('VIEW_MAIL')
    oView:SetNoInsertLine('VIEW_DEAL')

	oView:SetNoDeleteLine('VIEW_DESC')
    oView:SetNoDeleteLine('VIEW_MAIL')
    oView:SetNoDeleteLine('VIEW_DEAL')

Return(oView)

/*/{Protheus.doc} OA600001N_CommitModel
@description Evento de commit do modelo OFIA600, criado para corrigir inconsistï¿½ncias
             de gravaï¿½ï¿½o nos campos-chave da tabela VW5. Durante o processo padrï¿½o
             de gravaï¿½ï¿½o, o campo VW5_SEQUEN nï¿½o recebia valores ï¿½nicos para cada linha
             das trï¿½s grids (Descontos, E-mails e Dealers), resultando em duplicidades.
             Esta funï¿½ï¿½o executa a numeraï¿½ï¿½o manual atravï¿½s de GetSx8Num(), garantindo
             a geraï¿½ï¿½o de chaves ï¿½nicas e o vï¿½nculo correto entre VW4 (pai) e VW5 (filhas).
             O problema ocorre devido ao uso da mesma tabela VW5 para mï¿½ltiplos submodelos
             dentro da mesma estrutura MVC.

@author      Lucas Brustolin
@since       05/12/2025
@version     1.0
@type        Static Function
@param       oModel  | Objeto MpFormModel em execuï¿½ï¿½o.
@return      Logical | Verdadeiro (.T.) se o commit foi executado corretamente.
@obs         Implementaï¿½ï¿½o necessï¿½ria para assegurar unicidade de VW5_SEQUEN e integridade
             relacional entre VW4 e VW5 nos submodelos do contrato Scania.
/*/

Static Function OA600001N_CommitModel(oModel)

    Local lRetorno      := .F.
    Local nLinha        := 1
    Local oFieldMaster  := oModel:GetModel("MODEL_VW4")
    Local oGridDesc     := oModel:GetModel("MODEL_DESC")
    Local oGridDeal     := oModel:GetModel("MODEL_DEAL")
    Local oGridMail     := oModel:GetModel("MODEL_MAIL")
    Local nOperacao     := oModel:GetOperation()
    Local cSeqVW4       := ""

    If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE

        cSeqVW4     := oFieldMaster:getvalue("VW4_SEQUEN")        
     
        
        If !oGridDesc:IsEmpty()
            For nLinha:=1 To oGridDesc:Length()
                oGridDesc:GoLine(nLinha)
                oGridDesc:SetValue("VW5_SEQUEN", GetSx8Num("VW5","VW5_SEQUEN") )
                oGridDesc:SetValue("VW5_SEQVW4", cSeqVW4 )

                ConfirmSx8()
            Next nLinha
        EndIf


        If !oGridMail:IsEmpty()
            For nLinha:=1 To oGridMail:Length()
                oGridMail:GoLine(nLinha)
                oGridMail:SetValue("VW5_SEQUEN", GetSx8Num("VW5","VW5_SEQUEN") )
                oGridMail:SetValue("VW5_SEQVW4", cSeqVW4 )
                ConfirmSx8()
            Next nLinha
        EndIf

        If !oGridDeal:IsEmpty()
            For nLinha:=1 To oGridDeal:Length()
                oGridDeal:GoLine(nLinha)
                oGridDeal:SetValue("VW5_SEQUEN", GetSx8Num("VW5","VW5_SEQUEN") )
                oGridDeal:SetValue("VW5_SEQVW4", cSeqVW4 )
                ConfirmSx8()
            Next nLinha
        EndIf

    EndIf

    lRetorno := FwFormCommit(oModel)

Return lRetorno


/*/{Protheus.doc} OA600002N_ConsultarContratoChassi
@description Executa consulta manual de contrato via API Scania (História 6).
             Caso o contrato seja encontrado > inclui/atualiza via OFIA547(.T.)
             Caso não exista contrato > mensagem e não altera banco.
             Caso erro API > mensagem e não altera banco.
             Ao incluir/atualizar > abre tela OFIA600 automaticamente em modo VIEW.

@author      Lucas Brustolin
@since       2025
@version     12.1.2510
/*/
Function OA600002N_ConsultarContratoChassi()

    Local aArea     := GetArea()
    Local cChassi   := ""
    Local oRetApi   := Nil
    Local cTitulo   := ""
    Local cPrograma := ""
    Local nOperation:= 0    
    Local nTamChassiReduzido := SuperGetMV("OFIA600A",, 7) // Tamanhho Chassi Reduzido

    // -------------------------------------------
    // 1. Solicita chassi ao usuário
    // -------------------------------------------
    cChassi := FWInputBox(STR0010, "") // "Informe o número do chassi (reduzido):"

    If Empty(AllTrim(cChassi))
        RestArea(aArea)
        Return
    Else 
        cChassi := AllTrim(Upper(cChassi)) 
        cChassi := SubStr(cChassi,1,nTamChassiReduzido) // Ajusta tamanho conforme campo
    EndIf

    // -------------------------------------------
    // 2. Validação básica do chassi
    // -------------------------------------------
    If ( !IsDigit(cChassi) .Or.  Len(AllTrim(cChassi)) <> nTamChassiReduzido )
        FWAlertError(STR0011, STR0012) // "Formato de chassi inválido. Verifique e tente novamente." # "Consultar Contrato"
        RestArea(aArea)
        Return
    EndIf

    // -------------------------------------------
    // 3. Consulta via API sem gravação inicial
    //    (História 6: só grava se houver contrato válido)
    // -------------------------------------------
    //oRetApi := OFIA547(cChassi, .F.)

    MsgRun(STR0013,STR0014,{||(oRetApi := OFIA547(cChassi, .F.),ProcessMessage())}) //"Buscando Contrato"###"Aguarde..."


    If ValType(oRetApi) <> "J"
        FWAlertError(STR0015, STR0012) // "Erro inesperado ao consultar API. Tente novamente." ### "Consultar Contrato"
        RestArea(aArea)
        Return
    EndIf

    // -------------------------------------------
    // 4. Interpretação do retorno
    // -------------------------------------------
    Do Case

        // Erro de autenticação API
        Case oRetApi["status_code_res"] == "401"
            FWAlertError(STR0017, STR0012) // "Falha de autenticação. Verifique parâmetros ARMS." ### "Consultar Contrato"
            RestArea(aArea)
            Return

        // Contrato não encontrado
        Case oRetApi["status_code_res"] == "200" .And. Len(oRetApi) == 0
            FWAlertWarning(STR0018, STR0012) // "Nenhum contrato encontrado para o chassi informado." "Consultar Contrato"
            RestArea(aArea)
            Return

        // Erro da API
        Case oRetApi["status_code_res"] >= "400" .And. oRetApi["status_code_res"] <= "599"
            FWAlertError(STR0019 + oRetApi["status_code_res"], STR0012) // "Erro na API ARMS. Código HTTP: " ### "Consultar Contrato"
            RestArea(aArea)
            Return

        // Sucesso (possível contrato)
        Otherwise

            If Len(oRetApi) == 0
                FWAlertWarning(STR0020, STR0012) // "Nenhum contrato encontrado para o chassi informado." # "Consultar Contrato"
                RestArea(aArea)
                Return
            EndIf

            // Verifica se o contrato retornado é válido
            If !( Upper(AllTrim(oRetApi[1]["status"])) == "ATIVO" .And. ;
                  !Empty(oRetApi[1]["tipoContrato"]) .And. ;
                  !Empty(AllTrim(oRetApi[1]["contrato"])) )

                FWAlertWarning(STR0021, STR0012) //"Veículo sem contrato ativo na API." ### "Consultar Contrato"
                RestArea(aArea)
                Return
            EndIf

    EndCase

    // -------------------------------------------
    // 5. Agora sim > contrato válido > manda gravar
    // -------------------------------------------
    MsgRun(STR0022,STR0023,{||(oRetApi := OFIA547(cChassi, .T.),ProcessMessage())}) //""Gravando contrato..."..."###"Aguarde..."

    If ValType(oRetApi) <> "J"
        FWAlertError(STR0024, STR0012)// "Falha ao atualizar base local." ### "Consultar Contrato"
        RestArea(aArea)
        Return
    EndIf

    If oRetApi["status"] <> "sucesso"
        FWAlertError(STR0025 + oRetApi["message"], STR0012) // "Erro ao gravar contrato: " # "Consultar Contrato"
        RestArea(aArea)
        Return
    EndIf

    // -------------------------------------------
    // 6. Após inclusão/atualização — abrir OFIA600 na VIEW
    // -------------------------------------------

    // Localiza novamente o contrato com base no chassi
    cChassi := PadR(cChassi, TamSx3("VW4_CHASSI")[1])

    DbSelectArea("VW4")
    VW4->(DbSetOrder(3)) // FILIAL+CHASSI+NUMCTR

    If !VW4->(DbSeek( xFilial("VW4") + cChassi))
        FWAlertError(STR0026, STR0012) // "Contrato gravado, porém não localizado para exibição." # "Consultar Contrato"
        RestArea(aArea)
        Return
    EndIf

    cTitulo         := STR0027 + AllTrim(cChassi) // "Contrato Scania - Chassi "
    cPrograma       := "OFIA600"
    nOperation      := MODEL_OPERATION_VIEW
    nPercReducao    := 30
    
    nRet	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } /*bCloseOnOk*/,/*bOk*/ , nPercReducao, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )

    FWAlertSucess(STR0028, STR0012) // "Contrato atualizado a partir da API com sucesso!" # "Consulta Contrato"

    RestArea(aArea)
Return
