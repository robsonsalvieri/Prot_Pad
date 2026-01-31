#INCLUDE "TOTVS.CH"
#include "GRRXDefs.ch"
#INCLUDE "GRRWIZARD.CH"

#DEFINE SERVICE_NAME    "recorrencia"

// Posições do Array aWizParam
#Define CLIENT          1
#Define PROVIDER        2
#Define BANK            3
#Define BILLING         4

#Define SIZE_ENTITY     11

// posições do array de entidades 
#Define ENT_BRANCH      1 // filial (Ex: A1_FILIAL)
#Define ENT_CODE        2 // código de busca (Ex: A1_COD)
#Define ENT_STORE       3 // código adicional de busca (Ex: A1_LOJA)
#Define ENT_DESC        4 // descrição do registro (Ex: A1_NOME)
#Define ENT_AUX_DESC    5 // descrição auxiliar 
#Define ENT_PARAMETER   6 // nome do parâmetro
#Define ENT_ALIAS       7 // tabela da entidade
#Define ENT_IDENT       8 // identificador
#Define ENT_CONTENT     9 // conteúdo do parâmetro
#Define ENT_MODEL       10 // vetor com o registro modelo
#Define ENT_WHERE       11 // vetor com as condições de pesquisa

Static _lValidDic 
Static _oCompanies := JsonObject():New()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidDic
Valida se o dicionario de dados está atualizado.

@return Logico, Verdadeiro se o dicionario está atualizado.
@author  Marcia Junko
@since   16/02/2022
/*/
//-------------------------------------------------------------------------------------
Static Function ValidDic()
    If _lValidDic == NIL
        _lValidDic := AliasInDic( "HRH" ) .and. AliasInDic( "HRI" )
    EndIf
Return _lValidDic

//-------------------------------------------------------------------------------
/*/{Protheus.doc} IsGRRUpdated
Função que valida se a estrutura do GRR está disponível

@return lógico, Retorna se o ambiente está atualizado com as tabelas do GRR
@author Marcia Junko
@since  14/06/2022
/*/
//-------------------------------------------------------------------------------
Function IsGRRUpdated()
Return ValidDic() 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRWizard
Função de criação do Wizard do GRR

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Main Function GRRWizard()
    MsApp():New( 'SIGAFAT' )
    oApp:cInternet  := Nil
    __cInterNet := NIL
    oApp:bMainInit  := { || ( oApp:lFlat := .F. , SelGRREnvironment(), Final( STR0001 , "" )  ) }  //"Encerramento Normal"
    oApp:CreateEnv()
    OpenSM0()   

    PtSetTheme( "TEMAP10" )
    SetFunName( "UPDDISTR" )
    oApp:lMessageBar := .T.

    oApp:Activate() 
Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SelGRREnvironment
Mostra ao usuário uma tela para selecionar em qual "ambiente" do GRR a configuração 
será feita.

@author  Marcia Junko
@since   08/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SelGRREnvironment( )
    Local aList := { STR0002, STR0003 }  //'Sandbox'###'Produção'
    Local cEnvironment := ''
    Local lOk := .F.
    Local oDlg
    Local oTop
    Local oSay
    Local oFont3
    Local oCombo

    cEnvironment := LoadGRRMode( aList )

    oFont3 := TFont():New( "Arial",, -15,, .F.,,,,,, .F., .F. )	

    Define MsDialog oDlg Title STR0005 From 00,00 TO 200,560 Pixel  //"Configuração - Gestão de Receitas"

        @00, 00 MsPanel oTop Size 170, 80 
        oTop:Align := CONTROL_ALIGN_ALLCLIENT

        oSay := TSay():New( 10, 10, {|| STR0004 }, oTop, , oFont3, , , , .T., , , 260, 60, , , , , , .T. )  //'Com apenas alguns cliques, criaremos a configuração mínima necessária para uso do produto de Gestão de Receitas da TOTVS, mas antes de começarmos, nos informe em qual ambiente deseja realizar a configuração.'
        oSay:SetTextAlign( 3, 0 )

        @ 45, 90 COMBOBOX oCombo VAR cEnvironment ITEMS aList SIZE 100, 27 OF oTop FONT oFont3 PIXEL

    Activate MsDialog oDlg Centered ON INIT EnchoiceBar( oDlg, { || lOk := .T., oDlg:End() }, { || oDlg:End() }, .F., {},,,.F.,.F.,.F.,.T., .F. ) // #"Favor selecionar ao menos uma empresa para continuar." #"Atenção"

    If lOk
        MakeWizard( cEnvironment )
    EndIf
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeWizard
Função de criação do Wizard do GRR

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MakeWizard( cEnvironment )
    Local oComponent
    Local aPrvCompanies := {}
    Local aPartCompanies := {}
    Local aWelcome := {}
    Local aPartners := {}
    Local cText := STR0006  //"Assistente de configuração do produto Gestão de Receitas"
    Local nHeight := 600
    Local lSandbox := .F.
    Local lResize := .F.
    
    Default cEnvironment := ''

    BEGIN TRANSACTION
        lSandbox := ( cEnvironment == 'Sandbox' )       // Não traduzir

        aWelcome := { cText + Iif( lSandbox, ' - ' + STR0051, '' ) }    //'Modo Sandbox'
        aPartners := SetPartnersList()

        If len( aPartners ) > 1
            lResize := .T.
        EndIf

        aPrvCompanies := LoadPrvCompanies( lSandbox )

        oComponent := GRRWizModel():New( )
        If !Empty( aPrvCompanies )
            aPartCompanies := PartPrvCompanies( aPrvCompanies )

            oComponent:SetPrvCompany( aPartCompanies[ 1 ] )
            oComponent:SetPrvBranches( aPartCompanies[ 2 ] )
        EndIf
        oComponent:SetWelcome( aWelcome )
        oComponent:SetWizByCompany( .T. )
        oComponent:SetCustomTab( { |x| CustomWiz( oWizard, oComponent ) } )
        oComponent:SetUseCarol( .F. )
        oComponent:SetVldDic( { |x| ValidDic() .and. WalletDic() } )
        oComponent:SetVldRpo( { |x| .T. /*WalletRpo()*/ } )
        oComponent:SetUniqueFinish( { |x| SaveUniqueConfig( oComponent ) } )
        oComponent:SetFinish( { |x| SaveConfig( oComponent ) } )
        oComponent:SetFinishText( STR0053 )    //"Ativando a integração"
        oComponent:SetSandbox( lSandbox )
        If lResize
            oComponent:SetHeight( nHeight )
        EndIf
        
        If lSandbox
            oComponent:SetStepColor( '#FCC085' )
        EndIf
        oComponent:CreateWizard( oApp )
        
        oComponent:Destroy()
    END TRANSACTION
    
    FreeObj( oComponent )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CustomWiz
Função que prepara as informações necessárias para a sincronização de parâmetros 
com a plataforma.

@param oWizard, object, componente principal do Wizard
@param oSelf, object, objeto do GRRWizard.

@author  Marcia Junko
@since   16/02/2022
/*/
//-------------------------------------------------------------------------------------
Static Function CustomWiz( oWizard, oSelf )
    Local oNewPag
    Local aPlatform := {}
    Local aBranches := {}
    Local aData := {}
    Local cVldPath := '/organizations'

    //----------------------------------------
    // Seleciona as filiais para integração 
    //----------------------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetConstruction( {|Panel| aBranches := SelBranches( Panel, oSelf ) })
    oNewPag:SetStepDescription( STR0007 )   //"Filiais da integração"
    oNewPag:SetNextAction( {|| VldSelBranches( aBranches, @oSelf:aRetValues ) } )

    //----------------------------------------
    // Dados de Plataforma 
    //----------------------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetConstruction( {|Panel| aPlatform := GRRScrPlatform( Panel, GRRService(), GRRURL(), cVldPath )  })
    oNewPag:SetStepDescription( STR0009 )   //"Dados da plataforma"
    oNewPag:SetPrevAction({|| .T. })   						  
    oNewPag:SetNextAction( {|| Iif( !GRRADVPRExec(), GRRWVlPlatform( @aPlatform, @oSelf:aRetValues ), ( Aadd( oSelf:aRetValues, { 'Auth', { "", "" } } ), .T. )) } )

    //----------------------------------------
    // Dados de movimentação 
    //----------------------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetConstruction( {|Panel| aData := SetData( Panel, oSelf ) })
    oNewPag:SetStepDescription( STR0008 )   //"Dados de movimentação"
    oNewPag:SetNextAction( {|| VldIntegrationData( aData, @oSelf:aRetValues ) } )
 Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SelBranches
Função de montagem dos componentes da aba - Filiais da integração

@param oPanel, object, Painel onde os componentes serão criado
@param oSelf, object, objeto do GRRWizard.

@return array, Vetor com os itens selecionados
@author  Marcia Junko
@since   25/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SelBranches( oPanel, oSelf )
    Local aSelBranches := {}
    Local aBranches := {}
    Local aPrvBranches := {}

    aBranches := BranchForSel( oSelf:aCompany )

    If !Empty( oSelf:aPreviusBranches )
        aPrvBranches := PrevSelBranches( oSelf:aPreviusBranches )

        RmvPrevBranches( @aBranches, aPrvBranches )

        aSort( aPrvBranches, , , {|x, y| AllTrim( Upper( x ) ) < AllTrim( Upper( y ) ) } )
    EndIf

    aSort( aBranches, , , {|x, y| AllTrim( Upper( x ) ) < AllTrim( Upper( y ) ) } )

    aSelBranches := GRRListScreen( oPanel, aBranches, aPrvBranches )
Return aSelBranches


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BranchForSel
Função que monta a lista de filiais das empresas selecionadas.

@param aCompany, array, vetor com a lista de empresas para executar a instalação

@return array, Lista de filiais das empresas selecionadas no formato Grupo de Empresa - 
    Código da Filial - Descrição da Filial
@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function BranchForSel( aCompany )
    Local aBranches := {}
    Local aSM0 := {}
    Local nX := 0
    Local nCompany := 0

    aSM0 := FWLoadSM0()    

    For nX := 1 to len( aSM0 )
        nCompany := Ascan( aCompany, { |x| x[ 2 ] == aSM0[ nX ][ SM0_GRPEMP ] } )  
        
        If aCompany[ nCompany ][ 1 ]
            aAdd( aBranches, alltrim( aSM0[ nX ][ SM0_GRPEMP ] ) + ' - ' + Alltrim( aSM0[ nX ][ SM0_CODFIL ] ) + ' - ' + Alltrim( aSM0[ nX ][ SM0_NOMRED ] ) )
        EndIf
    Next
Return aBranches

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrevSelBranches
Função que monta a lista de filiais das empresas selecionadas.

@param aPrvBranches, array, lista de filiais configuradas em execuções anteriores

@return array, Lista de filiais das empresas selecionadas no formato Grupo de Empresa - 
    Código da Filial - Descrição da Filial
@author  Marcia Junko
@since  23/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function PrevSelBranches( aPrvBranches )
    Local aBranches := {}
    Local aInfo := {}
    Local nX := 0
    Local cContent := ''
    Local cCompany := ''
    Local cBranch := ''

    For nX := 1 to len( aPrvBranches )
        cContent := aPrvBranches[ nX ][ 1 ]

        aInfo := StrtokArr( cContent, '-' )
        cCompany := alltrim( aInfo[ 1 ] )
        cBranch := alltrim( aInfo[ 2 ] )

        aAdd( aBranches, cCompany  + ' - ' + cBranch  + ' - ' + Alltrim( FWFilName( cCompany, cBranch ) ) )
    Next
Return aBranches

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RmvPrevBranches
Remove da lista 1 os itens existentes na lista 2

@param @aList1, array, lista de onde os itens devem ser retirados.
@param aList2, array, lista com os itens que devem ser retirados.

@author  Marcia Junko
@since   04/04/2022
/*/
//-------------------------------------------------------------------------------------
Static Function RmvPrevBranches( aList1, aList2 )
    Local nX := 0
    Local nPos := 0

    For nX := 1 to len( aList2 )
        If ( nPos := Ascan( aList1, { |x| alltrim( aList2[ nX ] ) $ x } ) ) > 0
            aDel( aList1, nPos )
            aSize( aList1, len( aList1 ) - 1 )
        EndIf
    Next
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldSelBranches
Função que valida se alguma filial foi selecionada e adiciona ao vetor de controle.

