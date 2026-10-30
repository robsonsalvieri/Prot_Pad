#Include "TOTVS.ch"
#Include "msobject.ch"
#Include "POSCSS.CH"
#Include "Telaterminal.CH"

/*/{Protheus.doc} ListTerminalsPaymentHub
    Classe utilizada na selecao do Terminal que será utilizado na transação
    @author JMM
    @since 30/07/2020
    @version 1.0
/*/

Class ListTerminalsPaymentHub

Data oScreen
Data aTerminals
Data aTerminal
Data nOrigem
Data lMantemTerminal
Data lCheck
Data aBranches
Data lYouCanClose

Method New(nOrigem) Constructor
Method ShowScreen()
Method EndScreen()
Method YouCanClose()
Method RetSelectdTerminal()
Method ValidSelectTerm()
Method TerminalSelectd()
Method GetTerminals()

Method Screen()
Method ListTeminals()
Method SetSelectdTerminal()

EndClass

/*/{Protheus.doc} New
    Metodo construtor da classe
    @author JMM
    @since 30/07/2020
    @version  12.1.25
    @param nOrigem, numerico, de onte esta sendo chamado -> 1 = Venda | 2 = Cadastro de estação
    @param cCodeComp, Caracter, Codigo da empresa
    @param cTenant, Caracter, Empresa cadastrada no RAC
    @param cUserName, Caracter, Usuario RAC
    @param cPassword, Caracter, Senha RAC
    @param cClientId, Caracter, Identificador do produto no RAC
    @param cClientSecret, Caracter, Senha do identificador
/*/

Method New(nOrigem,cCodeComp,cTenant,cUserName,cPassword,cClientId,cClientSecret) Class ListTerminalsPaymentHub
        
    cCodeComp      := AllTrim(cCodeComp)
    cTenant        := AllTrim(cTenant)
    cUserName      := AllTrim(cUserName)
    cPassword      := AllTrim(cPassword)
    cClientId      := AllTrim(cClientId)
    cClientSecret  := AllTrim(cClientSecret)

    Self:nOrigem        := nOrigem
    Self:lYouCanClose   := .T.
    Self:aTerminals     := Self:ListTeminals(cCodeComp,cTenant,cUserName,cPassword,cClientId,cClientSecret)
    Self:aTerminal      := {}
    Self:aBranches      := {}
    Self:lCheck         := .F.
   

Return Self

/*/{Protheus.doc} ShowScreen
    Metodo responsavel pela exibição da tela de terminais 
    @author JMM
    @since 30/07/2020
    @version  12.1.25
    @param lObrigat, Logico, Indica se a tela pode ser fechada ou não pelo "X"
/*/

Method ShowScreen(lObrigat) Class ListTerminalsPaymentHub
    Default lObrigat 	:= .F.

    Self:lYouCanClose := !lObrigat
    Self:Screen()
    Self:oScreen:Activate(Nil,Nil,Nil,.T.,{|| Self:YouCanClose()}) //Abre a tela centralizada
Return

/*/{Protheus.doc} EndScreen
    Metodo responsavel pelo enceramento da tela de terminais 
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/

Method EndScreen() Class ListTerminalsPaymentHub
    Self:lYouCanClose := .T.
    Self:oScreen:End()
Return

/*/{Protheus.doc} EndScreen
    Metodo responsavel por indica se a tela pode ou não ser fechada pelo "X"
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/

Method YouCanClose() Class ListTerminalsPaymentHub
Return Self:lYouCanClose

