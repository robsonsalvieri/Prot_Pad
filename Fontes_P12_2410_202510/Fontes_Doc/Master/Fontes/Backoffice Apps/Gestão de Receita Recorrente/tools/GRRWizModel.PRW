#include "protheus.ch"
#include "GRRWizModel.ch"

//-------------------------- GRRWizModel -----------------------------------
// Biblioteca de funções para modelo de Wizard Genérico
//---------------------------------------------------------------------------

Class GRRWizModel
    Data cSource                // Nome do fonte que originou a chamada do wizard
    Data cFinishStep            // Label apresentado no passo de gravação do Wizard
    Data cUser                  // Usuário para autenticação
    Data cPsw                   // Senha para autenticação
    Data cFinishStamp           // Armazena a data e hora de quando a aba Finish é iniciada ( no formato FWTimeStamp, tipo 6 ).
    Data cStepColor             // Indica o RGB que deve ser utilizado para identificar os steps do Wizard

    Data nHeight                // Altura do componente Wizard
    Data nWidth                 // Comprimento do componente Wizard

    Data lUseCarol              // Indica se o wizard deve avaliar o uso da Carol
    Data lWizByCompany          // Indica se o wizard deve ser executado por empresa e apresentar a lista de empresas para seleção.
    Data lIsSandbox             // Indica se o wizard está configurando um ambiente Sandbox
    Data lResized               // Indica que as dimensões do Wizard foram alteradas pelo usuário
    Data lNoScreen              // Indica que não apresenta o Wizard em tela ( propriedade serve para testar a classe sem a interface )
    
    Data bCustomTab             // bloco de chamada das abas customizadas
    Data bVldDic                // bloco para validação de dicionário do ambiente
    Data bVldRpo                // bloco para validação de repositório do ambiente
    Data bFinish                // bloco para gravação dos dados por empresa
    Data bUniqueFinish          // bloco para gravação única ( independe da empresa )

    Data aWelcome               // Vetor com as mensagens que serão apresentadas na tela de boas-vindas
    Data aCompany               // Vetor com as empresas selecionadas durante a execução do Wizard
    Data aRetValues             // Vetor com as informações resultantes da execução do Wizard e que pode ser utilizado pelas funções de gravação.
    Data aPreviusCompany        // Vetor com as empresas selecionadas em execuções anteriores 
    Data aPreviusBranches       // Vetor com as filiais configuradas em execuções anteriores

    Data oStatus                // objeto de atualização das etpas de gravação

    Method New() CONSTRUCTOR
    
    Method Activate()
    Method CreateWizard()
    Method MakeWelcome()
    Method MakeLogin()
    Method MakeCustomTab()
    Method MakeFinish()

    Method SetWelcome()
    Method SetFinishText()
    Method SetFinish()
    Method SetUniqueFinish()    
    Method SetCustomTab()
    Method SetVldDic()
    Method SetVldRpo()
    Method SetUseCarol()
    Method SetWizByCompany()
    Method SetPrvCompany()
    Method SetPrvBranches()
    Method SetStepColor()
    Method SetSandbox()
    Method SetHeight()
    // Method SetWidth()
    Method SetNoScreen()

    Method ValidDic()
    Method ValidRpo()
    
    Method Destroy()
