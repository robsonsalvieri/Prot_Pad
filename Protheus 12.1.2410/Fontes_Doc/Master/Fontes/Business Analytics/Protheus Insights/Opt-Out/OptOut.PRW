#include "protheus.ch"
#INCLUDE "wizardopt.ch"

Class WizardOutPut
    Data cSource                // Nome do fonte que originou a chamada do wizard
    Data cFinishStep            // Label apresentado no passo de gravação do Wizard
    Data cUser                  // Usuário para autenticação
    Data cPsw                   // Senha para autenticação
    Data cStepColor             // Indica o RGB que deve ser utilizado para identificar os steps do Wizard
    Data nHeight                // Altura do componente Wizard
    Data nWidth                 // Comprimento do componente Wizard
    Data lResized               // Indica que as dimensões do Wizard foram alteradas pelo usuário
    Data bFinish                // bloco para finalização
    Data aWelcome               // Vetor com as mensagens que serão apresentadas na tela de boas-vindas
    Data aFinish                // Vetor com as mensagens de finalização 
    Data cSuggestion            // Armazena as sugestões para melhoria do produto
    Data lVldLogin              //Variavel de controle para validar login
    Data lCancel                //Variavel de controle para quando cancelarem a tela de sugestão

    Method New() CONSTRUCTOR
    
    Method Activate()
    Method CreateWizOpt()
    Method MakeWelcomeOpt()
    Method MakeLogin()
    Method MakeSuggestion()
    Method MakeCustomTab()
    Method MakeFinish()

    Method SetWelcome()
    Method SetFinish()  
    Method SetStepColor()
    Method SetHeight()
    Method SetWidth()
    Method Destroy()
ENDCLASS

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe. Responsável por inicializar as propriedades do objeto.

@author  DANILO SANTOS
@since   25/04/2023 
/*/
//-------------------------------------------------------------------------------------
Method New(  ) Class WizardOutPut
    ::cSource := ProcSource( 1 )   // Retorna o nome do fonte PRW que fez a chamada da função
    ::cSource := StrTran( ::cSource, '.PRW', '')

    ::cUser := Space( 25 )
    ::cPsw := Space( 25 )
    ::cFinishStep := STR0004
    ::cStepColor := ''

    ::nHeight := 530
    ::nWidth := 720
    ::aWelcome := { 'Hello World' }
    ::aFinish := {STR0005}
    ::cSuggestion := ''
    ::lResized := .F.
    ::lVldLogin := .T.
    ::lCancel   := .F.
    ::bFinish := {||}

    
Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateWizOpt
Método responsável por criar o Wizard.

@author  Danilo Santos
@since   25/04/2022
/*/
//-------------------------------------------------------------------------------------
Method CreateWizOpt(  ) Class WizardOutPut
    Local oStepWiz
    
    oStepWiz:= FWWizardControl():New( , { ::nHeight, ::nWidth } )
    oStepWiz:ActiveUISteps()

    //-------------------------------------------------------
    // Cria a aba de abertura
    //-------------------------------------------------------
    If !Empty( ::aWelcome )
        ::MakeWelcomeOpt( oStepWiz )
    EndIf

    //-------------------------------------------------------
    // Cria a aba de login
    //-------------------------------------------------------
    ::MakeLogin( oStepWiz )

    //-------------------------------------------------------
    // Cria tela de Sugestão
    //-------------------------------------------------------
    ::MakeSuggestion( oStepWiz )

    //-------------------------------------------------------
    // Cria a aba de encerramento
    //-------------------------------------------------------
    
    If ::lVldLogin
        ::MakeFinish( oStepWiz )
    EndIf
    
    //-------------------------------------------------------
    // Aplica um RGB especial aos steps do Wizard
    //-------------------------------------------------------
    //If !Empty( ::cStepColor )
        //oStepWiz:oUIStepWizard:oUiSteps:cBallColor := ::cStepColor
    //EndIf
    
    oStepWiz:Activate()
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeWelcomeOpt
Método para criação da aba de abertura do Wizard.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method MakeWelcomeOpt( oWizard ) class WizardOutPut
    Local oNewPag  

    //-----------------------------------------------------------------------
    // Pagina de Boas Vindas
    //-----------------------------------------------------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetStepDescription( STR0006 )   //"Boas vindas"
    oNewPag:SetConstruction( { | Panel | MakeWelcome( Panel, ::aWelcome ) } )
    oNewPag:SetNextAction( {|| .T.} )
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeLogin
Método para criação da aba de login.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method MakeLogin( oWizard ) class WizardOutPut
    Local oNewPag  
    Local lRet := .T.

    //------------------------
    // Pagina de Autenticação
    //------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetConstruction( {|Panel| MakeLogin( Panel, @self ) } )
    oNewPag:SetStepDescription( STR0007 )   //"Autenticação"
    oNewPag:SetNextAction( {|| FWMsgRun( NIL, { || lRet := VldLogin( @self )  }, Nil, STR0008 ), lRet })     //"Validando os acessos do usuário."        
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeSuggestion
Método para criação da aba de Sugestões .

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method MakeSuggestion( oWizard ) class WizardOutPut
    Local oNewPag  
    Local lRet := .T.

    //------------------------
    // Pagina de Sugestão
    //------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetStepDescription( STR0009 )   //"Autenticação"
    oNewPag:SetConstruction( {|Panel| Suggestion( Panel, @self ) } ) // ViewMsg | MakeLogin
    oNewPag:SetNextAction( {|| lRet := SendMsgOP( self,self:csuggestion ) }) //"Validando Msg de sugestão."
    oNewPag:SetPrevWhen({||.F.}) // Desabilita o botão se for cancelada a sugestão
    oNewPag:SetCancelAction({||Alert(STR0010), .T.})

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeFinish
Método para Finalização.