/*/{Protheus.doc} Screen
    Metodo responsavel por montar internamente a interface de tela da lista de terminais 
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/

Method Screen() Class ListTerminalsPaymentHub
    Local oTCBrowse := NIL 
    Local oButtonOk := NIL 
    Local oCheckBox := NIL 
    Local nX        := 0   
    Local bSetGet   := { |x| If( PCount() == 0, Self:lCheck, Self:lCheck := x ) } 

    Self:oScreen := TDialog():New(000,000,000,000,STR0001,,,,,0,16777215,,,.T.,,,,450,260) // "Lista de terminais"                                                 
    oTCBrowse := TCBrowse():New( 005 , 005, 220, 100,, {"    ",STR0002,STR0003},{40,100,20}, Self:oScreen,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) // "Terminal" // " Impressão no terminal?"
    
    For nX := 1 To Len(Self:aTerminals) 
        aAdd(Self:aBranches, {.F.,Self:aTerminals[nX][01], Self:aTerminals[nX][02]} )
    Next
    If Empty(Self:aBranches)
        aAdd(Self:aBranches, {.F.,"", "Não"} )
    EndIf

    oTCBrowse:SetArray( Self:aBranches )
    oTCBrowse:bLine := {||	{	If( Self:aBranches[oTCBrowse:nAt][1], LoadBitmap( GetResources(), "LBOK" ), LoadBitmap( GetResources(), "LBNO" ) ),;
									Self:aBranches[oTCBrowse:nAt][2],;
									Self:aBranches[oTCBrowse:nAt][3]}}

    oTCBrowse:bLDblClick := {|| If(Self:ValidSelectTerm(Self:aBranches, oTCBrowse:nAt), oTCBrowse:aArray[oTCBrowse:nAt][1] := !oTCBrowse:aArray[oTCBrowse:nAt][1], ) , oTCBrowse:Refresh(),}	

    oButtonOk := TButton():New( 110, 160,STR0004 ,Self:oScreen,{|| Iif(Self:TerminalSelectd(),Self:EndScreen(),Nil)},60,15,,,,.T.)  // "Confirmar"
    oCheckBox := TCheckBox():New(115,05,STR0005,bSetGet,Self:oScreen,150,210,,,,,,,,.T.,,,) // 'Manter terminal selecionado para as próximas operações.'

    If Self:nOrigem <> 1
        oCheckBox:Hide()
    EndIf 

    oButtonOk:SetCSS( POSCSS (GetClassName(oButtonOk), CSS_BTN_FOCAL  ))

Return

/*/{Protheus.doc} ListTeminals
    Metodo responsavel por retornar os Terminais disponiveis e se fazem impressao
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/

Method ListTeminals(cCodeComp,cTenant,cUserName,cPassword,cClientId,cClientSecret) Class ListTerminalsPaymentHub
Local aTerminals := {}
Local oPayment      := PaymentHub():New(cCodeComp,"BRL",Nil,Nil,cTenant,cUserName,cPassword,cClientId,cClientSecret)
Local oResult       := Nil 
Local cHasPrinter   := "Não"
Local nX            := 0

aRetorno := oPayment:ListTerminalsTransaction()
If aRetorno[1]
    oResult := oPayment:ResultListTerminalsTransaction()

    For nX := 1 To Len( oResult["posPeds"] )
        If oResult["posPeds"][nX]:GetJsonText("hasPrinter")  == ".T." .OR. UPPER( oResult["posPeds"][nX]:GetJsonText("hasPrinter") )  == "TRUE"
            cHasPrinter := "Sim"
        EndIf

        AADD(aTerminals, {oResult["posPeds"][nX]:GetJsonText("id"), cHasPrinter } )
    Next nX
EndIf

Return aTerminals

/*/{Protheus.doc} TerminalSelectd
    Metodo responsavel por retornar o Terminal selecionado
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/
Method TerminalSelectd() Class ListTerminalsPaymentHub
    Local aSelectdTeminal := ""
    Local nX := 0               

    For nX := 1 To Len(Self:aBranches)
        If Self:aBranches[nX][01]
            aSelectdTeminal := { Self:aBranches[nX][02], If(Self:aBranches[nX][03] == STR0006, .T., .F. ), Self:lCheck } // Sim
            Exit
        EndIf
    Next

    Self:SetSelectdTerminal(aSelectdTeminal)

return !Empty(aSelectdTeminal)

/*/{Protheus.doc} GetTerminals
    Metodo responsavel por retornar o array de todos os terminais ativos.
    @author Alberto Deviciente
    @since 06/08/2020
    @version 12.1.25
/*/
Method GetTerminals() Class ListTerminalsPaymentHub
return Self:aTerminals

/*/{Protheus.doc} ValidSelectTerm
    Metodo responsavel por validar a seleção de terminais
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/
Method ValidSelectTerm(aTerminals, nPosicao) Class ListTerminalsPaymentHub
    Local lRet := .T.   
    Local nX := 0       

    For nX := 1 To Len(aTerminals)
        If aTerminals[nX][01] .AND. nPosicao <> nX
            lRet := .F.
            Exit
        EndIf
    Next

return lRet

/*/{Protheus.doc} SetSelectdTerminal
    Metodo responsavel por atribuir valor ao atributo aTerminal
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/
Method SetSelectdTerminal(aSelectdTeminal) Class ListTerminalsPaymentHub
    Self:aTerminal := aSelectdTeminal
return

/*/{Protheus.doc} RetSelectdTerminal
    Metodo responsavel por retornar o valor do atributo aTerminal
    @author JMM
    @since 30/07/2020
    @version 12.1.25
/*/
Method RetSelectdTerminal() Class ListTerminalsPaymentHub
return Self:aTerminal