ENDCLASS

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe. Responsável por inicializar as propriedades do objeto.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method New(  ) Class GRRWizModel
    ::cSource := ProcSource( 1 )   // Retorna o nome do fonte PRW que fez a chamada da função
    ::cSource := StrTran( ::cSource, '.PRW', '')

    ::cUser := Space( 25 )
    ::cPsw := Space( 25 )
    ::cFinishStep := STR0001    //"Ativando a integração"
    ::cFinishStamp := ''
    ::cStepColor := ''

    ::nHeight := 530
    ::nWidth := 720

    ::aWelcome := { 'Hello World' }
    ::aCompany := {}
    ::aRetValues := {}
    ::aPreviusCompany := {}
    ::aPreviusBranches := {}

    ::lUseCarol := .T.
    ::lWizByCompany := .T.
    ::lIsSandbox := .F.
    ::lResized := .F.
    ::lNoScreen := ::SetNoScreen()

    ::bCustomTab := {|| }
    ::bVldDic := {|| }
    ::bVldRpo := {|| }
    ::bFinish := {|| }
    ::bUniqueFinish := {|| }

    ::oStatus := NIL
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateWizard
Método responsável por criar o Wizard.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method CreateWizard(  ) Class GRRWizModel
    Local oStepWiz

    iF !self:lNoScreen
        oStepWiz:= FWWizardControl():New( , { ::nHeight, ::nWidth } )
        oStepWiz:ActiveUISteps()

        //-------------------------------------------------------
        // Cria a aba de abertura
        //-------------------------------------------------------
        If !Empty( ::aWelcome )
            ::MakeWelcome( oStepWiz )
        EndIf

        //-------------------------------------------------------
        // Cria a aba de login
        //-------------------------------------------------------
        ::MakeLogin( oStepWiz )

        //-------------------------------------------------------
        // Cria as abas customizadas
        //-------------------------------------------------------
        If !Empty( ::bCustomTab )
            ::MakeCustomTab( oStepWiz )
        EndIf

        //-------------------------------------------------------
        // Cria a aba de encerramento
        //-------------------------------------------------------
        If !Empty( ::bFinish )
            ::MakeFinish( oStepWiz )
        EndIf
        
        //-------------------------------------------------------
        // Aplica um RGB especial aos steps do Wizard
        //-------------------------------------------------------
        If !Empty( ::cStepColor )
            oStepWiz:oUIStepWizard:oUiSteps:cBallColor := ::cStepColor
        EndIf
        
        oStepWiz:Activate()
    EndIF
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeWelcome
Método para criação da aba de abertura do Wizard.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method MakeWelcome( oWizard ) class GRRWizModel
    Local oNewPag  

    iF !self:lNoScreen
        //-----------------------------------------------------------------------
        // Pagina de Boas Vindas
        //-----------------------------------------------------------------------
        oNewPag := oWizard:AddStep()
        oNewPag:SetStepDescription( STR0002 )   //"Boas vindas"
        oNewPag:SetConstruction( { | Panel | MakeWelcome( Panel, ::aWelcome, self:lNoScreen ) } )
        oNewPag:SetNextAction( {|| .T.} )
    EndIf
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeLogin
Método para criação da aba de login.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method MakeLogin( oWizard ) class GRRWizModel
    Local oNewPag  
    Local lRet := .T.

    iF !self:lNoScreen
        //------------------------
        // Pagina de Autenticação
        //------------------------
        oNewPag := oWizard:AddStep()
        oNewPag:SetConstruction( {|Panel| MakeLogin( Panel, @self ) } )
        oNewPag:SetStepDescription( STR0003 )   //"Autenticação"
        oNewPag:SetNextAction( {|| FWMsgRun( NIL, { || lRet := VldLogin( self ) }, Nil, STR0004 ), lRet })     //"Validando os acessos do usuário."    
    EndIf
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeCustomTab
Método para criação das abas customizadas, se informadas.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method MakeCustomTab( oWizard ) class GRRWizModel
    Eval( ::bCustomTab )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeFinish
Método para criação da aba s abde gravação.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method MakeFinish( oWizard ) class GRRWizModel
    iF !self:lNoScreen
        //----------------------------------
        // Pagina de Gravação\Ativação
        //----------------------------------
        oNewPag := oWizard:AddStep()
        oNewPag:SetConstruction( {|Panel| MakeFinish( Panel, self ), SaveWizConfig( self ) } )
        oNewPag:SetStepDescription( Self:cFinishStep )  
        oNewPag:SetNextAction( {|| .T.} )
        oNewPag:SetPrevWhen( {|| .F. } )
        oNewPag:SetCancelWhen( {|| .F. } )
    EndIf
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetWelcome
Atribui o texto que será apresentado na tela de abertura