@param oWizard, object, objeto do Wizard onde a aba será criada.

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method MakeFinish( oWizard ) class WizardOutPut
    //----------------------------------
    // Pagina de Finalização
    //----------------------------------
    oNewPag := oWizard:AddStep()
    oNewPag:SetConstruction( { | Panel | OpFinish( Panel,  ::aFinish ) } )
    oNewPag:SetStepDescription( Self:cFinishStep )

Return 


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetWelcome
Atribui o texto que será apresentado na tela de abertura

@param aWelcome, array, vetor com os textos que serão apresentados na tela de abertura.
@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method SetWelcome( aWelcome ) class WizardOutPut
    ::aWelcome := aWelcome
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFinish

@param bFinish, codeblock, bloco com a função de gravação por empresa\filial.

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method SetFinish( bFinish ) class WizardOutPut
    ::bFinish := bFinish
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetStepColor
Define o RGB que deve ser utilizado para identificar os steps do Wizard

@param cColor, caracter, código RGB

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
//Method SetStepColor( cColor ) class WizardOutPut
    //::cStepColor := cColor
//Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetHeight
Ajusta a altura do Wizard.

@param nHeight, number, Altura do Wizard

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
// Method SetHeight( nHeight ) class WizardOutPut
//     ::nHeight := nHeight
//     ::lResized := .T.
// Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetWidth
Ajusta o comprimento do Wizard.

@param nWidth, number, Comprimento do Wizard

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
// Method SetWidth( nWidth ) class WizardOutPut
//     ::nWidth := nWidth
//     ::lResized := .T.
// Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o componente do Wizard.

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Method Destroy( ) class WizardOutPut
    ::cSource := ''
    ::cUser := ''
    ::cPsw := ''
    ::cFinishStep := ''
    ::cStepColor := ''
    ::nHeight := 0
    ::nWidth := 0
    ::aWelcome := {}
    ::lResized := .F.
    ::bFinish := NIL
    ::aFinish := {}               // Vetor com as mensagens de finalização 
    ::cSuggestion := ''           // Armazena as sugestões para melhoria do produto
    ::lVldLogin := .T.             //Variavel de controle para validar login
    ::lCancel := .F.

    FWFreeArray( ::aWelcome )
    
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeWelcome
Função que monta a tela de boas vindas