@param aBranches, array, vetor com as informações das filiais selecionadas.
@param @aRetValues, array, vetor com as informações que serão gravadas pelo Wizard.

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function VldSelBranches( aBranches, aRetValues )
    Local lResult := .T.
    Local nBranches := 0

    if !Empty( aBranches )
        nBranches := GRRRetbyAttribute( aRetValues, 'Branches' )

        If nBranches > 0
            aDel( aRetValues , nBranches )
            aSize( aRetValues , Len( aRetValues ) - 1 )    
        EndIf
        Aadd( aRetValues, { 'Branches', aClone( aBranches ) } )

        // ---------------------------------------------------------------
        // Avalia se precisa trocar os dados de conexão com as tabelas
        // ---------------------------------------------------------------
        ChangeConn( aBranches[ 1 ] )
    Else
        lResult := .F.
        ApMsgAlert( STR0010 )   //"Selecione ao menos uma filial para prosseguir com a instalação." 
    EndIf
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ChangeConn( cConnInfo )
Realiza a troca da empresa\filial de conexão e troca o environment caso seja necessário.

@param cConnInfo, caracter, dados da conexão a avaliar no formato T1 - D MG 01 - Belo Horizonte

@author  Marcia Junko
@since   09/11/2022
/*/
//-------------------------------------------------------------------------------------
Static Function ChangeConn( cConnInfo )
    Local aConnInfo := {}
    Local cAuxCompany := ''
    Local cAuxBranch := ''

    aConnInfo := StrtokArr( cConnInfo, '-' )

    cAuxCompany := Subs( aConnInfo[ 1 ], 1, 2 )
    cAuxBranch := Subs( Ltrim( aConnInfo[ 2 ] ), 1, FWSizeFilial() )

    GRRChgConn( cAuxCompany, cAuxBranch )
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveUniqueConfig
Função de gravação dos dados configurados no Wizard. As funções chamados por esta rotina
serão executadas uma única vez, independente da quantidade de empresas que tenham sido 
selecionadas. Por isso, devem ser colocadas aqui, por exemplo, as funções de gravação 
dos dados de conexão à plataforma.

@param oGRRWizard, object, objeto do GRRWizard.

@author  Marcia Junko
@since   16/02/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SaveUniqueConfig( oGRRWizard )
    Local aJobs := { 'GRRJobCommand' }
    Local aCompany := {}
    Local aVariables := {}
    Local aPlatAuth := {}
    Local aBranches := {}
    Local aGroupedBranches := {}
    Local aMotBx := {}
    Local nAuth := 0
    Local nBranches := 0
    Local oStatus

    aVariables := aClone( oGRRWizard:aRetValues )
    aCompany := aclone( oGRRWizard:aCompany )
    oStatus := oGRRWizard:oStatus

    nAuth := GRRRetbyAttribute( aVariables, 'Auth' )
    nBranches := GRRRetbyAttribute( aVariables, 'Branches' )

    aBranches := aVariables[ nBranches ][ 2 ] 
    aGroupedBranches := GRRGrpLInArray( aBranches )

    aPlatAuth := GRRPlatParam( aVariables[ nAuth ][ 2 ] )

    //-----------------------------------------------------
    // Seta as condições do motivo de baixa ( SIGAADV.MOT )
    //-----------------------------------------------------
    GRRSetMotBx( @aMotBx, "CARTEIRA", "A" )

    //-----------------------------------------------------
    // Grava as informações de conexão com a plataforma.
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0011  )  //'Salva os dados de conexão com a plataforma'
    GRRSaveAppParam( aPlatAuth )

    //-----------------------------------------------------
    // Grava o modo de uso da plataforma
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0012 + ' - ' + IIf( oGRRWizard:lIsSandbox, STR0002, STR0003 ) )  //"Salva o modo de uso da plataforma"###'Sandbox'###'Produção'
    SaveSndboxMode( oGRRWizard:lIsSandbox  )

    //-----------------------------------------------------
    // Prepara conexão com o Smartlink
    //-----------------------------------------------------
    // GRRWizStatus( @oStatus, STR0013  )  //'Prepara conexão com o Smartlink' 
    // GRRSLMakeSetup( @oStatus, SubscriptionList( ) )

    //-----------------------------------------------------
    // Grava o JOB de integração na tabela do Schedule
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0014 )  //'Salva o JOB de integração no Schedule'
    GRRSaveSchedule( aGroupedBranches, aJobs )

    //-----------------------------------------------------
    // Cria cadastros necessários para baixa Protheus.
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0015 )  //'Criando cadastros para as baixas de título'
    GRRNewMotBx( 'GRR', 'RECORRENTE', aMotBx )   
 
    //-----------------------------------------------------
    // Sincroniza dados da organization na plataforma
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0016 )  //Sincroniza dados da organization na plataforma
    GRRI010( @oStatus, aBranches, oGRRWizard:aPreviusBranches )

    //-----------------------------------------------------
    // Salva os dados de ativação da integração
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0017 )  //'Salva os dados de ativação da integração'
    SaveGRRParam( aGroupedBranches, oGRRWizard:lIsSandbox )

    FWFreeArray( aJobs )
    FWFreeArray( aVariables )
    FWFreeArray( aCompany )
    FWFreeArray( aBranches )
    FWFreeArray( aPlatAuth )
    FWFreeArray( aGroupedBranches )
    FWFreeArray( aMotBx )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveConfig
Função de gravação dos dados configurados no Wizard. As funções chamados por esta rotina
serão executadas por empresa\filial. Por isso indica-se colocar nesta rotina funções de
cadastro de parâmetros ou dados do ERP que dependam do ambiente aberto e na empresa\filial
correspondente.

@param oGRRWizard, object, objeto do GRRWizard.

@author  Marcia Junko
@since   16/02/2022
/*/
//----------------------------------------------------------;---------------------------
Static Function SaveConfig( oGRRWizard )
    Local aParams := {}
    Local aVariables := {}
    Local aCompany := {} 
    Local aBranches := {} 
    Local aGroupedBranches := {}
    Local aStampTables := {}
    Local aIntegrationData := {}
    Local nBranches := 0
    Local nIntegration := 0
    Local oStatus
    
    aVariables := aClone( oGRRWizard:aRetValues )
    aCompany := aClone( oGRRWizard:aCompany )
    oStatus := oGRRWizard:oStatus

    nBranches := GRRRetbyAttribute( aVariables, 'Branches' )
    aBranches := aVariables[ nBranches ][ 2 ] 

    aGroupedBranches := GRRGrpLInArray( aBranches )

    aStampTables := StampTable( )

    nIntegration := GRRRetbyAttribute( aVariables, 'IntegrationData' )
    aIntegrationData := aVariables[ nIntegration ][ 2 ] 

    aParams := { { "MV_GRRACTI", .T. } }

    //-----------------------------------------------------
    // Cria no ERP os registros de integração usado pelo GRR
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0018 )  //Criando dados para integração
    SaveEntity( oStatus, aIntegrationData, aGroupedBranches, oGRRWizard:lIsSandbox )

    //-----------------------------------------------------
    // Cria os parâmetros de integração com o GRR
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0019  )  //'Criando parâmetros de integração' 
    GRRSaveParam( aParams )

    //-----------------------------------------------------
    // Cria o campo S_T_A_M_P_ nas tabelas indicadas
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0020 )  //'Prepara o ambiente para sincronismo com a plataforma'
    GRRMakeStamp( aStampTables )

    //-----------------------------------------------------
    // Chama a classe FinIntegration para validar o ambiente para integração com SIGAFIN/GRRI110
    //-----------------------------------------------------
    if findClass( "totvs.protheus.backoffice.apps.grr.integration.financial.FinancialIntegration" )
        GRRWizStatus( @oStatus, STR0054 )  //'Preparando o ambiente para integração com SIGAFIN'
        GRRPreI110(@oStatus)
    endIf

    //-----------------------------------------------------
    // Sincroniza os parâmetros da SX6 com a Carol ou plataforma
    //-----------------------------------------------------
    // GRRWizStatus( @oStatus, 'Integra os parâmetros do Protheus com a Carol ou a plataforma'  )  //'Integra os parâmetros do Protheus com a Carol ou plataforma' 
    // SyncParameters( @oStatus )
            
    //-----------------------------------------------------
    // Sincroniza dados dos items ( produtos ) na plataforma
    //-----------------------------------------------------
    GRRWizStatus( @oStatus, STR0021 )  //Sincroniza dados dos items na plataforma
    GRRI020( oStatus, aBranches )

    FWFreeArray( aParams )
    FWFreeArray( aVariables )
    FWFreeArray( aCompany )
    FWFreeArray( aBranches )
    FWFreeArray( aGroupedBranches )
    FWFreeArray( aStampTables )
    FWFreeArray( oStatus )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRService
Função que retorna o nome do serviço do GRR.

@return caracter, nome do serviço atribuído ao endpoint
@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRService()
Return SERVICE_NAME 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveSndboxMode
Função que grava a configuração do modo de uso da plataforma GRR na tabela SYS_APP_PARAM

@param lIsSandbox, boolean, Se .T. indica que a configuração do GRR usa o modo Sandbox, 
            se .F., utiliza o modo de produção.

@author  Marcia Junko
@since   18/08/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SaveSndboxMode( lIsSandbox ) 
    Local aParams := {}

    Default lIsSandbox := .F.

    //-------------------------------------------------------
    // Grava o tipo de configuração que está ativa para o GRR
    //      grr_sndbox = true - utilizando modo Sandbox
    //      grr_sndbox = false - utilizando modo produção
    //-------------------------------------------------------
    aAdd( aParams, { "grr_sndbox", IIf( lIsSandbox, "true", "false" ) } )
    
    GRRSaveAppParam( aParams )

    FWFreeArray( aParams )
Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveGRRParam
Função que grava as configurações na tabela SYS_APP_PARAM

@param aGroupedBranches, array, vetor com as empresas\filiais que foram selecionadas 
            no Wizard.
@param lIsSandbox, boolean, Se .T. indica que a configuração do GRR usa o modo Sandbox, 
            se .F., utiliza o modo de produção.
@param lAutomato, boolean, Indica que vai tratar pelo ADVPR.

@author  Marcia Junko
@since   01/04/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SaveGRRParam( aGroupedBranches, lIsSandbox, lAutomato ) 
    Local aParams := {}
    Local aResult := {}
    Local aReference := {}
    Local nI := 0
    Local nJ := 0
    Local nPos := 0
    Local cKey := ''
    Local cEndpoint := GRRURL()
    Local cPath := '/organizations'
    Local cProperty := 'activated'

    Default lIsSandbox := .F.
    Default lAutomato := .F.

    if lIsSandbox
        cProperty := 'sndbox_' + cProperty
    EndIf

    If lAutomato .Or. ( FWIsIncallStack( "GRRWizard" ) .And. !GRRADVPRExec() )
        aResult := GRRAllResponse( cEndpoint, cPath )
        For nI := 1 to len( aResult )
            //-------------------------------------------------------
            // Tratar somente organizations enviados pelo Protheus e 
            // que não sejam níveis de hierarquia
            //-------------------------------------------------------
            If !Empty( aResult[ nI ][ 'reference' ] ) 
                aReference := StrTokArr2( aResult[ nI ][ 'reference' ], '|', .T. )
                
                If ( nPos := Ascan( aGroupedBranches, {|x| Alltrim( x[1] ) == alltrim( aReference[ 1 ] ) } ) ) > 0
                    If Ascan( aGroupedBranches[nPos][2], {|x| Alltrim(x) == Alltrim( aReference[ 2 ] ) } ) > 0
                        cKey := Strtran( alltrim(aResult[nI][ 'reference' ] ), " ", "_" ) 
                        aAdd( aParams, { 'grr_' + cProperty + cKey, IIf( aResult[ nI ][ 'isActive' ], "true", "false" ) } )
                    EndIf
                EndIf
            EndIf
        Next    
    Else
        For nI := 1 to len( aGroupedBranches )
            For nJ := 1 to len( aGroupedBranches[ nI ][ 2 ] )
                cKey := aGroupedBranches[ nI ][1] + '|' + aGroupedBranches[ nI ][ 2 ][ nJ ]
                cKey := Strtran( cKey, " ", "_" )

                aAdd( aParams, { 'grr_' + cProperty + cKey, "true" } )
            Next
        Next
    EndIf

    //-------------------------------------------------------
    // Se precisar criar mais configurações, adicioná-las no array aParams
    //-------------------------------------------------------
    GRRSaveParam( aParams, .F. )

    FWFreeArray( aParams )
    FWFreeArray( aResult )
    FWFreeArray( aReference )
Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadPrvCompanies
Função que carrega as empresas\filiais selecionadas em execuções anteriores. 

@param lIsSandbox, boolean, indica que deve tratar apenas as informações do Sandbox.

@return, array, vetor com as empresas\filiais que foram selecionadas em execuções 
anteriores. 
    O resultado seria:
    TI
        { T1 - D MG 01, D MG 01 } 
        { T1 - D SP 02, D SP 02 }
        { T1 - M SP 01, M SP 01 }
    T2
        { T2 - D RJ 01, D RJ 01 }
        { T2 - D SC 01, D SC 01 }
@author  Marcia Junko
@since   04/04/2022
/*/
//-------------------------------------------------------------------------------------
Static Function LoadPrvCompanies( lIsSandbox )
    Local oConfig
    Local aParams := {}
    Local aName := {}
    Local aCompanies := {}
    Local nI := 0
    Local nPos := 0
    Local cParamName := ''
    Local cProperty := 'activated'

    Default lIsSandbox := .F.

    if lIsSandbox
        cProperty := 'sndbox_' + cProperty
    EndIf

    If ( aCompanies := _oCompanies[ cProperty ] ) == NIL
        aCompanies := {} 
        aParams := GRRLoadAppParams(  )
        aParams := GRRFilterArray( aParams, {|x| cProperty $ x } )

        oConfig := GRRTFCfg()
        For nI := 1 to len( aParams )
            If oConfig[ aParams[ nI ] ] == 'true'
                cParamName := aParams[ nI ]
                cParamName := StrTran( cParamName, 'grr_' + cProperty, '' )
                cParamName := StrTran( cParamName, '_', ' ' )

                aName := STRTOKARR( cParamName, '|' )

                IF ( nPos := Ascan( aCompanies, {|x| x[ 1 ] == aName[ 1 ] } ) ) > 0
                    Aadd( aCompanies[ nPos ][ 2 ], { aName[ 1 ] + ' - ' + aName[ 2 ], aName[ 2 ] } )
                else
                    Aadd( aCompanies, { aName[ 1 ], { { aName[ 1 ] + ' - ' + aName[ 2 ], aName[ 2 ] } } } )
                EndIf
            EndIf
        Next

        _oCompanies[ cProperty ] := aClone( aCompanies )
    EndIf

    FwFreeArray( aName )
    FwFreeArray( aParams )
    FreeObj( oConfig )
Return aCompanies


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PartPrvCompanies
Função que agrupa as filiais por empresa

@param aData, array, vetor com as informações a separar

@return, array, vetor com as empresas\filiais que foram selecionadas em execuções 
anteriores. 
    O resultado seria:
    TI
        D MG 01
        D SP 02
        M SP 01
    T2
        D RJ 01
        D SC 01
@author  Marcia Junko
@since   04/04/2022
/*/
//-------------------------------------------------------------------------------------
Static Function PartPrvCompanies( aData )
    Local aCompanies := {}
    Local aBranches := {}

    aEval( aData, {|a| aAdd( aCompanies, a[1] ), aEval( a[2],  { |b| aAdd( aBranches, b ) } ) } ) 
Return { aCompanies, aBranches }


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} StampTable
Informa em quais tabelas o campo de controle S_T_A_M_P_ deve ser criado.

@return, array, vetor com o nome das tabelas que devem utilizar o campo S_T_A_M_P_ para
        permitir o controle de sincronismo dos dados entre o Prothesu e o GRR.
@author  Marcia Junko
@since   14/04/2022
/*/
//-------------------------------------------------------------------------------------
Static Function StampTable( )
    Local aTables := { 'SB1', ;  // Cadastro de produtos
                       'HRG', ;  // Produto Recorrente - GRR
                       'SE1', ;  // Títulos a receber   
                       'HRJ' }   // Integração GRR x SIGAFIN
Return aTables


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRActBranches
Função que retorna as filiais que estão ativas para o produto GRR para a empresa logada.

@param lFilter, boolean, se .T., retorna apenas os registros da empresa logada, 
        se .F., retorna todas as filiais ativas.

@return, array, vetor com as filiais habilitadas da empresa logada.
    O resultado seria:
    { "T1 - D MG 01 - Filial BELO HOR" }
    { "T1 - M PR 02 - Filial CASCAVEL" }
    { "T1 - M SP 02 - Filial CAMPINAS" }
    
@author  Marcia Junko
@since   19/04/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRActBranches( lFilter )
    Local aCompanyInfo := {}
    Local aPartCompanies := {}
    Local aBranches := {}
    Local lIsSandbox := .F.

    Default lFilter := .T.
    
    lIsSandbox := Iif( GRRSysValue( 'grr_sndbox' ) == "true", .T., .F. )

    aCompanyInfo := LoadPrvCompanies( lIsSandbox )

    If lFilter
        aCompanyInfo := GRRFilterArray( aCompanyInfo, {|x|  x[1] == cEmpAnt } )
    EndIf

    aPartCompanies := PartPrvCompanies( aCompanyInfo )
    aBranches := PrevSelBranches( aPartCompanies[ 2 ] )
Return aBranches


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SubscriptionList
Informa as subscrições disponíveis na plataforma GRR.

@OBS: Como o GRR é uma aplicação TOTVSApps não é necessário especificar as mensagens.

@return, array, vetor com a lista de subsccrições ( mensagens ) atribuídas ao GRR.
@author  Marcia Junko
@since   20/04/2022
/*/
//-------------------------------------------------------------------------------------
/*Static Function SubscriptionList( )
Return { 'PartnerLinkGrr', ;    // Partners
         "ErrorLinkGrr" }       // Error
*/

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetData
Função de montagem dos componentes da aba - Dados de integração

@param oPanel, object, Painel onde os componentes serão criado
@param oSelf, object, objeto do GRRWizard.
@param @aWizParam, array, vetor com as informarções mostradas no Wizard. 