@param aWelcome, array, vetor com os textos que serão apresentados na tela de abertura.
@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetWelcome( aWelcome ) class GRRWizModel
    ::aWelcome := aWelcome
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFinishText
Atribui o texto que será apresentado no passo de gravação

@param cFinishStep, caracter, label apresentado no passo de gravação do Wizard

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetFinishText( cFinishStep ) class GRRWizModel
    ::cFinishStep := cFinishStep
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetUniqueFinish
Atribui ao wizard a função de gravação única. A função chamada por esta bloco será 
executada uma única vez, independente da quantidade de empresas que tenham sido 
selecionadas. Por isso, devem ser colocadas aqui, por exemplo, as funções de gravação 
dos dados de conexão à plataforma.

@param bUniqueFinish, codeblock, bloco com a função de gravação única.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetUniqueFinish( bUniqueFinish ) class GRRWizModel
    ::bUniqueFinish := bUniqueFinish
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFinish
Atribui ao wizard a função de gravação por empresa. A função chamada por esta bloco será 
executada por empresa\filial. Por isso indica-se colocar neste bloco rotinas com funções 
que dependam do ambiente aberto e na empresa\filial correspondente.

@param bFinish, codeblock, bloco com a função de gravação por empresa\filial.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetFinish( bFinish ) class GRRWizModel
    ::bFinish := bFinish
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetCustomTab
Atribui ao wizard a função para criação das abas adicionais. 
Todas as abas adicionais podem ser criadas na mesma função informada no codeblock para 
permitir um melhor controle na execução entre as abas.

@param bCustom, codeblock, bloco com a função para criação das abas adicionais.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetCustomTab( bCustom ) class GRRWizModel
    ::bCustomTab := bCustom
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetVldDic
Atribui ao wizard a função de validação do ambiente, como por exemplo, regras para 
validação do dicionário ou outra regra que seja necessária.

@param bVldDic, codeblock, bloco com a função de validação

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetVldDic( bVldDic ) class GRRWizModel
    ::bVldDic := bVldDic
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetUseCarol
Define se o produto utiliza integração com a Carol.

@param lUseCarol, boolean, indica se o produto utiliza integração com a Carol.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetUseCarol( lUseCarol ) class GRRWizModel
    ::lUseCarol := lUseCarol
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetWizByCompany
Define se o wizard roda por empresa

@param lWizByCompany, boolean, indica se o wizard roda por empresa.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method SetWizByCompany( lWizByCompany ) class GRRWizModel
    ::lWizByCompany := lWizByCompany
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPrvCompany
Define ao objeto a lista de empresas selecionadas em execuções anteriores 

@param aPreviusCompany, array, vetor com as empresas selecionadas em execuções anteriores 

@author  Marcia Junko
@since   04/04/2022
/*/
//-------------------------------------------------------------------------------------
Method SetPrvCompany( aPreviusCompany ) class GRRWizModel
    ::aPreviusCompany := aClone( aPreviusCompany )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPrvBranches
Define ao objeto a lista de filiais selecionadas em execuções anteriores 

@param aPreviusBranches, array, vetor com as filiais selecionadas em execuções anteriores 

@author  Marcia Junko
@since   04/04/2022
/*/
//-------------------------------------------------------------------------------------
Method SetPrvBranches( aPreviusBranches ) class GRRWizModel
    ::aPreviusBranches := aClone( aPreviusBranches )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetStepColor
Define o RGB que deve ser utilizado para identificar os steps do Wizard

@param cColor, caracter, código RGB

@author  Marcia Junko
@since   08/06/2022
/*/
//-------------------------------------------------------------------------------------
Method SetStepColor( cColor ) class GRRWizModel
    ::cStepColor := cColor
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetSandbox
Define se o Wizard deve tratar a configuração como Sandbox.

@param lUseSandbox, boolean, Indica se o Wizard está configurando um ambiente Sandbox.

@author  Marcia Junko
@since   14/06/2022
/*/
//-------------------------------------------------------------------------------------
Method SetSandbox( lUseSandbox ) class GRRWizModel
    ::lIsSandbox := lUseSandbox
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetHeight
Ajusta a altura do Wizard.