@param oPanel, object, Painel onde os componentes serão criados
@param aWelcome, array, Vetor com as mensagens que serão apresentadas na tela de boas-vindas

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------
Static Function MakeWelcome( oPanel, aWelcome )
    Local cWelcome := ''
    Local nI := 0
    Local oFont3
    Local oSay

    oFont3	    := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)	

    For nI := 1 to Len( aWelcome )
        cWelcome += aWelcome[ nI ] + CRLF
    Next

    oSay := TSay():New( 10, 10, {|| cWelcome }, oPanel, , oFont3, , , , .T., , , 340, 155, , , , , , .T. )    
    oSay:SetTextAlign( 3, 0 )
 Return
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeLogin
Função de montagem dos componentes da aba.

@param oPanel, object, Painel onde os componentes serão criado
@param @oSelf, object, objeto da classe GRRWizModel

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------
Static Function MakeLogin( oPanel, oSelf )
    Local oTGet1
    Local oTGet2
    Local nLine := 10
    Local nCol1 := 10
    Local nCol2 := 140

    oCHFont := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)	
    oCMFont := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)
    
    @ nLine, nCol1 SAY STR0011 OF oPanel PIXEL FONT oCHFont //"Usuário:"
    @ nLine + 10, nCol1 MSGET oTGet1 VAR oSelf:cUser SIZE 100, 10 OF oPanel Font oCMFont PIXEL 

    @ nLine, nCol2 SAY STR0012 OF oPanel PIXEL FONT oCHFont //"Senha:"
    @ nLine + 10, nCol2 MSGET oTGet2 VAR oSelf:cPsw SIZE 100, 10 OF oPanel Font oCMFont PIXEL PASSWORD

    oTGet1:SetFocus()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Suggestion
Função de montagem dos componentes da aba.

@param oPanel, object, Painel onde os componentes serão criado
@param @oSelf, object, objeto da classe GRRWizModel

@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------
Static Function Suggestion( oPanel, oSelf )
    
    Local cText := STR0013
    Local oTMultiget1
    Local cMotivo := ""
    Local nLine := 10
    Local nCol1 := 10
    Local lContinua := .F.
    oCHFont := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)  
    oCMFont := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)  
    oFont   := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)
    
    @ nLine, nCol1 SAY cText OF oPanel PIXEL FONT oCHFont //"Texto:"
    oTMultiget1 := tMultiget():new( nLine + 10, nCol1, {| u | if( pCount() > 0, cMotivo := u, oSelf:csuggestion := cMotivo ) }, ;
    oPanel, 273, 120, , , , , , .T. )

    lContinua := .T.
    
    lRet := .T.

Return lRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} VldLogin
Função que valida as informações de login e avalia se o dicionário está atualizado para
prosseguir com o processo.

@param @oSelf, object, objeto da classe GRRWizModel

@return boolean, informa se há erros de preenchimento na aba
@author  Danilo Santos
@since   25/04/2023
/*/
//-------------------------------------------------------------------------------------
Static Function VldLogin( oSelf )
    Local nVldLogin
    Local cMsg          := ""
    Local lValid        := .F.

    If Empty( oSelf:cUser )
        cMsg := STR0016    //"Informe o usuário"
    Else 
        nVldLogin := PswAdmin( Alltrim( oSelf:cUser ), Alltrim( oSelf:cPsw ) )
        if nVldLogin == 0
            lValid   := .T.
            oSelf:lVldLogin := .T.
        Else
            If nVldLogin == 1
                cMsg := STR0017     //"O usuário informado não é administrador do sistema."
            ElseIf nVldLogin == 2
                cMsg := STR0018     //"Dados para login incorretos."
            EndIf
            oSelf:lVldLogin := .F.
        EndIf
    ENDIF

    If !lValid
        ApMsgAlert( cMsg, STR0019 )
    EndIf

Return lValid

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendMsgOP
Função que faz a chamada para o envio da msg de sugestões ao RabbitMQ pelo smartlink  

@param oSelf, object, Painel onde os componentes serão criados

@author  Danilo Santos
@since   25/04/2023
/*/
//--------------------------------------------------------------------------------------
Static function SendMsgOP(oSelf ,csuggestion)  //oSelf,
 
    Local lRet := .T.
    Default csuggestion := ''
    If oSelf:lVldLogin
        lRet := SendOptOut(csuggestion,oSelf)     
    Endif