@return array, Vetor com as informações de cada entidade
@author  Marcia Junko
@since   01/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetData( oPanel, oSelf )
    Local oClient
    Local oStore
    Local oName
    Local aWizParam := {}
    Local cPartner := ''
    Local aPartners := {}
    Local aAuxPartners := {}
    Local nTop := 0
    Local nI := 0
    Local lExistSA1 := .F.
    Local lExistSA2 := .F.
    Local lExistSA6 := .F.
    Local lFilledSA1 := .F.
    Local lFilledSA2 := .F.
    Local lFilledSA6 := .F.

    aAuxPartners := SetPartnersList()
    For nI := 1 to len( aAuxPartners )
        Aadd( aPartners, aAuxPartners[ nI] [ 1 ] )
    Next
    
    aWizParam := Array( 4 )

    cPartner := aPartners[ 1 ]
    IF !Empty( SuperGetMV( "MV_GRRCPAY", .F., '' ) )
        cPartner := StrtokArr( SuperGetMV( "MV_GRRCPAY", .F., '' ), '|' )[ 1 ]
    EndIf

    aWizParam[ CLIENT ] := LoadParamInfo( 'SA1', Alltrim( cPartner ) )
    aWizParam[ PROVIDER ] := LoadParamInfo( 'SA2', Alltrim( cPartner ) )
    aWizParam[ BANK ] := LoadParamInfo( 'SA6', Alltrim( cPartner ) )
    aWizParam[ BILLING ] := LoadParamInfo( 'FRV', Alltrim( cPartner ) )   

    lExistSA1 := CheckParam( 'SA1', aWizParam[ CLIENT ] )
    lExistSA2 := CheckParam( 'SA2', aWizParam[ PROVIDER ] )
    lExistSA6 := CheckParam( 'SA6', aWizParam[ BANK ] )

    DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD 
	DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10
    
    @ nTop + 10, 10 SAY STR0022 OF oPanel PIXEL FONT oCHFont   //"Defina os dados que serão utilizados para a integração com o Gestão de Receitas"

        If oSelf:lResized
            nTop := 15 

            lFilledSA1 := GRRChkX6Filled( aWizParam[ CLIENT ][ ENT_PARAMETER ] )
            lFilledSA2 := GRRChkX6Filled( aWizParam[ PROVIDER ][ ENT_PARAMETER ] )
            lFilledSA6 := GRRChkX6Filled( aWizParam[ BANK ][ ENT_PARAMETER ] )

            @ nTop + 10, 50 SAY STR0023 OF oPanel PIXEL FONT oCHFont   //"Selecione o parceiro comercial:"
            @ nTop + 10, 150 COMBOBOX oCombo VAR cPartner ITEMS aPartners SIZE 100, 10 OF oPanel PIXEL ;
            	ON CHANGE SetWizInfo( @aWizParam, cPartner, @lExistSA1, @lExistSA2, @lExistSA6  ) ;
	            WHEN !lFilledSA1 .And. !lFilledSA2 .And. !lFilledSA6  

            nTop += 10
        EndIf

        @ nTop + 20, 10 GROUP TO nTop + 57, 353 PROMPT STR0024 OF oPanel PIXEL    //"Dados do cliente"

            @ nTop + 30, 15 SAY STR0025 OF oPanel PIXEL FONT oCHFont   //"Código:"
            @ nTop + 40, 15 MSGET oClient VAR aWizParam[ CLIENT ][ ENT_CODE ]  SIZE 70, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA1 

            @ nTop + 30, 90 SAY STR0026 OF oPanel PIXEL FONT oCHFont   //"Loja:"
            @ nTop + 40, 90 MSGET oStore VAR aWizParam[ CLIENT ][ ENT_STORE ]  SIZE 30, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA1
            
            @ nTop + 30, 125 SAY STR0027 OF oPanel PIXEL FONT oCHFont  //"Nome:"
            @ nTop + 40, 125 MSGET oName VAR aWizParam[ CLIENT ][ ENT_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN .F. 

            @ nTop + 040, 285 BUTTON oBtnClient PROMPT STR0028 SIZE 60, 11 OF oPanel PIXEL ;
                WHEN !lExistSA1 ACTION ( DataAction( CLIENT, @aWizParam[ CLIENT ], @lExistSA1, cPartner  ) )    //"Informar dados"

        @ nTop + 62, 10 GROUP TO nTop + 99, 353 PROMPT STR0029 OF oPanel PIXEL    //'Dados do fornecedor'

            @ nTop + 72, 15 SAY STR0025 OF oPanel PIXEL FONT oCHFont   //"Código:"
            @ nTop + 82, 15 MSGET oClient VAR aWizParam[ PROVIDER ][ ENT_CODE ]  SIZE 70, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA2 

            @ nTop + 72, 90 SAY STR0026 OF oPanel PIXEL FONT oCHFont   //"Loja:"
            @ nTop + 82, 90 MSGET oStore VAR aWizParam[ PROVIDER ][ ENT_STORE ]  SIZE 30,10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA2
            
            @ nTop + 72, 125 SAY STR0027 OF oPanel PIXEL FONT oCHFont  //"Nome:"
            @ nTop + 82, 125 MSGET oName VAR aWizParam[ PROVIDER ][ ENT_DESC ]  SIZE 150,10 OF oPanel Font oCMFont PIXEL WHEN .F. 

            @ nTop + 82, 285 BUTTON oBtnProvider PROMPT STR0028 SIZE 60, 11 OF oPanel PIXEL ;
                WHEN !lExistSA2 ACTION ( DataAction( PROVIDER, @aWizParam[ PROVIDER ], @lExistSA2, cPartner  ) )    //"Informar dados"

        @ nTop + 104, 10 GROUP TO nTop + 165, 353 PROMPT STR0030 OF oPanel PIXEL  //'Dados do Banco'

            @ nTop + 114, 15 SAY STR0025 OF oPanel PIXEL FONT oCHFont  //"Código:"
            @ nTop + 124, 15 MSGET oClient VAR aWizParam[ BANK ][ ENT_CODE ]  SIZE 40, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

            @ nTop + 114, 60 SAY STR0031 OF oPanel PIXEL FONT oCHFont  //"Agência:"
            @ nTop + 124, 60 MSGET oStore VAR aWizParam[ BANK ][ ENT_STORE ]  SIZE 60, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6
            
            @ nTop + 114, 125 SAY STR0032 OF oPanel PIXEL FONT oCHFont //"Conta:"
            @ nTop + 124, 125 MSGET oName VAR aWizParam[ BANK ][ ENT_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN !lExistSA6

            @ nTop + 124, 285 BUTTON oBtnProvider PROMPT STR0028 SIZE 60, 11 OF oPanel PIXEL ;
                WHEN !lExistSA6 ACTION ( DataAction( BANK, @aWizParam[ BANK ], @lExistSA6, cPartner ) )     //"Informar dados"

            @ nTop + 139, 15 SAY STR0033 OF oPanel PIXEL FONT oCHFont  //"Nome do banco:"
            @ nTop + 149, 15 MSGET oName VAR aWizParam[ BANK ][ ENT_AUX_DESC ]  SIZE 150, 10 OF oPanel Font oCMFont PIXEL WHEN .F.

Return aWizParam


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadParamInfo
Esta função é responsável por retornar os dados padrões do parâmetro (caso não esteja 
preenchido) ou os dados existentes no banco de dados.

@param cType, caracter, Alias da tabela principal
@param cPartner, caracter, Identificação do parceiro comercial

@return, array, armezena os dados da entidade
    aReturn[1] := filial (Ex: A1_FILIAL)
    aReturn[2] := código de busca (Ex: A1_COD)
    aReturn[3] := código auxiliar de busca (Ex: A1_LOJA)
    aReturn[4] := descrição do registro (Ex: A1_NOME)
    aReturn[5] := descrição auxiliar  
    aReturn[6] := nome do parâmetro
    aReturn[7] := tabela da entidade
    aReturn[8] := identificação
    aReturn[9] := conteúdo do parâmetro
    aReturn[10] := vetor com o registro modelo

@author  Marcia Junko
@since   05/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function LoadParamInfo( cType, cPartner )
    Local aSvAlias := GetArea()
    Local aReturn := Array( SIZE_ENTITY )
    Local aPartners := {}
    Local aPartnerInfo := {}
    Local aContent := {}
    Local cContent := ''
    Local nPos := 0

    aPartners := SetPartnersList()
    If ( nPos := Ascan( aPartners, {|x| upper( Alltrim( x[ 1 ] ) ) == upper( Alltrim( cPartner ) ) } ) ) > 0
        aPartnerInfo := aPartners[ nPos ][ 2 ]
    EndIf

    aReturn[ ENT_ALIAS ] := cType

    If cType == 'SA1'
        aReturn[ ENT_CODE ] := SetDataContent( aPartnerInfo, cType, 'COD' )
        aReturn[ ENT_STORE ] := SetDataContent( aPartnerInfo, cType, 'LOJA' )
        aReturn[ ENT_DESC ] := SetDataContent( aPartnerInfo, cType, 'NOME' )
        aReturn[ ENT_AUX_DESC ] := SetDataContent( aPartnerInfo, cType, 'NREDUZ' )
        aReturn[ ENT_PARAMETER ] := 'MV_GRRCPAY'
        aReturn[ ENT_IDENT] := STR0036  //'Cliente'
    ElseIf cType == 'SA2'
        aReturn[ ENT_CODE ] := SetDataContent( aPartnerInfo, cType, 'COD' )
        aReturn[ ENT_STORE ] := SetDataContent( aPartnerInfo, cType, 'LOJA' )
        aReturn[ ENT_DESC ] := SetDataContent( aPartnerInfo, cType, 'NOME' )
        aReturn[ ENT_AUX_DESC ] := SetDataContent( aPartnerInfo, cType, 'NREDUZ' )
        aReturn[ ENT_PARAMETER ] := 'MV_GRRFPAY'
        aReturn[ ENT_IDENT ] := STR0037     //'Fornecedor'
    ElseIf cType == 'SA6'
        aReturn[ ENT_CODE ] := Padr( Upper( Alltrim( cPartner ) ), TamSX3( 'A6_COD' )[1] )
        aReturn[ ENT_STORE ] := Padr( Upper( Alltrim( cPartner ) ), TAMSX3( "A6_AGENCIA" )[1] )
        aReturn[ ENT_DESC ] := Padr( Upper( Alltrim( cPartner ) ), TAMSX3( "A6_NUMCON" )[1] )
        aReturn[ ENT_AUX_DESC ] := Padr( Upper( Alltrim( cPartner ) ) + ' - ' + STR0034, TAMSX3( "A6_NOME" )[1] )   //'CONTA TRANSITORIA'
        aReturn[ ENT_PARAMETER ] := 'MV_GRRBPAY'
        aReturn[ ENT_IDENT ] := STR0038     //'Banco'
    ElseIf cType == 'FRV'
        aReturn[ ENT_CODE ] := 'R'
        aReturn[ ENT_STORE ] := Padr( STR0035, TamSx3( "FRV_DESCRI" )[1] )  //'CARTEIRA DEVOLUÇÃO - GR'
        aReturn[ ENT_DESC ] := ''
        aReturn[ ENT_AUX_DESC ] := ''
        aReturn[ ENT_PARAMETER ] := 'MV_GRRSNCC'
        aReturn[ ENT_ALIAS ] := 'FRV'
        aReturn[ ENT_IDENT ] := STR0039     //'Situação'
    EndIf

    aReturn[ ENT_BRANCH ] := xFilial( aReturn[ ENT_ALIAS ] )
    aReturn[ ENT_CONTENT ] := ''
    aReturn[ ENT_MODEL ] := {}

    cContent := SuperGetMV( aReturn[ ENT_PARAMETER ], .T., '' )

    If !Empty( cContent )
        cAlias := aReturn[ ENT_ALIAS ]
        cSeek := StrTran( cContent, '|', '' )
        aContent := StrtokArr( cContent , '|' )
        
        aReturn[ ENT_CODE ] := aContent[1]

        If cType == 'SA6'
            cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_AGENCIA' )
            If !Empty( cAux )
                aReturn[ ENT_STORE ] := cAux
            EndIf
            
            cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_NUMCON' )
            If !Empty( cAux )
                aReturn[ ENT_DESC ] := cAux
            EndIf

            cAux := Posicione( 'SA6', 1, xFilial( 'SA6' ) + cSeek, 'A6_NOME' )
            If !Empty( cAux )
                aReturn[ ENT_AUX_DESC ] := cAux 
            EndIf
        ElseIf cType == 'FRV'
            cAux := Posicione( 'FRV', 1, xFilial('FRV') + cSeek , 'FRV_DESCRI' )
            If !Empty( cAux )
                aReturn[ ENT_STORE ] := cAux
            EndIf
        Else
            aReturn[ ENT_STORE ] := aContent[2]
            aReturn[ ENT_DESC ] := Posicione( cAlias, 1, xFilial( cAlias ) + cSeek, PrefixoCPO( cAlias ) + '_NOME' )
        EndIf

        aReturn[ ENT_CONTENT ] := cContent
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aContent )
Return aReturn


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CheckParam
Função de verifica se o registro existe no banco de dados

@param cType, caracter, Alias da tabela principal
@param aInfo, array, armezena os dados da entidade a ser pesquisada

@return boolean, indica se o registro em questão existe no banco de dados.
@author  Marcia Junko
@since   01/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function CheckParam( cType, aInfo )
    Local lExist := .F.
    Local cQuery := ''
    Local cTempAlias := ''
    Local aSvAlias := GetArea()

    IF cType == 'SA1'
        cQuery := "SELECT A1_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ; 
            " WHERE A1_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
                " AND A1_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
                " AND A1_LOJA = '" + aInfo[ ENT_STORE ] + "' " + ;
                " AND D_E_L_E_T_ = ' '"
    ElseiF cType == 'SA2'
        cQuery := "SELECT A2_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
            " WHERE A2_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
                " AND A2_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
                " AND A2_LOJA = '" + aInfo[ ENT_STORE ] + "' " + ;
                " AND D_E_L_E_T_ = ' '"
    ElseiF cType == 'SA6'
        cQuery := "SELECT A6_COD FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
            " WHERE A6_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
                " AND A6_COD = '" + aInfo[ ENT_CODE ] + "' " + ;
                " AND A6_AGENCIA = '" + aInfo[ ENT_STORE ] + "' " + ;
                " AND A6_NUMCON = '" + aInfo[ ENT_DESC ] + "' " + ;
                " AND D_E_L_E_T_ = ' '"
    // ElseiF cType == 'FRV'
    //     cQuery := "SELECT FRV_CODIGO FROM " + RetSqlName( aInfo[ ENT_ALIAS ] ) + ;
    //         " WHERE FRV_FILIAL = '" + aInfo[ ENT_BRANCH ] + "' " + ;
    //             " AND FRV_CODIGO = '" + aInfo[ ENT_CODE ] + "' " + ;
                // " AND D_E_L_E_T_ = ' '"
    EndIf

    IF !Empty( cQuery )
        cQuery := ChangeQuery( cQuery )

        cTempAlias := MPSysOpenQuery( cQuery )
        If ( cTempAlias )->( !Eof() )
            lExist := .T.
        EndIf
        ( cTempAlias )->( DbCloseArea() )
    EndIf

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )
Return lExist


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetWizInfo
Função executada ao alterar o parceiro comercial.
Esta função é responsável por atualizar as informações do array de controle do Wizard, de
acordo com o parceiro comercial selecionado.