@param nHeight, number, Altura do Wizard

@author  Marcia Junko
@since   15/06/2022
/*/
//-------------------------------------------------------------------------------------
Method SetHeight( nHeight ) class GRRWizModel
    ::nHeight := nHeight
    ::lResized := .T.
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetWidth
Ajusta o comprimento do Wizard.

@param nWidth, number, Comprimento do Wizard

@author  Marcia Junko
@since   15/06/2022
/*/
//-------------------------------------------------------------------------------------
// Method SetWidth( nWidth ) class GRRWizModel
//     ::nWidth := nWidth
//     ::lResized := .T.
// Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetNoScreen
Atribui que não apresenta o Wizard em tela ( propriedade serve para testar a classe sem a interface )

@param lNoScreen, boolean, Indica se não apresenta a interface
@author  Marcia Junko
@since   15/06/2024
/*/
//-------------------------------------------------------------------------------------
Method SetNoScreen( lNoScreen ) class GRRWizModel
    Default lNoScreen := .F.

    ::lNoScreen := lNoScreen
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidDic
Executa a função de validação do ambiente.

@return boolean, indica se pode prosseguir com a instalação.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method ValidDic( ) class GRRWizModel
Return Eval( ::bVldDic )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o componente do Wizard.

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Method Destroy( ) class GRRWizModel
    ::cSource := ''
    ::cUser := ''
    ::cPsw := ''
    ::cFinishStep := ''
    ::cFinishStamp := ''
    ::cStepColor := ''

    ::nHeight := 0
    ::nWidth := 0

    ::aWelcome := {}
    ::aCompany := {}
    ::aRetValues := {}
    ::aPreviusCompany := {}
    ::aPreviusBranches := {}

    ::lUseCarol := .T.
    ::lWizByCompany := .T.
    ::lIsSandbox := .F.
    ::lResized := .F.
    ::lNoScreen:= .F.

    ::bCustomTab := NIL
    ::bVldDic := NIL
    ::bFinish := NIL
    ::bUniqueFinish := NIL

    ::oStatus := NIL

    FWFreeArray( ::aWelcome )
    FWFreeArray( ::aCompany )
    FWFreeArray( ::aRetValues )
    FWFreeArray( ::aPreviusCompany )
    FWFreeArray( ::aPreviusBranches )
    Freeobj( ::oStatus )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeWelcome
Função que monta a tela de boas vindas

@param oPanel, object, Painel onde os componentes serão criados
@param aWelcome, array, Vetor com as mensagens que serão apresentadas na tela de boas-vindas
@param lNoScreen, boolean, Indica que não apresenta o Wizard em tela ( propriedade serve para testar a classe sem a interface )

@author  Marcia Junko
@since   24/03/2022
/*/
//-------------------------------------------------------------------
Static Function MakeWelcome( oPanel, aWelcome, lNoScreen )
    Local cWelcome := ''
    Local nI := 0
    Local oFont3
    Local oSay

    Default lNoScreen := .F.

    iF !lNoScreen
        oFont3 := TFont():New( "Arial",, -15,, .F.,,,,,, .F., .F. )	

        For nI := 1 to Len( aWelcome )
            cWelcome += aWelcome[ nI ] + CRLF
        Next

        oSay := TSay():New( 10, 10, {|| cWelcome }, oPanel, , oFont3, , , , .T., , , 340, 155, , , , , , .T. )    
        oSay:SetTextAlign( 3, 0 )
    EndIf
 Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeLogin
Função de montagem dos componentes da aba.

@param oPanel, object, Painel onde os componentes serão criado
@param @oSelf, object, objeto da classe GRRWizModel

