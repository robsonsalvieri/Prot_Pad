#INCLUDE "PROTHEUS.CH"
#INCLUDE "gpem947.ch"

/*/{Protheus.doc} GPEM947
Função de menu para abrir o .app Residuos do Credito do Trabalhador
@author Maria Luisa de Souza Arcanjo Bastos
@since 06/02/2026
/*/
Function GPEM947()
    If Gpm947PreValid()
        FwCallApp("GPEM947") //Abre o app Residuos do Credito do Trabalhador
    EndIf
Return


/*/{Protheus.doc} Gpm947PreValid
Função de pré-validação para abertura da rotina de Resíduos do Crédito do Trabalhador
@author Maria Luísa de Souza Arcanjo Bastos
@since 06/02/2026
/*/
Static Function Gpm947PreValid()

    Local cAcessVFut := &("{ || " + ChkRH("GPEA110", "SRK","2") + "}")
    Local cHtml      := ""
    Local lAcessoOk  := .F.
    Local lCpoExists := cPaisLoc == "BRA" .And. RCK->(ColumnPos("RCK_MAIL") > 0) 
    Local lMppOK     := AmIOnRestEnv() //Verifica se está com a port MPP habilitada
    Local lMvOk      := .F.
    Local lTudoOk    := .F.
    Local lVersaoOK  := (GetRPORelease() >= "12.1.2310")
    Local oModal	 := Nil
    Local oContainer := Nil

    lMvOk := !Empty(SuperGetMv('MV_RELSERV', .F., "")) .And. ;
             !Empty(SuperGetMv('MV_RELPSW', .F., "")) .And. ;
             !Empty(SuperGetMv('MV_RELACNT',  .F., ""))

    lAcessoOk  := Eval(cAcessVFut) 
    lTudoOk    := (lAcessoOk .And. lMppOK .And. lMVOk .And. lCpoExists .And. lVersaoOK)

    If !lTudoOk

        oFontSub := TFont():New('Arial',,-14,.T.)
        oFontText := TFont():New('Arial',,-14,.T.)
        oFontTitle := TFont():New('Arial',,-18,.T.)
        oFontTitle:Bold := .T.
        oFontButtons := TFont():New('Arial',,-16,.T.)
        oFontButtons:Underline := .T.
        oFontButtons:Bold := .T.
        oModal := FWDialogModal():New()
        oModal:SetEscClose(.T.)
        oModal:setSize(200, 450)
        oModal:createDialog()

        oModal:addCloseButton(Nil, STR0001) //Fechar
        oFont := TFont():New('Courier new',,-18,.T.)

        cHtml := fMontaHtml(lMppOK, lMVOk, lCpoExists, lVersaoOK, lAcessoOk)

        oSay := TSay():New(10,10,{|| cHtml },,,oFontSub,,,,.T.,,,440,160,,,,,,.T.)

        oBtn1 := THButton():New( 177, 15, STR0002, oContainer, { || ShellExecute( "Open", "https://tdn.totvs.com/x/jIUoI", "", "C:\", 1 ) }, 160, 020, oFontButtons, STR0002 ) //Como configurar a Porta Multiprotocolo?
        oBtn2 := THButton():New( 190, -17, STR0003, oContainer, { || ShellExecute( "Open", "https://tdn.totvs.com/pages/viewpage.action?pageId=1041790094", "", "C:\", 1 ) }, 250, 020, oFontButtons, STR0003 ) //"Documentação sobre o funcionamento da rotina"       
        oBtn2:SetCss("QPushButton{ color: #21a4c4; }")

        oModal:Activate()

    EndIf
Return lTudoOk

/*/{Protheus.doc} fMontaHtml
Monta texto para exibição dos pre requisitos
@author Maria Luisa de Souza Arcanjo Bastos
@since 13/09/2024
/*/
Static Function fMontaHtml(lMppOK, lMVOk, lCpoExists, lVersaoOK, lAcessoOk)
    Local cHtml := ""
    Local cOk   := "color: green;"
    Local cFail := "color: red;"

    cHtml += '<h1 style="color: #21a4c4; text-align: center; margin-top: 30; margin-bottom: 40px;">'+STR0004+'</h1>' //Resíduo do Crédito do Trabalhador
    cHtml += '<p style="color: #4a5c60; margin-left: 20px; margin-bottom: 10px;">'+STR0005+'</p>' //Para utilizar essa nova funcionalidade, existem alguns pré-requisitos que seu ambiente precisa atender, conforme abaixo:
    cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>1.</b> '+STR0007+' <b style="'+If(lMppOK, cOk, cFail)+'">'+If(lMppOK, STR0006, STR0008)+'</b></p>'         //Possuir a Porta Multiprotocolo habilitada ### OK ## Porta Multiprotocolo desabilitada
    cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>2.</b> '+STR0009+' <b style="'+If(lCpoExists, cOk, cFail)+'">'+If(lCpoExists, STR0006, STR0010)+'</b></p>' //Dicionário atualizado com o novo campo da tabela RCK (RCK_MAIL) ### OK ### Dicionário desatualizado    
    cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>3.</b> '+STR0011+' <b style="'+If(lMVOk, cOk, cFail)+'">'+If(lMVOk, STR0006, STR0012)+'</b></p>'   //Possuir parâmetros de envio de e-mail configurados ### OK ### Conteúdo dos parâmetros incorretos
    cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>4.</b> '+STR0013+' <b style="'+If(lAcessoOk, cOk, cFail)+'">'+If(lAcessoOk, STR0006, STR0014)+'</b></p>' //Possuir permissão de acesso à rotina ### OK ### Sem permissão de acesso à rotina
    cHtml += '<p style="color: #4a5c60; margin-left: 30px;"><b>5.</b> '+STR0015+' <b style="'+If(lVersaoOK, cOk, cFail)+'">'+If(lVersaoOK, STR0006, STR0016)+'</b></p>' //Estar com o ambiente na versão do RPO igual a 12.1.2310 ou superior ### OK ### Versão do RPO incompatível

Return cHtml