@param aWizParam, array, vetor com as informarções mostradas no Wizard. 
@param cPartner, caracter, Identificação do parceiro comercial
@param @lExistSA1, boolean, indica se o registro existe na tabela SA1 
@param @lExistSA2, boolean, indica se o registro existe na tabela SA2 
@param @lExistSA6, boolean, indica se o registro existe na tabela SA6 

@author  Marcia Junko
@since   15/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetWizInfo( aWizParam, cPartner, lExistSA1, lExistSA2, lExistSA6 )
    aWizParam[ CLIENT ] := LoadParamInfo( 'SA1', cPartner )
    aWizParam[ PROVIDER ] := LoadParamInfo( 'SA2', cPartner )
    aWizParam[ BANK ] := LoadParamInfo( 'SA6', cPartner )
    aWizParam[ BILLING ] := LoadParamInfo( 'FRV', cPartner )   

    lExistSA1 := CheckParam( 'SA1', aWizParam[ CLIENT ] )
    lExistSA2 := CheckParam( 'SA2', aWizParam[ PROVIDER ] )
    lExistSA6 := CheckParam( 'SA6', aWizParam[ BANK ] )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetDataContent
Esta função é responsável por retornar um dado específico relacionado ao parceiro comercial.

@param aData, array, Informações do parceiro comercial
@param cAlias, caracter, nome da tabela
@param cField, caracter, identificador do campo

@return caracter, conteúdo padrão do campo
@author  Marcia Junko
@since   15/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetDataContent( aData, cAlias, cField )
    Local cResult := ''
    Local nPos := 0

    nPos := Ascan( aData, {|x| x[ 1 ] == cField } )
    cResult := Padr( aData[ nPos ][ 2 ], TamSX3( PrefixoCpo( cAlias ) + '_' + cField )[1] )
Return cResult 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} DataAction
Função executada ao clicar no botão Informar dados.
Esta função é responsável por montar a AXINCLUI para informar os dados adicionais ao 
incluir o registro na base de dados.

@param nType, number, identifica qual a entidade está sendo validada, onde:
    [1] - cliente
    [2] - fornecedor
    [3] - banco
    [4] - situação de cobrança

@param aArray, array, armezena os dados da entidade
@param lExist, boolean, variável de controle do botão. Se ocorrer a inclusão pela
        função, o botão no wizard deve ser desabilitado. (passado por referência)
@param cPartner, caracter, Identificação do parceiro comercial

@author  Marcia Junko
@since   01/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function DataAction( nType, aArray, lExist, cPartner )
    Local cTitle := ''
    Local cParameter := ''
    Local aFields := {}
    Local aContent := {}
    Local aOtherInfo := {}
    Local aDataInfo := {}
    Local aPartners := {}
    Local aPartnerInfo := {}
    Local nPos := 0

    If nType == CLIENT
        cTitle := STR0040    //"Configuração do cliente - Gestão de Receitas"
        aFields := {'A1_FILIAL', 'A1_COD', 'A1_LOJA', 'A1_NOME', 'A1_NREDUZ'}
    ElseIf nType == PROVIDER
        cTitle := STR0041    //"Configuração do fornecedor - Gestão de Receitas"
        aFields := {'A2_FILIAL', 'A2_COD', 'A2_LOJA', 'A2_NOME', 'A2_NREDUZ'}
    ElseIf nType == BANK
        Inclui := .T.
        cTitle :=  STR0042   //"Configuração do banco - Gestão de Receitas"
        aFields := {'A6_FILIAL', 'A6_COD', 'A6_AGENCIA', 'A6_NUMCON', 'A6_NOME', 'A6_NREDUZ'}
        aOtherInfo := { { 'A6_NOME', Upper( Alltrim( cPartner ) ) + ' - ' + STR0034 }, { 'A6_NREDUZ', Upper( Alltrim( cPartner ) ) } }  //'CONTA TRANSITÓRIA'
    EndIf

    aPartners := SetPartnersList()
    If ( nPos := Ascan( aPartners, {|x| upper( Alltrim( x[ 1 ] ) ) == upper( Alltrim( cPartner ) ) } ) ) > 0
        aPartnerInfo := aPartners[ nPos ][ 2 ]
    EndIf

    cParameter := aArray[ ENT_PARAMETER ]

    aDataInfo := { cTitle, aFields, aPartnerInfo, aOtherInfo }

    GRRDataAction( aDataInfo, @aArray, @lExist )

    If nType == BANK
        aArray[ ENT_PARAMETER ] := cParameter
    EndIf

    FWFreeArray( aFields )
    FWFreeArray( aContent )
    FWFreeArray( aOtherInfo )
    FWFreeArray( aDataInfo )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldIntegrationData
Função que valida se os dados de modelo para movimentação dos registros no Protheus 
foram criadas corretamente.