@author  Marcia Junko
@since   23/03/2022
/*/
//-------------------------------------------------------------------
Static Function MakeLogin( oPanel, oSelf )
    Local oTGet1
    Local oTGet2
    Local oList
    Local nLine := 20
    Local nCol1 := 40
    Local nCol2 := 200

    iF !oSelf:lNoScreen
        oSelf:aCompany := LoadCompany( oSelf )

        DEFINE FONT oCHFont	NAME 'Arial' WEIGHT 10 BOLD 
        DEFINE FONT oCMFont	NAME 'Arial' WEIGHT 10

        @ 10, 10 GROUP TO 50, 350 PROMPT STR0005 OF oPanel PIXEL   //'Autenticação do usuário'
        
        @ nLine, nCol1 SAY STR0006 OF oPanel PIXEL FONT oCHFont //"Usuário:"
        @ nLine + 10, nCol1 MSGET oTGet1 VAR oSelf:cUser SIZE 120, 10 OF oPanel Font oCMFont PIXEL 

        @ nLine, nCol2 SAY STR0007 OF oPanel PIXEL FONT oCHFont //"Senha:"
        @ nLine + 10, nCol2 MSGET oTGet2 VAR oSelf:cPsw SIZE 120, 10 OF oPanel Font oCMFont PIXEL PASSWORD

        If oSelf:lWizByCompany
            //-------------------------------------------------------------------
            // Monta a lista de empresas. 
            //-------------------------------------------------------------------  	
            @ 060, 010 LISTBOX oList;
                FIELDS HEADER "", STR0008, STR0009 ; // "Código"###"Descrição da Empresa"
                SIZE 160, 130 OF oPanel PIXEL; 
                ON DBLCLICK ( oSelf:aCompany[ oList:nAt, 1] := !oSelf:aCompany[ oList:nAt, 1], oList:Refresh( .F. ) ) 
            
                oList:SetArray( oSelf:aCompany )
                oList:bLine := {|| { If( oSelf:aCompany[ oList:nAt, 1], LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )), ;
                    oSelf:aCompany[ oList:nAt, 2], oSelf:aCompany[ oList:nAt, 3] }}
                oList:bHeaderClick := {|a, b| iif( b == 1 , MarkAll( oSelf:aCompany, b), ), oList:Refresh() }
                oList:Refresh()
        EndIf

        oTGet1:SetFocus()
    EndIf
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeFinish
Função de montagem da tela de ativação do Wizard.

@param oPanel, object, Painel onde os componentes serão criado
@param @oSelf, object, objeto da classe GRRWizModel

@author  Marcia Junko
@since   23/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MakeFinish( oPanel, oSelf )
    Local cStatus
    Local oBtnPanel
    Local oFont 
    
    iF !oSelf:lNoScreen
        oBtnPanel := TPanel():New( 0, 0, "", oPanel, , , , , , 40, 40, .T., .T. )
        oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

        DEFINE FONT oFont NAME "Courier New" SIZE 10, 0

        oSelf:oStatus := TMultiGet():New( 12, 35, { |u| Iif( pCount() > 0, cStatus := u, cStatus ) }, oBtnPanel, 290, 145,,,,,, .T.,,,,,,.T.,,,, .T., .T. )		
        oSelf:oStatus:lWordWrap := .T.

        oSelf:cFinishStamp := FWTimeStamp( 6 )
    EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MarkAll
Função para marcar/desmarcar todos os itens de um lista.

@param aArray, array, vetor com os itens a serem marcados/desmarcados
@param nPos, number, posição do array para validar a situação do item

@author  Marcia Junko
@since   23/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function MarkAll( aArray, nPos )
	Local lMark := .F.
	
	aEval( aArray, {|x| iif( !x[ nPos ], lMark := .T., )  })
	aEval( aArray, {|x, i| aArray[ i, nPos] := lMark })
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidArr
Função que valida se algum item da lista está marcado.

@param aArray, array, vetor com os itens para validar a seleção.

@return boolean, valida se existe algum item selecionado. 
@author  Marcia Junko
@since   23/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function ValidArr( aArray )
Return ( aScan( aArray, {|x| x[1] == .T. } ) > 0 )

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadCompany
Monta um vetor com as empresas disponíveis no sistema e já traz a empresa
selecionada, caso o Wizard já tenha sido executado anteriormente.

@param oWizard, object, componente principal do Wizard

@return array, vetor com as empresas para execução do Wizard.
@author  Marcia Junko
@since   25/03/2022
/*/
//-------------------------------------------------------------------
Static Function LoadCompany( oWizard ) 
	Local aCompany := {}
    Local aGrpCompanies := {}

	SET DELET ON

    OpenSM0()
    aGrpCompanies := FWAllGrpCompany()

    IF oWizard:lWizByCompany
        aEval( aGrpCompanies, {|oComp| AAdd( aCompany, { .T., oComp, FWEmpName( oComp ) }) } )

        //-----------------------------------------------------------
        // Selecionas as empresas salvas anteriormente.
        //-----------------------------------------------------------
        IF !Empty( oWizard:aPreviusCompany )
            Aeval( aCompany, {|x| iif( ascan( oWizard:aPreviusCompany, x[ 2 ]) > 0, x[ 1 ] := .T., .F. ) } )    
        EndIf
    Else
        //-----------------------------------------------------------
        // Se não tiver seleção por empresa, inclui sempre a primeira 
        // empresa\filial para conseguir abrir o ambiente
        //-----------------------------------------------------------
        AAdd( aCompany, { .T., aGrpCompanies[1], FWEmpName( aGrpCompanies[1] ) } )
    EndIf

    // If oWizard:lUseCarol
    //     GRRSM0byCarol( @aCompany )
    // EndIf

    FWFreeArray( aGrpCompanies )