return (lRet)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendOptOut
Função que faz o envio das mensagens para o job do smartlink

@author  Danilo Santos
@since   25/04/2023
/*/
//--------------------------------------------------------------------------------------
Static Function SendOptOut( csuggestion, oSelf )
    Local oSmartLink as object
    Local cMessage as character
    Local lSuccess as logical
    Local lRet := .F.
    Local cCnpj := ""
    Local cError := STR0020
    Default csuggestion := ""
    cCnpj := RetCnpj()

    oSmartLink := FwTotvsLinkClient():New()    

    cMessage :=	'{' +;
                    '"cnpj": ' + '"'+ cCnpj  +'",' +;
                    '"origem": ' + '"'+ GetClientIP()  +'",'  +;
                    '"cUserid": ' + '"000001",'+;
                    '"cUserName": ' + '"'+ Alltrim(oSelf:cUser) +'",' +;
                    '"DateTime": ' + '"'+ dtoc(date()) + "T" + time()  +'",' +;
                    '"xmotivo": ' + '"'+ csuggestion +'"' +;
                '}'
    
    Conout(cMessage)
    lSuccess := oSmartLink:Send("OptOutMsg", cMessage)

    If lSuccess
        lRet := .T.
    else
        ApMsgAlert( STR0021 + CRLF + cError, STR0022 )
    Endif
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} OpFinish
Função que monta a tela de boas vindas

@param oPanel, object, Painel onde os componentes serão criados
@param aWelcome, array, Vetor com as mensagens que serão apresentadas na tela de boas-vindas

@author  Danilo Santos
@since   25/04/2023
/*/
//--------------------------------------------------------------------------------------
Static Function OpFinish( oPanel, aFinish)
    Local cFinish := ''
    Local nI := 0
    Local oFont3
    Local oSay
    Local lRet:= .T.

    oFont3	    := TFont():New("Arial",,-12,,.F.,,,,,,.F.,.F.)	
    For nI := 1 to Len( aFinish )

        cFinish += aFinish[ nI ] + CRLF
    Next   
    oSay := TSay():New( 10, 10, {|| cFinish }, oPanel, , oFont3, , , , .T., , , 340, 155, , , , , , .T. )    
    oSay:SetTextAlign( 3, 0 )  

 Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetCnpj
Função que retorna os cnpj's da tabela de empresas 

@param oPanel, object, Painel onde os componentes serão criados
@param aWelcome, array, Vetor com as mensagens que serão apresentadas na tela de boas-vindas

@author  Danilo Santos
@since   25/04/2023
/*/
//--------------------------------------------------------------------------------------
Static Function RetCnpj()
//Local lPrimeiro := .T.
Local cAliasEmp := ''
Local cCnpj := ""
    
    cQuery := "SELECT * "
    cQuery += "FROM SYS_COMPANY "
    

    cAliasEmp	:= GetNextAlias()
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEmp,.T.,.T.)
    DbSelectArea(cAliasEmp)
    (cAliasEmp)->(DbGoTop())
    While (cAliasEmp)->(!EOF())
        If !Empty((cAliasEmp)->M0_CGC)
            cCnpj += Alltrim((cAliasEmp)->M0_CGC) +  "," 
        Endif
        (cAliasEmp)->(dbSkip())

    EndDo

    (cAliasEmp)->(dbCloseArea())  
    cCnpj := Substr(cCnpj,1,Len(cCnpj) -1)
Return cCnpj