@param aData, array, vetor com as informarções mostradas no Wizard.
@param @aRetValues, array, vetor com as informações que serão gravadas pelo Wizard.

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   02/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function VldIntegrationData( aData, aRetValues )
    Local aWhere := {}
    Local lValid := .T.
    Local cMsg  := ''
    
    If Empty( aData[ CLIENT ][ ENT_CODE ] ) .Or. Empty( aData[ CLIENT ][ ENT_STORE ] ) .Or. Empty( aData[ CLIENT ][ ENT_DESC ] )
        lValid := .F.
        cMsg := STR0043  //"Informe os dados do cliente para a integração com o Gestão de Receitas."
    else
        lValid := CheckParam( 'SA1', aData[ CLIENT ] )

        IF !lValid
            cMsg := STR0044     //"Por favor, preencha os dados complementares para a inclusão do cliente através do botão 'Informar dados'." 
        EndIf
    Endif

    If lValid
        If Empty( aData[ PROVIDER ][ ENT_CODE ] ) .Or. Empty( aData[ PROVIDER ][ ENT_STORE ] ) .Or. Empty( aData[ PROVIDER ][ ENT_DESC ] )
            lValid := .F.
            cMsg := STR0045     //"Informe os dados do fornecedor para a integração com o Gestão de Receitas."
        else
            lValid := CheckParam( 'SA2', aData[ PROVIDER ] )

            IF !lValid
                cMsg := STR0046     //"Por favor, preencha os dados complementares para a inclusão do fornecedor através do botão 'Informar dados'." 
            EndIf
        Endif
    EndIf

    If lValid
        If Empty( aData[ BANK ][ ENT_CODE ] ) .Or. Empty( aData[ BANK ][ ENT_STORE ] ) .Or. Empty( aData[ BANK ][ ENT_DESC] )
            lValid := .F.
            cMsg := STR0047     //"Informe os dados do banco para a integração com o Gestão de Receitas."     
        else
            lValid := CheckParam( 'SA6', aData[ BANK ])

            IF !lValid
                cMsg := STR0048     //"Preencha os dados complementares para a inclusão do banco pelo botão 'Informar dados'."     
            EndIf
        Endif
    ENDIF

    If lValid .And. !Empty( aData[ BILLING ][ ENT_CODE ] )
        If GRRVldFRV( @aData[ BILLING ] )
            GRRMakeFRVRecord( aData[ BILLING ][ ENT_CODE ], aData[ BILLING ][ ENT_STORE ] )
        EndIf
    EndIf

    If !lValid
        ApMsgAlert( cMsg )
    else
        If Empty( aData[ CLIENT ][ ENT_MODEL ] )
            aWhere := { { 'A1_FILIAL', aData[ CLIENT ][ ENT_BRANCH ] }, { 'A1_COD', aData[ CLIENT ][ ENT_CODE ] }, { 'A1_LOJA', aData[ CLIENT ][ ENT_STORE ]} }
            aData[ CLIENT ][ ENT_WHERE ] := aWhere
            aData[ CLIENT ][ ENT_MODEL ] := GRRGetModel( aData[ CLIENT ][ ENT_ALIAS ], aWhere ) 
        EndIf

        If Empty( aData[ PROVIDER ][ ENT_MODEL ] )
            aWhere := { { 'A2_FILIAL', aData[ PROVIDER ][ ENT_BRANCH ] }, { 'A2_COD', aData[ PROVIDER ][ ENT_CODE ] }, { 'A2_LOJA', aData[ PROVIDER ][ ENT_STORE ]} }
            aData[ PROVIDER ][ ENT_WHERE ] := aWhere
            aData[ PROVIDER ][ ENT_MODEL ] := GRRGetModel( aData[ PROVIDER ][ ENT_ALIAS ], aWhere  ) 
        EndIf

        If Empty( aData[ BANK ][ ENT_MODEL ] )
            aWhere := { { 'A6_FILIAL', aData[ BANK ][ ENT_BRANCH ] }, { 'A6_COD', aData[ BANK ][ ENT_CODE ] }, { 'A6_AGENCIA', aData[ BANK ][ ENT_STORE ]}, {'A6_NUMCON', aData[ BANK ][ ENT_DESC ]} }
            aData[ BANK ][ ENT_WHERE ] := aWhere
            aData[ BANK ][ ENT_MODEL ] := GRRGetModel( aData[ BANK ][ ENT_ALIAS ], aWhere ) 
        EndIf

        If Empty( aData[ BILLING ][ ENT_MODEL ] )
            aWhere := { { 'FRV_FILIAL', aData[ BILLING ][ ENT_BRANCH ] }, { 'FRV_CODIGO', aData[ BILLING ][ ENT_CODE ]} }
            aData[ BILLING ][ ENT_WHERE ] := aWhere
            aData[ BILLING ][ ENT_MODEL ] := GRRGetModel( aData[ BILLING ][ ENT_ALIAS ], aWhere ) 
        EndIf

        Aadd( aRetValues, { 'IntegrationData', aClone( aData ) } )
    EndIf
Return lValid


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPartnersList
Função que alimenta os dados de cadastro dos parceiros comerciais.

OBS: Estas informações não devem ser traduzidas, pois se referem a dados de cadastro, 
como endereço e contato.

@return array, Vetor com as informações dos parceiros comerciais disponíveis para o GRR.
@author  Marcia Junko
@since   06/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SetPartnersList()
    Local aPartners := {}

    //------------------------------------------------------------------
    // Dados de contato da MaxiPago
    //------------------------------------------------------------------
    aAdd( aPartners, { 'REDE', { ;                                              //Nunca traduzir
            { 'COD', 'REDE' }, ;                                                //Nunca traduzir
            { 'LOJA', '01' }, ;
            { 'NOME', 'REDECARD INSTITUIÇÃO DE PAGAMENTO S.A.' }, ;             //Nunca traduzir
            { 'NREDUZ', 'REDECARD' }, ;                                         //Nunca traduzir
            { 'CGC', '01425787000104' }, ;
            { 'END', 'RUA TENENTE MAURO DE MIRANDA, 36' }, ;                    //Nunca traduzir
            { 'COMPLEM', 'BLOCO D - 7º ANDAR' }, ;                              //Nunca traduzir
            { 'COD_MUN', '50308' }, ;   
            { 'MUN', 'SAO PAULO' }, ;                                           //Nunca traduzir
            { 'BAIRRO', 'JABAQUARA' }, ;                                        //Nunca traduzir
            { 'EST', 'SP' }, ;
            { 'CEP', '04345030' }, ;
            { 'PAIS', '105' } } } )

    //------------------------------------------------------------------
    // Dados de contato da Adyen
    //------------------------------------------------------------------
    aAdd( aPartners, { 'ADYEN', { ;                                             //Nunca traduzir
            { 'COD', 'ADYEN' }, ;                                               //Nunca traduzir
            { 'LOJA', '01' }, ;
            { 'NOME', 'ADYEN DO BRASIL INSTITUIÇÃO DE PAGAMENTO LTDA.' }, ;     //Nunca traduzir
            { 'NREDUZ', 'ADYEN DO BRASIL' }, ;                                  //Nunca traduzir
            { 'CGC', '14796606000190' }, ;
            { 'END', 'AV. DAS NAÇÕES UNIDAS, 14261' }, ;                        //Nunca traduzir
            { 'COMPLEM', 'COND. WT MORUMBI - CONJ. 3001B - ALA B' }, ;          //Nunca traduzir
            { 'COD_MUN', '50308' }, ;   
            { 'MUN', 'SAO PAULO' }, ;                                           //Nunca traduzir
            { 'BAIRRO', 'VILA GERTRUDES' }, ;                                   //Nunca traduzir
            { 'EST', 'SP' }, ;
            { 'CEP', '04794000' }, ;
            { 'PAIS', '105' } } } )

Return aPartners


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveEntity
Função que grava as entidades relacionados aos parâmetros e dispara a gravação dos 
parâmetros por filial.

@param oStatus, object, Painel onde serão mostrados as etapas de gravação.
@param aWizParam, array, vetor com as informarções mostradas no Wizard. 
@param aSelBranches, array, vetor com a lista de filiais selecionadas no Wizard.
@param lIsSandbox, boolean, indica que está sendo usado um ambiente Sandbox.