Return aCompany

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldLogin
Função que valida as informações de login e avalia se o dicionário está atualizado para
prosseguir com o processo.

@param @oSelf, object, objeto da classe GRRWizModel

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function VldLogin( oSelf )
    Local nVldLogin
    Local cDicCompany   := ""
    Local cNoCompany    := ""
    Local cMsg          := ""
    Local nX            := 0
    Local nCompany      := 0
    Local lValid        := .F.

    If Empty( oSelf:cUser )
        cMsg := STR0010     //"Informe o usuário"
    ElseIf !ValidArr( oSelf:aCompany )
        cMsg := STR0011     //"Selecione ao menos uma empresa"
    ElseIf !oSelf:ValidRpo()
        cMsg := I18N( STR0021, { STR0020 } )     //"Ambiente não possui os requisitos mínimos de fontes do #1." //"Gestão de Receitas"
    Else 
        nVldLogin := PswAdmin( Alltrim( oSelf:cUser ), Alltrim( oSelf:cPsw ) )
        if nVldLogin == 0
            For nX := 1 To Len( oSelf:aCompany )
                If oSelf:aCompany[ nX ][ 1 ]
                    OpenSM0( oSelf:aCompany[ nX ][ 2 ] )      
                    If GRRConnCompany( SM0->M0_CODIGO, SM0->M0_CODFIL, oSelf:cUser, oSelf:cPsw )
                        If nCompany == 0
                            nCompany := nX

                            //---------------------------------------------------
                            // Coloca aqui as funções de load
                            //---------------------------------------------------
                        EndIf
                        lValid := .T.
                        If oSelf:ValidDic()
                            lValid := .T. 
                        Else
                            cDicCompany += SM0->M0_CODIGO + ","
                            lValid   := .F.
                        EndIf
                    Else 
                        cNoCompany += SM0->M0_CODIGO + "," 
                    EndIf
                    RpcClearEnv() 
                EndIf
            Next nX 
            If Empty( cNoCompany ) 
                If lValid 
                    OpenSM0( oSelf:aCompany[ nCompany ][ 2 ] ) 
                    GRRConnCompany( SM0->M0_CODIGO, SM0->M0_CODFIL, oSelf:cUser, oSelf:cPsw )
                Else
                    cMsg := I18N( STR0012, { STR0020, SubStr( cDicCompany, 1, Len( cDicCompany ) - 1 ) } )     //"Atualização de dicionário de dados do #1 não aplicado ou desatualizado para a(s) empresa(s): #2."
                EndIf
            Else
               cMsg     := I18N( STR0013, { SubStr( cNoCompany, 1, Len( cNoCompany ) - 1 ) } )  //"Usuário não possui acesso na(s) empresa(s): #1."
               lValid   := .F.
            EndIf
        Else
            If nVldLogin == 1
                cMsg := STR0014     //"O usuário informado não é administrador do sistema."
            ElseIf nVldLogin == 2
                cMsg := STR0015     //"Dados para login incorretos."
            EndIf
        EndIf
    ENDIF

    If !lValid
        ApMsgAlert( cMsg, STR0016 )     //"Wizard de Configuração"
    EndIf
Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveWizConfig
Função que faz a chamada das funções de gravação do Wizard

@param oSelf, object, objeto da classe GRRWizModel

@return boolean, informa se há erros de preenchimento na aba
@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Static Function SaveWizConfig( oSelf )
    Local nCompany  := 0
    Local lSave  := .T.
    Local lNoScreen := oSelf:lNoScreen

    For nCompany := 1 to len( oSelf:aCompany )
        If oSelf:aCompany[ nCompany ][1]
            IF nCompany > 1
                If !lNoScreen
                    oSelf:oStatus:AppendText( Replicate( '-', 50 ) + CRLF )
                EndIf
            EndIF

            //-----------------------------------------------------------------------
            // Abre o ambinente
            //-----------------------------------------------------------------------
            If !lNoScreen
                GRRWizStatus( oSelf:oStatus, I18N( STR0017, { oSelf:aCompany[ nCompany ][2] } ) )    //"Conectando ambiente - #1"
            EndIf
            GRROpenEnv( oSelf:cUser, oSelf:cPsw, oSelf:aCompany[ nCompany ][2] )

            //-----------------------------------------------------------------------
            // Executa a gravação das informações únicas ( que independem da empresa )
            //-----------------------------------------------------------------------
            If lSave
                If !Empty( oSelf:bUniqueFinish )
                    Eval( oSelf:bUniqueFinish )
                EndIf
                lSave := .F.
            EndIf

            //-----------------------------------------------------------------------
            // Executa a gravação das informações por empresa
            //-----------------------------------------------------------------------
            If !Empty( oSelf:bFinish )
                Eval( oSelf:bFinish )
            EndIf
            
            RpcClearEnv()
            If !lNoScreen
                GRRWizStatus( oSelf:oStatus, I18N( STR0018, { oSelf:aCompany[ nCompany ][2] } ) )    //'Ambiente encerrado - #1'
        
                oSelf:oStatus:AppendText( '' + CRLF )
            EndIf
        EndIf
    NEXT

    If !lNoScreen
        GRRWizStatus( oSelf:oStatus, STR0019 )  //'Configurações finalizadas'
        oSelf:oStatus:Gotop()
        oSelf:oStatus:Refresh()
    EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GRRWizStatus
Função que exibe as informações executadas pelo Wizard ao usuário.

@param oStatus, object, objeto onde as mensagens serão apresentadas
@param cMessage, caracter, Mensagem que será apresentada

@author  Marcia Junko
@since   31/03/2022
/*/
//-------------------------------------------------------------------------------------
Function GRRWizStatus( oStatus, cMessage )
	Iif( oStatus <> NIL, oStatus:AppendText( Padr( Dtoc( MsDate() ), 14 ) + Padr( Time(), 10 ) + ' - ' + cMessage + CRLF ), )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetVldRpo
Atribui ao wizard a função de validação do repositório.
@param bVldRpo, codeblock, bloco com a função de validação
@author  Claudio Yoshio Muramatsu
@since   20/08/2025
/*/
//-------------------------------------------------------------------------------------
Method SetVldRpo( bVldRpo ) class GRRWizModel
    ::bVldRpo := bVldRpo
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidRpo
Executa a função de validação do repositório.
@return boolean, indica se pode prosseguir com a instalação.
@author  Claudio Yoshio Muramatsu
@since   20/08/2025
/*/
//-------------------------------------------------------------------------------------
Method ValidRpo( ) class GRRWizModel
Return Eval( ::bVldRpo )