@author  Marcia Junko
@since   06/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SaveEntity( oStatus, aWizParam, aSelBranches, lIsSandbox )
    Local aSvAlias := GetArea()
    Local aSM0 := FWLoadSM0()
    Local aSX6 := {}
    Local aModel := {}
    Local aElem := {}
    Local aWhere := {}
    Local aAux := {}
    Local aTam := {}
    Local aItemsSX6 := {}
    Local nEmp := 0
    Local nElem := 0
    Local nFields := 0
    Local nX    := 0
    Local nCompany := 0
    Local cCode     := ''
    Local cCompExec := ''
    Local cBranchExec := ''
    Local cBranchbySM0 := ''
    Local cBranchbyRecord := ''
    Local cNewBranch := ''
    Local cSeek := ''
    Local cAuxBranch := ''
    Local cParameter := ''
    Local cFindBranch := ''
    Local cFirstCompany := ''
    Local cCodeOrigin := ''
    Local lInSelBranches := .F.
    Local lContinue := .F.
    Local lOtherCompany := .F.

    Default aSelBranches := {}
    Default lIsSandbox := .F.

    cCompExec := cEmpAnt
    cBranchExec := cFilAnt

    cFirstCompany := cCompExec
    If !Empty( aSelBranches )
        lInSelBranches := .T.
        cFirstCompany := aSelBranches[1][1]
    EndIf

    For nEmp := 1 to len( aSM0 )
        If aSM0[ nEmp ][1] == cCompExec
            lOtherCompany :=  cFirstCompany != cCompExec 
            If !lInSelBranches .Or. ;
                ( lInSelBranches .And. ( ( nCompany := ( Ascan( aSelBranches, {|x| Alltrim( x[ 1 ] ) == Alltrim( aSM0[nEmp][1] ) } )) ) > 0  .And. ;
                    ( Ascan( aSelBranches[ nCompany ][2], {|x| Alltrim( x ) == Alltrim( aSM0[nEmp][2] ) } )  > 0  ) ) )  

                For nElem := 1 to len( aWizParam )
                    cNewBranch := ''
                    cLastBranch := ''
                    cSeek := ''
                    cContent := ''
                    aModel := {}
                    aTam := {}

                    aElem := aWizParam[ nElem ]
                    aModel := aElem[ ENT_MODEL ]
                    aWhere := aElem[ ENT_WHERE ]

                    cBranchbySM0 := xFilial( aWizParam[ nElem ][ ENT_ALIAS ], aSM0[ nEmp ][2] ) 
                    cBranchbyRecord := aElem[ ENT_BRANCH ]                         

                    cCode := aElem[ ENT_CODE ]
                    cSeekAlias := aElem[ ENT_ALIAS ] 
                    cParameter := aElem[ ENT_PARAMETER ]
                    cAuxBranch := xFilial( cSeekAlias )
                    cFindBranch := xFilial( cSeekAlias )

                    For nX := 1 to len( aWhere )
                        If !( '_FILIAL' $ aWhere[ nX ][ 1 ] )
                            cSeek += aWhere[ nX ][ 2 ]
                            cContent += aWhere[ nX ][ 2 ] + '|'
                            aAdd( aTam, TamSX3( aWhere[ nX ][ 1 ] )[ 1 ] )
                        Else
                            aWhere[ nX ][ 2 ] := xFilial( cSeekAlias )
                        EndIf
                    Next
                    cContent := Subs( cContent, 1, len( cContent ) - 1 )

                    IF lOtherCompany .Or. ( cBranchbySM0 != cBranchbyRecord ) 
                        lContinue := .T.

                        cFilAnt := aSM0[ nEmp ][2]

                        cNewBranch := cBranchbySM0

                        lUnique   := .T.
                        
                        cParamContent := SuperGetMV( aElem[ ENT_PARAMETER ], .F. )
                        If !Empty( cParamContent )
                            cContent := cParamContent
                            cSeek := ''
                            aAux := StrTokArr( cParamContent, '|' )
                            For nX := 1 to len( aAux )
                                cSeek += Padr( aAux[nX], aTam[ nX ] )
                            Next
                        EndIf

                        DBSelectArea( cSeekAlias )
                        DbSetOrder(1)

                        IF Empty( cParamContent ) .or. !MSSeek( xFilial( cSeekAlias ) + cSeek ) 
                            If cSeekAlias != "FRV" .And. !MSSeek( xFilial( cSeekAlias ) + cSeek ) .and. !MSSeek( cNewBranch + cSeek )
                                RecLock( cSeekAlias, .T.)
                                For nFields := 1 To Len( aModel[2] )
                                    aFields := aModel[2][ nFields ]
                                    If '_FILIAL' $ aFields[1]
                                        FieldPut( FieldPos( aFields[1] ), cNewBranch )
                                    else
                                        FieldPut( FieldPos( aFields[1] ), aFields[2] )
                                    EndIf
                                Next 
                                MsUnLock()
                            else
                                lUnique := .F.
                                lFind := .T.

                                IF cSeekAlias != "FRV" .And. MSSeek( xFilial( cSeekAlias ) + cSeek ) 
                                    cCodeOrigin := aElem[ ENT_CODE ]
                                    aElem[ ENT_CODE ] := Subs( aElem[ ENT_CODE ], 1, len( aElem[ ENT_CODE ] ) - 1) + '0'
                                    
                                    While lFind
                                        aElem[ ENT_CODE ] := Padr( Soma1( aElem[ ENT_CODE ] ), len( aElem[ ENT_CODE ] ) )

                                        nX := Ascan( aWhere , {|x| '_COD' $ x[1] } )
                                        If nX > 0
                                            aWhere[ nX ][ 2 ] := aElem[ ENT_CODE ] 
                                        EndIf

                                        IF GRRGetID( cSeekAlias, aWhere ) == 0
                                            lFind := .F.
                                            
                                            aWizParam[ nElem ][ ENT_CODE ] := aElem[ ENT_CODE ]
                                            aWizParam[ nElem ][ ENT_WHERE ][ 1 ][ 2 ] := cBranchbySM0
                                            aWizParam[ nElem ][ ENT_WHERE ][ nX ][ 2 ] := aElem[ ENT_CODE ]

                                            nX := Ascan( aWizParam[ nElem ][ ENT_MODEL ][2]  , {|x| '_COD' $ x[1] } )
                                            If nX > 0
                                                aWizParam[ nElem ][ ENT_MODEL ][2][ nX ][ 2 ] := aElem[ ENT_CODE ] 
                                            EndIf                                                

                                            aWhere[ 1 ][ 2 ] := cBranchbySM0

                                            cContent := ''
                                            For nX := 1 to len( aWhere )
                                                If !( '_FILIAL' $ aWhere[ nX ][ 1 ] )
                                                    cContent += aWhere[ nX ][ 2 ] + '|'
                                                EndIf
                                            Next
                                            cContent := Subs( cContent, 1, len( cContent ) - 1 )
                                        EndIf
                                    End
                                    
                                    RecLock( cSeekAlias, .T. )
                                        For nFields := 1 To Len( aElem[ ENT_MODEL ][2] )
                                            aFields := aElem[ ENT_MODEL ][2][ nFields ]
                                                    
                                            If '_FILIAL' $ aFields[1]
                                                FieldPut( FieldPos( aFields[1]), cBranchbySM0 )
                                            ElseIf aFields[1] == ( SUBSTR( cSeekAlias, 2, 3 ) + '_COD' )
                                                FieldPut( FieldPos( aFields[1] ), aElem[ ENT_CODE ] )
                                            else
                                                FieldPut( FieldPos( aFields[1] ), aFields[2] )
                                            EndIf
                                        Next 
                                    MSUnlock()      
                                else
                                    If GRRVldFRV( @aElem )
                                        GRRMakeFRVRecord( aElem[ ENT_CODE ], aElem[ ENT_STORE ] )
                                    EndIf
                                EndIf

                                // volta o conteúdo original para o código
                                aElem[ ENT_CODE ] := cCodeOrigin
                            EndIf
                        endif

                        cLastBranch := xFilial( cSeekAlias )

                        If lContinue
                            cFindBranch := cLastBranch

                            If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cFindBranch .and. x[ ENT_CODE ] == aElem[ ENT_PARAMETER ] } ) == 0
                                Aadd( aSX6, {  cFindBranch , aElem[ ENT_PARAMETER ], 'C', ;
                                I18N( STR0050, { aElem[ ENT_IDENT ] } ), ;
                                '', '', cContent, cContent, cContent, 'S', 'S'} )   //"#1 utilizado para gerar contas a pagar para a adquirente."
                            EndIf
                        ENDIF
                    Else
                        If Ascan( aSX6, {|x| x[ ENT_BRANCH ] == cFindBranch  .and. x[ ENT_CODE ] == cParameter } ) == 0
                            Aadd( aSX6, { cFindBranch , cParameter, 'C', ;
                                i18N( STR0050, { aElem[ ENT_IDENT ] } ), ;
                                '', '', cContent, cContent, cContent, 'S', 'S' } )     //"#1 utilizado para gerar contas a pagar para a adquirente."
                        ENDIF
                    EndIf
        
                    aElem[ ENT_CODE ] := cCode
                    cBranchbyRecord := xFilial( cSeekAlias )
                Next

                // Associa o cliente ao fornecedor
                GRRRlCusXSup( aSX6 )
            EndIf
        EndIF
        
        lUnique := .T.
    Next

    SaveParameters( aSX6 )

    If ( cCompExec != cEmpAnt ) .OR. ( cBranchExec != cFilAnt )
        RPCClearEnv()
        GRRConnCompany( cCompExec, cBranchExec )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aSM0 )
    FWFreeArray( aSX6 )
    FWFreeArray( aModel )
    FWFreeArray( aElem )
    FWFreeArray( aWhere )
    FWFreeArray( aItemsSX6 )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetModel
Esta função é responsável por retornar as informações armazenadas no banco de dados 
para um registro específico, que pode ser usado como base para replicar as mesmas 
informações em outro ambiente.

@param cAlias, caracter, nome da tabela a qual o modelo se refere
@param aWhere, array, vetor com as informações para busca do registro modelo

@return, array, contém os dados modelo para replicar nas outras empresas/filiais
    [1] - recno do registro
    [2] - vetor com as informações do registro.
@author  Marcia Junko
@since   06/06/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRGetModel( cAlias, aWhere )
    Local aSvAlias := GetArea()
    Local aStru := {}
    Local aInfo := {}
    Local nFields := 0
    Local nRecno := 0
    Local xContent
    Local cField := ''

    aSvAlias := GetArea()

    aStru :=  ( cAlias )->( DBStruct() )

    nRecno := GRRGetID( cAlias, aWhere )

    DBSelectArea( cAlias )
    DBGoto( nRecno )

    For nFields := 1 to len( aStru )
        cField := aStru[ nFields ][1]
        xContent := ( cAlias )->( FieldGet( FieldPos( aStru[ nFields ][1] ) ) )
        IF !Empty( xContent ) .And. !( cField $ "USERLGI|USERLGA" )
            aAdd( aInfo, { cField, xContent }  )
        EndIf
    Next

    RestArea( aSvAlias )
    
    FWFreeArray( aSvAlias )
    FWFreeArray( aStru )
Return { nRecno, aInfo }


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRGetID
Esta função resgata o R_E_C_N_O_ do registro de acordo com a condição pesquisada.

@param cAlias, caracter, Alias da tabela a ser pesquisada
@param aWhere, array, vetor com os campos e condições do WHERE

@return, number, R_E_C_N_O_ do registro

@author  Marcia Junko
@since   06/06/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRGetID( cAlias, aWhere )
    Local aSvAlias := GetArea()
    Local cQuery := ''
    Local cTempAlias := ''
    Local nItems := 0
    Local nRecno := 0

    cQuery := "SELECT R_E_C_N_O_ AS ID FROM " + RetSqlName( cAlias ) + " WHERE "

    For nItems := 1 to len( aWhere )
        cQuery += aWhere[ nItems ][1] + " = '" + aWhere[ nItems ][2] + "' AND "
    Next
    cQuery += " D_E_L_E_T_ = ' '"
    
    cTempAlias := MPSysOpenQuery( cQuery )

    if ( cTempAlias )->( !EOF() )
        nRecno := ( cTempAlias )->ID
    EndIf

    ( cTempAlias )->( DbCloseArea() )

    RestArea( aSvAlias )
    
    FWFreeArray( aSvAlias )
Return nRecno


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRRlCusXSup
Esta função associa o fornecedor Suplier ao cliente Supplier de acordo com o conteúdo
que será gravado no parâmetro.

@param aSX6, array, vetor com os parâmetros que serão gravados pelo Wizard.

@author  Marcia Junko
@since   06/06/2022
/*/
//-------------------------------------------------------------------------------------
Static Function GRRRlCusXSup( aSX6 )
    Local aSvAlias := GetArea()
    Local aProvider := {}
    Local aClient := {}
    Local aWhere := {}
    Local cBranchProvider := ''
    Local cBranchClient := ''
    Local nProvider := 0
    Local nClient := 0
    Local nRecClient := 0
    Local nRecProvider := 0
    
    cBranchProvider := xFilial( "SA2" )
    cBranchClient := xFilial( "SA1" )

    nProvider := Ascan( aSX6, {|x| x[1] == cBranchProvider .And. x[2] == "MV_GRRFPAY" } )
    // If nProvider == 0
    //     nProvider := Ascan( aSX6, {|x| Empty( x[1] ) .And. x[2] == "MV_GRRFPAY" } )
    // EndIf

    If nProvider > 0
        nClient := Ascan( aSX6, {|x| x[1] == cBranchClient .And. x[2] == "MV_GRRCPAY" } )
        // If nClient == 0
        //     nClient := Ascan( aSX6, {|x| Empty( x[1] ) .And. x[2] == "MV_GRRCPAY" } )
        // EndIf
    
        aProvider := StrTokArr( aSX6[ nProvider ][7], '|' )
        If !Empty( aProvider ) .And. nClient > 0
            aWhere := { { 'A2_FILIAL', cBranchProvider }, { 'A2_COD', aProvider[1] }, { 'A2_LOJA', aProvider[2] } }
            nRecProvider := GRRGetID( 'SA2', aWhere )
      
            If nRecProvider > 0
                SA2->( DbGoTo( nRecProvider ) )
                aClient := StrTokArr( aSX6[ nClient ][7], '|' )
                If !Empty( aClient )
                    aWhere := { { 'A1_FILIAL', cBranchClient }, { 'A1_COD', aClient[1] }, { 'A1_LOJA', aClient[2] } }
                    nRecClient := GRRGetID( 'SA1', aWhere )

                    If nRecClient > 0
                        RecLock("SA2", .F.)
                            SA2->A2_CLIENTE := aClient[1]
                            SA2->A2_LOJCLI := aClient[2]
                        MSUnlock()
                    EndIf
                EndIf
            EndIf    
        EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aProvider )
    FWFreeArray( aClient )
    FWFreeArray( aWhere )
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveParameters
Salva os parâmetros na base de dados.

@param aSX6, array, Lista de parâmetros a gravar

@author  Marcia Junko
@since   16/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SaveParameters( aSX6 ) 
    Local aStruct := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_DESC1", "X6_DESC2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI", "X6_PYME" }
    Local aSvAlias := GetArea()
    Local lFind    := .F.
    Local nParams := 0
    Local nFields := 0

    Default aSX6 := {}
    
    dbSelectArea( "SX6" )
    dbSetOrder(1)
    For nParams := 1 To Len( aSX6 )
        If !Empty( aSX6[ nParams ][2] )
            If !dbSeek( aSX6[ nParams, 1] + aSX6[ nParams, 2] )
                lFind := .F.
            Else
                lFind := .T.
            EndIf

            RecLock( "SX6", !lFind )
                For nFields := 1 To Len( aSX6[ nParams ] )
                    If !Empty( FieldName( FieldPos( aStruct[ nFields ] ) ) )
                        IF !lFind .Or. "X6_CONT" $ aStruct[ nFields ]
                            FieldPut( FieldPos( aStruct[ nFields ] ), aSX6[ nParams, nFields] )
                        EndIf
                    EndIf
                Next 
            MsUnLock()
        EndIf
    Next

    RestArea( aSvAlias )

    FwFreeArray( aSvAlias )
    FWFreeArray( aSX6 )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRVldFRV
Função de validação da situação de cobrança

@param aBilling, array, vetor com as informações da situação de cobrança, onde:
    [1] - filial da situação de cobrança
    [2] - código da situação de cobrança
    [3] - descrição da situação
    [4] - "vazio"
    [5] - "vazio"
    [6] - nome do parâmetro que vai armazenar a informação da situação para o GRR
    [7] - tabela da entidade - "FRV"
    [8] - Identificador
    [9] - conteúdo gravado no parâmetro
    [10] - vetor com as informações do modelo do registro para replicá-lo
    [11] - vetor com as condições de pesquisa

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   08/06/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRVldFRV( aBilling )
    Local aSvAlias  := GetArea()
    Local aRecords := {}
    Local cParamContent := ''
    Local cBillingCode := ''
    Local cQuery := ''
    Local cTempAlias := GetNextAlias()
    Local nTamFRVCod := 0

    cParamContent  := aBilling[ ENT_CONTENT ]
    nTamFRVCod  := TamSX3( "FRV_CODIGO" )[1]
    cBillingCode    := Replicate( "0", nTamFRVCod )

    cQuery := " SELECT FRV_CODIGO"
    cQuery += " FROM " + RetSQLName("FRV") + " FRV"
    cQuery += " WHERE FRV_FILIAL = '" + xFilial( "FRV" )  + "' "
    cQuery += " AND FRV.D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery( cQuery )

    MPSysOpenQuery( cQuery, cTempAlias )

    ( cTempAlias )->( DbGoTop() )

    While ( cTempAlias )->( !( EoF() ) )
        AAdd( aRecords, Upper( AllTrim( ( cTempAlias )->FRV_CODIGO ) ) )
        ( cTempAlias )->( DbSkip() )
    End

    ( cTempAlias )->( DbCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )

    If Len( aRecords ) > 0
        //------------------------------------------------
        // Parâmetro preenchido e carteira existente
        //------------------------------------------------
        If !Empty( cParamContent ) .And. AScan( aRecords, Upper( Alltrim( cParamContent ) ) ) > 0
            FWFreeArray( aRecords )
            Return .F.
        EndIf

        //------------------------------------------------
        // Parâmetro preenchido não encontrado na tabela
        //------------------------------------------------
        IF AScan( aRecords, Upper( Alltrim( aBilling[ ENT_CODE ] ) ) ) == 0 
            FWFreeArray( aRecords )
            Return .T.
        EndIf

        cBillingCode := SubStr( cBillingCode, 1, nTamFRVCod )
        While cBillingCode != SubStr( Replicate( "Z", nTamFRVCod ), 1, nTamFRVCod )
            If AScan( aRecords, Upper( AllTrim( cBillingCode ) ) ) > 0
                cBillingCode := Soma1( cBillingCode ) 
            Else
                aBilling[ ENT_CODE ] := cBillingCode
                Exit
            EndIf
        End
    EndIf

    FWFreeArray( aRecords )
Return .T.


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRMakeFRVRecord
Função reponsável por criar e configurar uma situação de cobrança de acordo com as 
especificações de manipulação do registro financeiro.

@param cCode, caracter, Código da situação de cobrança
@param cDescription, caracter, Descrição da situação de cobrança

@author  Marcia Junko
@since   08/06/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRMakeFRVRecord( cCode, cDescription )
    FTFWGrvFRV( { cCode, cDescription, "2", "", "2", "1", "2", "2" } )
    GRRBlockFRV( cCode )
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRBlockFRV
Função reponsável por ajustar as regras de bloqueio da situação de cobrança.

@param cSituation, caracter, Código da situação de cobrança
@param cProcess, caracter, Códigos de processo que devem ser excluídos para a situação de cobrança

@author  Marcia Junko
@since   08/06/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRBlockFRV( cSituation, cProcess )
    Local aSvAlias := GetArea()

    Default cProcess := '0001|0002|0003|0004|0007|0008|0009|0010'

    DBSelectArea( "FW2" )
    DbSetOrder(1)   //FW2_FILIAL+FW2_SITUAC+FW2_CODIGO

    IF FW2->( DbSeek( xFilial("FW2") + cSituation ) )
        While FW2->( !Eof() ) .And. FW2->FW2_SITUAC == cSituation
            IF !( FW2->FW2_CODIGO $ cProcess )
                Reclock( "FW2", .F. )
                    DBDelete()
                MSUnlock()
            EndIf

            FW2->( DBSkip() )
        End
    EndIf

    RestArea( aSvAlias )
    
    FWFreeArray( aSvAlias )
return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGRRMode
Avalia se o Wizard foi executado anteriormente para vir com o tipo de instalação posicionada.

@param aOptions, array, Vetor com os tipos de instalação disponíveis

@return caracter, Tipo de instalação do ambiente GRR. Onde: 1=Sandbox; 2=Produção
@author  Marcia Junko
@since   09/11/2022
/*/
//-------------------------------------------------------------------------------------
Static Function LoadGRRMode( aOptions )
    Local cContent := ''
    Local nPosition := 0

    cContent := GRRSysValue( 'grr_sndbox' )
    If !Empty( cContent )
        nPosition := Iif( cContent == 'true', 1, 2 )
    Else
        nPosition := 2
    EndIf
Return aOptions[ nPosition ]

//-------------------------------------------------------------------
/*/{Protheus.doc} FinancialIntegration
    @description Função responsável por utilizar a classe FinancialIntegration para
    validar e realizar a configuração inicial do ambiente para a integração da plataforma
    com o módulo Financeiro (GRRI110).
    @author guilherme.sordi@totvs.com.br
    @since 09/06/2025
    @version 12.1.2410
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=910680319
*/
//-------------------------------------------------------------------
Static Function GRRPreI110(oStatus as object)
    local oFinIntegration := totvs.protheus.backoffice.apps.grr.integration.financial.FinancialIntegration():new()
    local lSuccess := .F.
    local cError := "FinancialIntegration class not return a valid response."
    local jResult := JsonObject():new()

    if getRpoRelease() <= "12.1.2410" .and. !MethIsMemberOf(oFinIntegration, "setupEnvironmentFromWizard")
        lSuccess := .F.
        cError := STR0057 //"O ambiente não possui todos os artefatos necessários para configurar a integração com o SIGAFIN. Aplique o pacote de atualização mais recente."
    else

        jResult := oFinIntegration:setupEnvironmentFromWizard()
        if jResult:hasProperty("success") .and. valType(jResult['success']) == 'L'
            lSuccess := jResult['success']
        endIf
        if !lSuccess .and. jResult:hasProperty("message") .and. valType(jResult['message']) == 'C'
            cError := jResult['message']
        endIf
    
    endIf

    if lSuccess
        GRRWizStatus( @oStatus, STR0056 ) //"Integração com SIGAFIN concluída com sucesso."
    else
        GRRWizStatus( @oStatus, STR0055 ) //"Integração com SIGAFIN não pôde ser concluída. Verifique os logs."
        GRRWizStatus( @oStatus, cError )
    endIf

    jResult:fromJson("{}")
    freeObj(jResult)
    freeObj(oFinIntegration)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} WalletDic
    @description Valida se os requisitos mínimos de dicionário para
	a carteira são atendidos.
    @author claudio.yoshio@totvs.com.br
    @since 04/09/2025
    @version 12.1.2410
*/
//-------------------------------------------------------------------
Static Function WalletDic
    local lRet := .F.

    if GetRpoRelease() >= "12.1.2610" .or. findClass( "totvs.protheus.backoffice.apps.grr.integration.financial.Validations" )
        lRet := totvs.protheus.backoffice.apps.grr.integration.financial.Validations():hasWalletDictionaryRequirements()
   endIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WalletRpo
    @description Valida se os requisitos mínimos de repositório para
	a carteira são atendidos.
    @author claudio.yoshio@totvs.com.br
    @since 04/09/2025
    @version 12.1.2410
*/
//-------------------------------------------------------------------
Static Function WalletRpo
    local lRet := .F.
    
    if GetRpoRelease() >= "12.1.2610" .or. findClass( "totvs.protheus.backoffice.apps.grr.integration.financial.Validations" )
        lRet := totvs.protheus.backoffice.apps.grr.integration.financial.Validations():hasWalletRepositoryRequirements()
   endIf
Return lRet
