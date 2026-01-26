#include "TOTVS.CH"
#include "msobject.ch"
#include "fileio.ch" 
#INCLUDE "AUTODEF.CH"
#include "PagamentosDigitais.ch"

Static lApTPD   := .F.         //Define se pagamento foi aprovado ou não no QrCode apresentado no PinPad. 
Static oTef20   := STBGetTEF() //Tef TOTVS PDV 
Static lEndQr   := .F.         //Retira QrCode do PinPad 

User function xpgtodig()
RPCSETENV("99", "01",,,"FRT")  
oPH := PaymentHub():New("00000001","BRL","","001","protheusvarejo","geratoken","@geratoken!TOTVS2020","totvs_pagamento_digital_protheus_ro","39f56c0d-1a0d-48e9-94de-eb32f4e8877c",,,,"1")
oPD := PagamentosDigitais():New(oPH,"123456789",100.50,,,"PX")
oPD:FlowForDigitalPayments()

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PagamentosDigitais
Classe responsavel por toda a interface e controle do pagamento digital

@type       Class
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@return
/*/
//-------------------------------------------------------------------------------------

Class PagamentosDigitais

Method New()          CONSTRUCTOR

// -- Interface de meio de pagamentos digitais
Method FlowForDigitalPayments()
Method AddsPaymentmethods()
Method ExchangePanels()
Method PaymentMethodSelected()
Method DirectoryControl()
Method EndScreen()

Method Paymentflow()
Method PaymentInterface()
Method GetStatusTransaction()
Method ConfirmPayment()

// -- Dados para o pagamento
Data oPaymentHub
Data oLJCComPaymentHub
Data cIdTransct
Data ctransactionId
Data nAmount
Data cFormPayment
Data cIdPagto               //Id de identificação do pagamento na tela do Venda Assistida

// -- Dados do pagamento
Data oResult

// -- Interface
Data oInterface             // -- Janela Principal
Data aPanels                // -- Paineis internos
Data oTFont
Data oNextButton
Data oPreviousButton

Data oReturnButton
Data oCancelButton
Data oReturnPrintQr

Data nTamHPnl               // -- Tamanho Horizontal do Painel (Ponto)
Data nTamVPnl               // -- Tamanho Vertical do Painel (Ponto)

// -- Controles estaticos
Data nCurrentPage
Data nCurrentBox 
Data nNumTotalBox    
Data nVerticalBoxPosition
Data nHorizontalBoxPosition
Data nQtyOfPages
Data lNavButtons
Data oTimer
Data lClosed  
Data cDirBase
Data cDirTransec
Data lUniquewallet

Data nGlobalNumberThread
Data cNameGlobalStatus
Data cNomeGlobalNumberThread

// -- Configuração da Janela
Data nMaxNumOfHorizontalBox
Data nMaxNumOfVerticalBox
Data nMaxNumOfBoxPerpage
Data nMargin

// -- Configurações das caixas
Data nBoxWidth          
Data nBoxHeight
Data nPartitionBetweenBox 

// -- Dados do TEF para enviar Qr-Code do PIX para o Pin-Pad
Data cQrCode 

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da Classe PagamentosDigitais

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param oPaymentHub, Objeto, Objeto para comunicação com as API do PaymentHub
@param cIdTransct, Caracter, Id da transação
@param nAmount, Numerico, Valor da transação
@param cIdPagto, Caracter, Sequencial da transção (Usado para o Venda Assistida)
@param oCfgPayHub, Objeto, Objeto de configuração do paymenthub (utilizado no cancelamento)
@param cFormPayment, Caracter, Forma de pagamento utilizada

@return PagamentosDigitais, Objeto, Objeto construido.
/*/
//-------------------------------------------------------------------------------------

Method New(oPaymentHub,cIdTransct,nAmount,cIdPagto,oCfgPayHub,cFormPayment) Class PagamentosDigitais

    Default cIdPagto             := "" //Id de identificação do pagamento na tela do Venda Assistida
    Default cFormPayment         := ""

    // -- Configuração da janela
    Self:nMaxNumOfHorizontalBox  := 3   // -- Caixas horizontais 
    Self:nMaxNumOfVerticalBox    := 2   // -- Caixas Verticais   
    Self:nMaxNumOfBoxPerpage     := ( Self:nMaxNumOfHorizontalBox * Self:nMaxNumOfVerticalBox ) // -- Numero maximo de caixa por pagina
                                                
    // -- Configuração das caixas
    Self:nBoxWidth               := 100 // -- Largura de cada caixa
    Self:nBoxHeight              := 80  // -- Altura de cada caixa
    Self:nPartitionBetweenBox    := 10  // -- Espaço entre caixa
    Self:nMargin                 := ( Self:nPartitionBetweenBox * 2 ) // -- Para uma melhor vizualização a Margem superior e lateral esqueda deve ser o dobro do espaço entre as caixas

    Self:aPanels                 := {}
    Self:nCurrentPage            := 1   
    Self:nNumTotalBox            := 0
    Self:lNavButtons             := .F.
    Self:oTFont                  := TFont():New(, , -16, .T.)

    Self:cIdTransct              := cIdTransct
    Self:nAmount                 := nAmount
    Self:cFormPayment            := cFormPayment
    Self:cIdPagto                := cIdPagto
    Self:lClosed                 := .F.
    
    Self:nGlobalNumberThread     := 0

    // -- Variaveis de "SERVER" que serão criadas uso de mult-thread. deve obrigatoriamente ser concatenada com o ID da Thread instaciadora
    Self:cNameGlobalStatus       := "LJG_STATUSTRANSACTION" + cValTochar(ThreadId()) 
    Self:cNomeGlobalNumberThread := "LJG_NUMBERTHREAD"      + cValTochar(ThreadId())

    Self:cDirBase                := "\phub"
    Self:cDirTransec             := "\qrcode"

    Self:oPaymentHub             := oPaymentHub
    Self:cQrCode                 := ""          //Qr-Code para envio ao Pin-Pad 

    If !Empty(oCfgPayHub)
        Self:oLJCComPaymentHub      := LJCComPaymentHub():New(oCfgPayHub) // -- Cria uma nova instancia de comunicação para cancelamento se necessario.
    EndIf 

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PagamentosDigitais
Metodo responsavel por todo o fluxo de pagamento digital, controla a operação do começo ao fim.

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@return aResult, Array, {
    "#Logico#,Indicativo de resultado do metodo",
    {
        "#Array#, Mensagem de erro caso tenha ocorrido"
    }  
}
/*/
//-------------------------------------------------------------------------------------

Method FlowForDigitalPayments(oTransacao) Class PagamentosDigitais
    Local oMethodsAvaliables := Nil // -- Retorno dos metodos disponiveis
    Local aMethodsAvaliables := {}
    Local aResult            := {.T.,{""}}  // -- Retorno
    Local oFontBold          := TFont():New(, , -16, .T., .T.)
    Local cImgArq            := ""
    Local cImgDecode         := ""
    Local nImgHandle         := 0
    Local cMsgErrArq         := ""
    Local cImg64Logo         := "" //Codigo da imagem do LOGO da carteia digital em base 64
    
    Local nx                 := 0   // -- Contador
    Local ni                 := 0   // -- Contador
    Local nQtyMethods        := 0   // -- quantidade de metodos disponiveis 
    Local nQtyAux            := 0   // -- Auxiliar para calculo de paginas

    Local nBtnWidth          := 58  // -- Tamanho horizontal do botÃ£o de navegaÃ§Ã£o
    Local nBtnHeight         := 20  // -- Tamanho vertical do botÃ£o de navegaÃ§Ã£o
    
    Local nTamHDlg           := 0   // -- Tamanho horizontal da Dialog (Pixel)  
    Local nTamVDlg           := 0   // -- Tamanho Vertical da Dialog (Pixel)
    Local oPanelVlr          := Nil // -- Painel para exibição do valor da transação

    Local cAmbiente         := Nil
    Local aDadosCli         := {}  // Dados do cliente da transaçao
    Local cInicioT          := ""
    Local cFinalT           := ""

    Default oTransacao      := JsonObject():New()

    Iif( ValType(oTransacao:aDadosCli) == "A", aDadosCli := oTransacao:aDadosCli, aDadosCli := {"","","","","","","",""} ) 

    cInicioT    := Time()
    LjGrvLog("TPD"," FlowForDigitalPayments - Inicio: " + cInicioT,,,.T. ) 
        
    If Self:DirectoryControl() // -- Cria diretorios 
        aResult := Self:oPaymentHub:MethodsAvaliables()

        If AllTrim( Self:oPaymentHub:cEnvironment ) == "1" 
            cAmbiente := "shipaypagador" // Homologação
        Else
            cAmbiente := "PIX" // Produção
        EndIf

        If aResult[1]

            oMethodsAvaliables := Self:oPaymentHub:ResultMethodsAvaliables()
            LjGrvLog("TPD"," FlowForDigitalPayments - oMethodsAvaliables", oMethodsAvaliables,,.T.)

            aAux := oMethodsAvaliables["paymentMethods"]

            Self:nTamHPnl := ((Self:nBoxWidth + Self:nPartitionBetweenBox) * Self:nMaxNumOfHorizontalBox )                            
            nTamHDlg := (Self:nTamHPnl * 2 )  + Self:nMargin 
            
            Self:nTamVPnl := Self:nMaxNumOfVerticalBox  * (Self:nBoxHeight + Self:nPartitionBetweenBox)
            nTamVDlg := ((Self:nTamVPnl * 2 ) + Self:nMargin ) + 40   // -- EspaÃ§o para os botoes de Proxima pagina e de pagina anterior

            If AllTrim(Upper(Self:cFormPayment)) == "PX"

                LjGrvLog("TPD"," FlowForDigitalPayments - Ambiente ", Self:oPaymentHub:cEnvironment,,.T.)

                nPos := aScan(aAux, { |x| Upper(x["code"]) == Upper(cAmbiente) })
                If nPos <> 0
                    Self:lUniquewallet := .T.
                    aResult := self:Paymentflow(aAux[nPos]["code"], aAux[nPos]["name"], aDadosCli, nTamVDlg, nTamHDlg)
                Else
                    aResult := {.F.,{STR0001}} // "Metodo de pagamento PIX não foi encontrado, verifique se a opção se encontra ativa no portal de configuração!"
                    LjGrvLog("TPD"," FlowForDigitalPayments - Metodo de pagamento PIX não foi encontrado, verifique se a opção se encontra ativa no portal de configuração!",,,.T. )
                EndIf 
            EndIf
            
            For nX := 1 To Len(aAux)
                aADD(aMethodsAvaliables,aAux[nX]) 
            Next
              
            nQtyMethods := Len(aMethodsAvaliables)
            LjGrvLog("TPD"," FlowForDigitalPayments - Quantidade de Metodos de Pagamnts ", nQtyMethods,,.T.)

            If nQtyMethods > Self:nMaxNumOfBoxPerpage
                Self:lNavButtons := .T. 
            Endif

            Self:nQtyOfPages := Ceiling(nQtyMethods / Self:nMaxNumOfBoxPerpage) 

            If nQtyMethods >= 1 

                For nX := 1 to Self:nQtyOfPages  //Quantidade de paginas necessarias
                    
                    Self:nHorizontalBoxPosition := 0
                    Self:nVerticalBoxPosition   := 0
                    Self:nCurrentBox            := 0

                    
                    If nQtyMethods >= Self:nMaxNumOfBoxPerpage
                        nQtyAux := Self:nMaxNumOfBoxPerpage
                    Else 
                        nQtyAux :=  nQtyMethods
                    EndIf 
                    
                    nQtyMethods -= nQtyAux
                    
                    If AllTrim(Upper(Self:cFormPayment)) <> "PX"    
                        If Self:oInterface == Nil //Cria a Dialog caso nao tem ainda iniciado a sua criação
                            Self:oInterface := TDialog():New(000,000,nTamVDlg,nTamHDlg,STR0002,,,,,CLR_BLACK,/*CLR_WHITE*/,,,.T.) // "Carteiras digitais :D"
                        EndIf
                        AAdd(Self:aPanels,tPanel():New(Self:nMargin * 0.50,Self:nMargin * 0.50,"",Self:oInterface,,.T.,,CLR_BLACK,CLR_WHITE,Self:nTamHPnl,Self:nTamVPnl))
                    EndIf    
                    
                    If nX <> 1
                        Self:aPanels[nX]:Disable()
                        Self:aPanels[nX]:lVisible := .F.
                    EndIf   

                    For nI := 1 to nQtyAux //Formas na pagina

                        If nX > 1
                            nSumnI := nI + Self:nNumTotalBox
                        Else
                            nSumnI := nI
                        Endif 

                        aMethodsAvaliables[nSumnI]["logo"] := STRTOKARR(aMethodsAvaliables[nSumnI]["logo"],",")
                        cImg64Logo  := aMethodsAvaliables[nSumnI]["logo"][2]
                        cImgArq     := Self:cDirBase + "\" + aMethodsAvaliables[nSumnI]["code"]  + ".png"

                        LjGrvLog("PagamentosDigitais","Imagem do LOGO em base 64 retornada pela API",cImg64Logo,,.T.)
                        
                        cImgDecode  := Decode64(cImg64Logo)
                        nImgHandle  := FCreate(cImgArq)
                        
                        If nImgHandle == -1
                            cMsgErrArq := STR0003 + cImgArq + "). Ferror: " + Str(Ferror()) // "Erro ao tentar criar o arquivo ("
                            LjGrvLog("PagamentosDigitais",cMsgErrArq,,,.T.) 
                            ConOut(cMsgErrArq)
                            MsgAlert(cMsgErrArq)
                        Else
                            FWrite(nImgHandle, cImgDecode)
                            FClose(nImgHandle)
                        EndIf
                        
                        If AllTrim(Upper(Self:cFormPayment)) <> "PX"    
                            aResult := Self:AddsPaymentmethods(Self:aPanels[nX],cImgArq,aMethodsAvaliables[nSumnI]["name"],aMethodsAvaliables[nSumnI]["code"]) 
                        EndIf
                        
                        If !aResult[1]
                            EXIT 
                        Endif 

                        Self:nNumTotalBox++
                    Next

                    If !aResult[1]
                        EXIT 
                    Endif

                Next 

            Else
                If !Self:lUniqueWallet
                    aResult := {.F.,{STR0004}}  // "Não foi possivel obter metodos de pagamentos disponiveis"
                    LjGrvLog("TPD"," FlowForDigitalPayments - Não foi possivel obter metodos de pagamentos disponiveis ", Self:lUniqueWallet,,.T.)
                EndIf
            EndIf 

            If aResult[1] 
                
                oPanelVlr := tPanel():New(Self:nTamVPnl + (Self:nMargin * 0.50), 003, "", Self:oInterface,,.F.,,CLR_BLACK,,140 ,nBtnHeight)
                @00, 00 TO nBtnHeight, 140 LABEL "" OF oPanelVlr PIXEL
                TSay():New(005,005,{||STR0005},oPanelVlr,,oFontBold,,,,.T.,CLR_BLACK,CLR_HRED,50,20) //"Valor:"
                TSay():New(005,030,{||AllTrim(Transform(Self:nAmount,PesqPict("SL1","L1_VLRTOT")))},oPanelVlr,,oFontBold,,,,.T.,CLR_HRED,CLR_HGRAY,50,20)
                
                If !Empty(Self:cIdPagto)
                    TSay():New(005,110,{||"ID:"},oPanelVlr,,oFontBold,,,,.T.,CLR_BLACK,,50,20) //"ID:"
                    TSay():New(005,125,{||Self:cIdPagto},oPanelVlr,,oFontBold,,,,.T.,CLR_HRED,,50,20)
                EndIf

                If Self:lNavButtons
                    Self:oNextButton         := TButton():New( Self:nTamVPnl + (Self:nMargin * 0.50), (Self:nTamHPnl + Self:nMargin * 0.50) - nBtnWidth, STR0006,Self:oInterface,{||Self:exchangePanels(+1)}, nBtnWidth,nBtnHeight,,,.F.,.T.,.T.,,.F.,,,.F. ) // "Proxima pagina"
                    Self:oPreviousButton     := TButton():New( Self:nTamVPnl + (Self:nMargin * 0.50), (Self:nTamHPnl + Self:nMargin * 0.50) - ((nBtnWidth * 2) + (Self:nPartitionBetweenBox * 0.20) ) , STR0007,Self:oInterface,{||Self:exchangePanels(-1)}, nBtnWidth,nBtnHeight,,,.F.,.T.,.T.,,.F.,,,.F. )  // "Pagina Anterior"
                    Self:oPreviousButton:Disable()
                EndIf  

                Self:oInterface:Activate(,,,.T.,{|| Self:EndScreen()},,{|| IIF(SuperGetMV("MV_LJQRCPP",,"0")=="1".And. Self:cFormPayment == "PX",STBEnvAutPinPad(Self:cQrCode,self:oPaymentHub),.F.)}) // Parâmetro que define se o usuario deseja enviar o qr code direto ao pinpad (1=habilitado ,0=desabilitado )
            EndIf
        Else    
            aResult := {.F.,{STR0004}} // "Não foi possivel obter metodos de pagamentos disponiveis"
            LjGrvLog("TPD"," FlowForDigitalPayments - Não foi possivel obter metodos de pagamentos disponiveis", aResult[1],,.T. )
        EndIf 
    Else
        aResult := {.F.,{STR0008}} // "Não foi possivel criar/checar os diretorios"
        LjGrvLog("TPD"," FlowForDigitalPayments - Não foi possivel criar/checar os diretorios",,,.T.) 
    EndIf 

    cFinalT := Time()
    LjGrvLog("TPD"," FlowForDigitalPayments - Final: "+ cFinalT + " Tempo total de execução do processo de pagamentos digitais: "+ ElapTime(cInicioT,cFinalT),,,.T.)
Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AddsPaymentmethods
Sub-Metodo de FlowForDigitalPayments, responsavel por criar os paineis com as carteiras disponiveis para pagamento

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param oPanel, Objeto, Objeto com interface do painel atual
@param cDirImg, Caracter, diretorio da imagem que sera exibida no painel
@param cName, Caracter, Nome do metodo de pagamento que será exibido no painel
@param cId, Caracter, ID do metodo de pagamento (Ex.: "mercadopago","ame",etc.. ), recebido do metodo de listar pagamentos (MethodsAvaliables)

@return aResult, Array, {
    "#Logico#,Indicativo de resultado do metodo",
    {
        "#Array#, Mensagem de erro caso tenha ocorrigo"
    }  
}
/*/
//-------------------------------------------------------------------------------------

Method AddsPaymentmethods(oPanel,cDirImg,cName,cId) Class PagamentosDigitais
    Local lQuebraLinha  := .F.
    Local nAux          := 0
    Local aResult       := {.T.,{""}}
    Local oBtnTpPD      := Nil 
       
    Self:nCurrentBox ++
    nAux :=  (( Self:nCurrentBox -1 ) / Self:nMaxNumOfHorizontalBox)
    
    lQuebraLinha := nAux - int(nAux) = 0
    
    If lQuebraLinha 
        If  nAux <> 0
            Self:nHorizontalBoxPosition := 0
            Self:nVerticalBoxPosition   :=  (Self:nVerticalBoxPosition + Self:nBoxHeight ) + Self:nPartitionBetweenBox 
        EndIf 
    Endif 

    Self:nHorizontalBoxPosition :=  iif(Self:nCurrentBox <> 1 .AND. !lQuebraLinha , (Self:nHorizontalBoxPosition + Self:nBoxWidth ) + Self:nPartitionBetweenBox,Self:nHorizontalBoxPosition)

    TBitmap():New(Self:nVerticalBoxPosition,Self:nHorizontalBoxPosition,Self:nBoxWidth,Self:nBoxHeight - 10,,cDirImg,,oPanel,{||aResult := Self:Paymentflow(cId,cName)},,.F.,.T.,,,.F.,,.T.,,.F.)
    oBtnTpPD :=  TButton():New((Self:nVerticalBoxPosition + Self:nBoxHeight) - 10,Self:nHorizontalBoxPosition,cName,oPanel,{||aResult := Self:Paymentflow(cId,cName)},Self:nBoxWidth,15,,,.F.,.T.,.T.,,.F.,,,.F. )
    
Return aResult


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ExchangePanels
Sub-Metodo de FlowForDigitalPayments, Metodo responsavel pela navegação entra paginas (caso necessario)

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param nNextpage, Numerico, Recebe um numero negativo ou positivo, caso seja negativo ele volta 1 pagina, caso positivo avança uma pagina.
@param nGoPage, Numerico, Recebe numero especifico para de pagina para exibição
@param lDestroyPg, logico, Indica se o painel atual deverá ser destruido
@param lUpdButtons, logico, Indica se deverá atualizar o status dos botoes 

@return Nulo, Nil
/*/
//-------------------------------------------------------------------------------------

Method ExchangePanels(nNextpage,nGoPage,lDestroyPg,lUpdButtons) Class PagamentosDigitais
    Default nGoPage     := 0    // -- Indica qual painel deverá ser exibido
    Default lDestroyPg  := .F.  // -- Indica se deve destruir o painel atual
    Default lUpdButtons := .T.  // -- Indica se deve atualizar o status atual dos botoes

    Self:aPanels[Self:nCurrentPage]:Disable()
    Self:aPanels[Self:nCurrentPage]:lVisible := .F.

    If nGoPage > 0
        If Len(Self:aPanels) >= nGoPage
            
            If lDestroyPg
                FreeObj(Self:aPanels[Self:nCurrentPage])
                aDel( Self:aPanels, Self:nCurrentPage )
                aSize(Self:aPanels, Len( Self:aPanels ) - 1 )
            EndIf 

            Self:nCurrentPage := nGoPage

        EndIf 
    Else
    
        If nNextpage < 0
            Self:nCurrentPage--
        Else 
            Self:nCurrentPage++
        EndIf 
        
    EndIf 

    If Self:lNavButtons .AND. lUpdButtons
        If  Self:nCurrentPage == Self:nQtyOfPages
            Self:oNextButton:Disable()
        Else
            Self:oNextButton:Enable()
        EndIf 

        If Self:nCurrentPage == 1
            Self:oPreviousButton:Disable()
        Else 
            Self:oPreviousButton:Enable()
        Endif
    EndIf 

    Self:aPanels[Self:nCurrentPage]:Enable()
    Self:aPanels[Self:nCurrentPage]:lVisible := .T.
    Self:aPanels[Self:nCurrentPage]:Refresh()
    Self:oInterface:Refresh()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Paymentflow
Sub-Metodo de FlowForDigitalPayments, Fluxo de pagamento

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param cIdMethod, Caracter, ID do metodo de pagamento (Ex.: "mercadopago","ame",etc.. ), recebido do metodo de listar pagamentos (MethodsAvaliables)
@param cName, Caracter, Nome do metodo de pagamento que será exibido no painel
@param aDadosCli, array, dados do cliente da transaçao
@param nTamVDlg, Numérico, Posicição Vertical para diação da dialog
@param nTamHDlg, Numérico, Posicição Horizontal para diação da dialog

@return aResult, Array, {
    "#Logico#,Indicativo de resultado do metodo",
    {
        "#Array#, Mensagem de erro caso tenha ocorrigo"
    }  
}
/*/
//-------------------------------------------------------------------------------------

Method Paymentflow(cIdMethod, cName, aDadosCli, nTamVDlg, nTamHDlg) Class PagamentosDigitais
    Local oResult
    Local aResult        := {.T.,{""}}
    Local nMilissegundos := 500 // -- intervalo em milisegundos entre buscar
    Local cInicioT       := ""  
    Local cFinalT        := ""
    
    Default aDadosCli    := {"","","","","","","",""} // {"cod","email","cpf/cnpj","nome","rua","cidade","cep","estado"}
    Default nTamVDlg     := Nil
    Default nTamHDlg     := Nil
    
    cInicioT := Time()

    LjGrvLog("PagamentosDigitais","Inicia transação para Id da carteira: " + cIdMethod + " Nome: " + cName + " Hr: " + cInicioT,,,.T.) 
    LjGrvLog("PagamentosDigitais","Id: " + Self:cIdTransct + " Valor: " + cValToChar(Self:nAmount),,,.T.) 
    
    aResult := Self:oPaymentHub:LinkPaymentTransaction(Nil,Self:cIdTransct,Self:nAmount,Nil,Nil,Nil,Nil,cIdMethod, aDadosCli)
    
    If aResult[1]
        If Self:oInterface == Nil .And. nTamVDlg <> Nil .And. nTamHDlg <> Nil
            //Cria a Dialog caso nao tem ainda iniciado a sua criação
            Self:oInterface := TDialog():New(000,000,nTamVDlg,nTamHDlg,STR0002,,,,,CLR_BLACK,/*CLR_WHITE*/,,,.T.) // "Carteiras digitais :D"
        EndIf
    
        oResult := Self:oPaymentHub:ResultLinkPaymentTransaction()
        Self:ctransactionId := oResult["transactionId"]

        If !Empty(Self:oLJCComPaymentHub)
            Self:oLJCComPaymentHub:TransPed(Self:ctransactionId,Self:nAmount,oResult["processorTransactionId"],oResult["externalTransactionId"],Self:cFormPayment/* "PD" */)
        Else
            LjGrvLog("PagamentosDigitais","Controle de transação pendente não esta ativo!",,,.T.)
        EndIf 

        AAdd(Self:aPanels,tPanel():New(Self:nMargin * 0.50,Self:nMargin * 0.50,"",Self:oInterface,,.T.,,CLR_BLACK,CLR_WHITE,Self:nTamHPnl - Self:nPartitionBetweenBox ,Self:nTamVPnl ))
        
        If Self:lNavButtons        
            Self:oNextButton:Disable()
            Self:oPreviousButton:Disable()
        End

        Self:PaymentInterface(Self:aPanels[Len(Self:aPanels)],cIdMethod,cName,oResult["qrCodeText"],oResult["qrCode"],oResult["processorTransactionId"],oResult["link"])

        ClearGlbValue(Self:cNomeGlobalNumberThread)  
        ClearGlbValue(Self:cNameGlobalStatus) 
    
        Self:oTimer := TTimer():New(nMilissegundos, {|| aResult := Self:GetStatusTransaction(oResult["externalBusinessUnitId"],oResult["externalPosId"],oResult["processorTransactionId"],cIdMethod)}, Self:oInterface )
        Self:oTimer:Activate()
    Else
        LjGrvLog("PagamentosDigitais","Metodo: " + cName + " Não esta disponivel no momento.",,,.T.)
        LjGrvLog("PagamentosDigitais","Buscar pelo IdLog:[PaymentHub] para maiores informações sobre o motivo da falha",,,.T.) 
        MsgAlert(STR0009 + cName + STR0010 ,"Ops... ") // "Metodo: " ##" Não esta disponivel no momento."
    EndIf 

    cFinalT := Time() 
    LjGrvLog("Pagamentos Digitais", "Final da transação para Id da carteira: " + cIdMethod + ", Nome: " + cName +" Hr: " +cFinalT ,,,.T.) 
    LjGrvLog("Pagamentos Digitais","Tempo total da execução da transação: "+ElapTime(cInicioT,cFinalT))
Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PaymentInterface
Sub-Metodo de FlowForDigitalPayments, interface de pagameno

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param oPanel, Objeto com interface do painel atual
@param cIdMethod, Caracter, ID do metodo de pagamento (Ex.: "mercadopago","ame",etc.. ), recebido do metodo de listar pagamentos (MethodsAvaliables)
@param cName, Caracter, Nome do metodo de pagamento que será exibido no painel
@param cTextQrCode, Caracter, Texto do QR-Code
@param cImg64QrCode, Caracter, Codigo da imagem do QR-Code em base 64 que será exibido para o pagamento.
@param cIdProcessor, Caracter, Id do processador
@param qrLink

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method PaymentInterface(oPanel,cIdMethod,cName,cTextQrCode,cImg64QrCode,cIdProcessor,qrLink) Class PagamentosDigitais
    Local nLenPanels      := Len(Self:aPanels)
    Local nsizeHorizontal := Self:nTamHPnl - Self:nPartitionBetweenBox
    Local nsizeVertical   := Self:nTamVPnl
    Local nBoxHeight      := Self:nBoxHeight
    Local nBoxWidth       := Self:nBoxWidth
    Local nLogoWidth      := 0
    Local nLogoHeight     := 0
    
    Local nBtnWidth       := 58
    Local nBtnHeight      := 20

    Local bAction         :={|| Self:exchangePanels(,1,.T.)                                                                     ,;
                                Self:oCancelButton:lVisible  := .F.                                                             ,;
                                Self:oReturnButton:lVisible  := .F.                                                             ,;
                                IIF(lNotImpFisc,Self:oReturnPrintQr:lVisible := .F.,Nil)                                       ,;
                                Self:oTimer:DeActivate()                                                                        ,;          
                                IIF(!Empty(Self:oLJCComPaymentHub),Self:oLJCComPaymentHub:TrataPend(Self:cTransactionId),Nil)   ,;
                                Self:cTransactionId := ""                                                                       ,; 
                                IIF(Self:lNavButtons,Self:oNextButton:Enable(),Nil)                                             }
    
    Local lGuil       := SuperGetMV("MV_FTTEFGU",, .T.)
    Local lPos        := STFIsPOS()
    Local cPrint      := ""
    Local bPrint      := Nil
    Local lNotImpFisc := (LjUseSat() .Or. LjEmitNFCe() .Or. LjUsaMfe() .Or. (LjFTVD() .AND. !Empty(LjGetStation("IMPFISC"))))
    Local cArqQrCode  := Self:cDirBase + Self:cDirTransec + "\" + cIdProcessor + ".png"
    Local cImgDecode  := ""
    Local nImgHandle  := 0
    Local cMsgErrArq  := ""
    Local oBtnLink    := Nil
    Local oPinPad     := Nil
    
    Default qrLink := ""

    cPrint := TAG_CENTER_INI + STR0011 + cName + CHR(10) + CHR(13) + STR0012 + cValToChar(Self:nAmount) + CHR(10) + CHR(13) + TAG_QRCODE_INI + cTextQrCode + TAG_QRCODE_FIM+TAG_CENTER_FIM  // "Método de pagamento: " ## "Valor R$: "
    cPrint += + CHR(10) + CHR(13)
    cPrint += + CHR(10) + CHR(13)
    
    If lGuil
        cPrint += TAG_GUIL_INI+TAG_GUIL_FIM	
    EndIf 
    
    bPrint := {|| IIF(lPos,STWPrintTextNotFiscal(cPrint),INFTexto(cPrint))}

    cImg64QrCode := SubStr(cImg64QrCode,At(",",cImg64QrCode)+1)
    cImg64QrCode := StrTran(cImg64QrCode," ","")
    cImg64QrCode := StrTran(cImg64QrCode,chr(13),"")
    cImg64QrCode := StrTran(cImg64QrCode,chr(10),"")
    
    If nsizeHorizontal > nBoxWidth .AND. nsizeVertical > nBoxHeight
        nBoxWidth := nBoxWidth + (nBoxWidth * 0.25)
        nBoxHeight := nBoxHeight + (nBoxHeight * 0.25)
    EndIf 

    If Self:nMaxNumOfVerticalBox >= 2
        nLogoHeight := nBoxHeight * 0.40
        nLogoWidth  := nBoxWidth  * 0.40
        TBitmap():New(0,(nsizeHorizontal - nLogoWidth ) * 0.50,nLogoWidth,nLogoHeight,,Self:cDirBase + "\" + cIdMethod + ".png",.T.,oPanel,{||},,.F.,.T.,,,.F.,,.T.,,.F.)
        oSayPgto := TSay():New(nLogoHeight + 5 ,(nsizeHorizontal - nBoxWidth) * 0.50,{||STR0013},oPanel,,Self:oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,nBoxWidth,20) //"Aguardando pagamento"
        oSayPgto:SetTextAlign( 2, 2 )
    EndIf 
    
    oSayCarteira := TSay():New(nLogoHeight,(nsizeHorizontal - nBoxWidth) * 0.50,{||cName},oPanel,,Self:oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,nBoxWidth,10)
    oSayCarteira:SetTextAlign( 2, 2 )
    
    LjGrvLog("PagamentosDigitais","Imagem do QR-Code em base 64 retornada pela API",cImg64QrCode,,.T.)

    cImgDecode  := Decode64(cImg64QrCode)   //Decodifica o Qr-Code
    nImgHandle  := FCreate(cArqQrCode)      //Cria a imagem no disco

     If nImgHandle == -1
        cMsgErrArq := STR0003 + cArqQrCode + "). Ferror: " + Str(Ferror()) // "Erro ao tentar criar o arquivo (" 
        LjGrvLog("PagamentosDigitais",cMsgErrArq,,,.T.) 
        ConOut(cMsgErrArq)
        MsgAlert(cMsgErrArq)
    Else
        FWrite(nImgHandle, cImgDecode)
        FClose(nImgHandle)
    EndIf

    If !Empty(cTextQrCode)
        Self:cQrCode := cTextQrCode
    EndIf

    TBitmap():New(((nsizeVertical - nBoxHeight) + nLogoHeight) * Iif(Self:nMaxNumOfVerticalBox == 1,1,0.50),(nsizeHorizontal - nBoxWidth) * 0.50 ,nBoxWidth,nBoxHeight ,,cArqQrCode,.T.,oPanel,{||},,.F.,.T.,,,.F.,,.T.,,.F.)

    //Após montar a Imagem do Qr-Code na tela, já apaga para não acumular arquivos no disco.
    If FErase(cArqQrCode) == -1
        LjGrvLog("PagamentosDigitais",'Falha na deleção do Arquivo: ' + cArqQrCode + ' (FError' + Str(ferror(),4) + ')',,,.T.)
    EndIf
    
    
    If AllTrim(Upper(Self:cFormPayment)) == "PX"
        oBtnLink :=  TButton():New(((nsizeVertical + nBoxHeight + nLogoHeight + 10) * Iif(Self:nMaxNumOfVerticalBox == 1,1,0.49)) + 1, ((nsizeHorizontal - nBoxWidth) * 0.53), STR0014,oPanel,{|| Iif(!Empty(qrLink),(CopytoClipboard(qrLink),MsgAlert(STR0015)),MsgAlert(STR0016)) }, ((nsizeHorizontal - nBoxWidth) * 0.58),10,,,.F.,.T.,.T.,,.F.,,,.F. ) // "Copiar Link para pagamento" ## "Copiado para area de transferencia." ## "Link de pagamento não está disponivel"
        
        oPinPad  := TButton():New(Self:nTamVPnl + (Self:nMargin * 0.50), (Self:nTamHPnl + Self:nMargin * 0.50) - ((nBtnWidth * 2.1) + (Self:nPartitionBetweenBox * 0.58) ), STR0022 , Self:oInterface, {|| STBEnvAutPinPad(Self:cQrCode,self:oPaymentHub)}, nBtnWidth,nBtnHeight,,,.F.,.T.,.T.,,.F.,,,.F. ) //"Qr-Code no PinPad" 
        
    EndIF 
    
    Self:oCancelButton     := TButton():New( Self:nTamVPnl + (Self:nMargin * 0.50), (Self:nTamHPnl + Self:nMargin * 0.50) - nBtnWidth, STR0017,Self:oInterface,{|| Self:oInterface:End(), Self:oLJCComPaymentHub:DeletaArqTrans(Self:cTransactionId) }, nBtnWidth,nBtnHeight,,,.F.,.T.,.T.,,.F.,,,.F. ) // "Cancelar"     
    
    If !Self:lUniquewallet
        Self:oReturnButton     := TButton():New( Self:nTamVPnl + (Self:nMargin * 0.50), (Self:nTamHPnl + Self:nMargin * 0.50) - ((nBtnWidth * 2) + (Self:nPartitionBetweenBox * 0.20) ) , STR0018,Self:oInterface,bAction, nBtnWidth,nBtnHeight,,,.F.,.T.,.T.,,.F.,,,.F. ) // "Retornar"
    EndIf 

    If lNotImpFisc
        Self:oReturnPrintQr    := TButton():New( Self:nTamVPnl + (Self:nMargin * 0.50), (Self:nTamHPnl + Self:nMargin * 0.50) - ((nBtnWidth * 3.3) + (Self:nPartitionBetweenBox * 0.40) ) , STR0019,Self:oInterface,bPrint, nBtnWidth,nBtnHeight,,,.F.,.T.,.T.,,.F.,,,.F. )  // "Imprimir QR-Code"
    EndIf  

    Self:ExchangePanels(,nLenPanels,,.F.) 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ConfirmPayment
Sub-Metodo de FlowForDigitalPayments, Confirma o pagamento 

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@return Nil, Nulo
/*/
//-------------------------------------------------------------------------------------

Method ConfirmPayment() Class PagamentosDigitais
    Local oResult   := Nil

    oResult := Self:oPaymentHub:ResultStatusLinkPaymentTransaction()
    // -- Possiveis Status: ["status": "pending, approved, cancelled, expired, refunded, refund_pending"]
    If oResult["status"] == "approved"
        MSGINFO(STR0020) // "Pagamento realizado!"
        Self:lClosed := .T.
        Self:oTimer:DeActivate()
        Self:oInterface:End()
        LjGrvLog("Pagamentos Digitais","Pagamento realizado " + " Wallet:[" + oResult["wallet"] +"] "+" Status: ["+ oResult["status"] + "]") 
    Else
        ConOut(STR0013 + oResult["wallet"] )  // "Aguardando pagamento"
        LjGrvLog("Pagamentos Digitais","Aguardando pagamento... "+ " Wallet:[" + oResult["wallet"] +"] "+" Status: ["+ oResult["status"] + "]") 
    EndIf 
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} DirectoryControl
Controle de diretório

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@return Logico, Indica se o diretorio existe, ou se conseguiu criar o diretorio
/*/
//-------------------------------------------------------------------------------------

Method DirectoryControl() Class PagamentosDigitais
    Local lRetorno := .T.
    
    If ExistDir(Self:cDirBase)
        If !ExistDir(Self:cDirBase + Self:cDirTransec)
            lRetorno := MakeDir(Self:cDirBase + Self:cDirTransec) == 0
        EndIf 
    Else
        lRetorno := MakeDir(Self:cDirBase) == 0
        If lRetorno
            lRetorno := MakeDir(Self:cDirBase + Self:cDirTransec) == 0
        EndIf 
    EndIf

Return lRetorno

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} EndScreen
Fecha a tela

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@return Logico, Logico liberando o fechamento do dialogo
/*/
//-------------------------------------------------------------------------------------

Method EndScreen() Class PagamentosDigitais

    If !Self:lClosed .And. !Empty(Self:cTransactionId)
        If !Empty(Self:oLJCComPaymentHub)
            Self:oLJCComPaymentHub:TrataPend(Self:cTransactionId)
            Self:cTransactionId := ""
        Else    
            LjGrvLog("PagamentosDigitais","Controle de transação pendente não esta ativo!",,,.T.)
        EndIf 
    EndIf 

Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetStatusTransaction
Sub-Metodo de FlowForDigitalPayments, interface de pagameno

@type       Method
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param cExternalBusinessUnitId, Caracter, Id da unidade "companhia"
@param cExternalPosId, Caracter, Codigo do PDV
@param cIdProcessor, Caracter, Id do processador
@param cIdMethod, Caracter, ID do metodo de pagamento (Ex.: "mercadopago","ame",etc.. ), recebido do metodo de listar pagamentos (MethodsAvaliables)
@return aResult, Array, {
    "#Logico#,Indicativo de resultado do metodo",
    {
        "#Array#, Mensagem de erro caso tenha ocorrigo"
    }  
}
/*/
//-------------------------------------------------------------------------------------

Method GetStatusTransaction(cExternalBusinessUnitId,cExternalPosId,cIdProcessor,cIdMethod) Class PagamentosDigitais
    Local aGetUserInfo     := {}
    Local lNewConsultation := .T.
    Local uGSValue         := ""
    Local cGKeyValue         := ""
    Local aResult          :={.T., {""}}
    Local oJson            := JsonObject():New()
    Local cResult          := ""
    Local aTrasaction      := {}
    Local aPHubParams      := {}
    
    GetGlbVars(Self:cNomeGlobalNumberThread,Self:nGlobalNumberThread)
    
    If Self:nGlobalNumberThread <> 0
        aGetUserInfo := GetUserInfoArray()
        GetGlbVars(Self:cNameGlobalStatus,uGSValue,cGKeyValue)
        lNewConsultation := ((aScan(aGetUserInfo, { |x| x[3] == Self:nGlobalNumberThread }) == 0) .AND. Empty(uGSValue)) 
    EndIf 
    
    If lNewConsultation

        // -- Devera ser montado na ordem que o metodo StatusLinkPaymentTransaction da classe paymenthub recebe.
        aTrasaction := {cExternalBusinessUnitId,cExternalPosId,cIdProcessor,.F.}

        // -- Deve ser montado na ordem em que a classe Paymenthub recebera no construtor
        aPHubParams := { Self:oPaymentHub:cCodeComp,Self:oPaymentHub:cCurrency,Self:oPaymentHub:cIdPinPed,Self:oPaymentHub:cIdPos                   ,;
                        Self:oPaymentHub:cTenant,Self:oPaymentHub:cUserName,Self:oPaymentHub:cPassword,Self:oPaymentHub:cClientId                   ,;
                        Self:oPaymentHub:cClientSecret,Self:oPaymentHub:cToken,Self:oPaymentHub:dDateExpiration,Self:oPaymentHub:cTimeExpiration    ,;
                        Self:oPaymentHub:cEnvironment }
        
        Startjob("PdGetStatus",GetEnvServer(),.F.,aPHubParams,aTrasaction,Self:cNameGlobalStatus,Self:cNomeGlobalNumberThread,cIdProcessor + cExternalBusinessUnitId)
        //PdGetStatus(aPHubParams,aTrasaction,Self:cNameGlobalStatus,Self:cNomeGlobalNumberThread,cIdProcessor + cExternalBusinessUnitId) 
    EndIf 

    GetGlbVars(Self:cNameGlobalStatus,uGSValue,cGKeyValue)
    
    If !Empty(uGSValue)
        If cIdProcessor + cExternalBusinessUnitId == cGKeyValue 
            If ValType( uGSValue ) == "A"
                aResult := uGSValue
            Else
                cResult  := oJson:FromJson(uGSValue) 
                If ValType(cResult) == "U"
                    Self:oPaymentHub:SetStatusLinkPaymentTransaction(oJson)
                    Self:ConfirmPayment()
                Else
                    aResult := {.F.,{STR0021} + cResult}  // "Não foi possivel realizar o Parse do retorno da API, ERRO: "
                EndIf 
            EndIf
        EndIf 

        ClearGlbValue(Self:cNomeGlobalNumberThread)  
        ClearGlbValue(Self:cNameGlobalStatus)

    EndIf 
 
Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PdGetStatus
Sub-Metodo de FlowForDigitalPayments, interface de pagameno

@type       Function
@author     Lucas Novais (lnovais@)
@since      09/12/2020
@version    12.1.27

@param aPHubParams, Array, Array com os parametros para o instaciamento da classe PaymentHub
@param aTrasaction, Array, Array com os parametros para o instaciamento do metodo StatusLinkPaymentTransaction
@param cGSName, Caracter, Nome da variavel global de retorno do metodo
@param cGTName, Caracter, Nome da variavel global que armazena a thread que será devolvida para a thread instaciadora 
@param cKey, Caracter, Chave que é enviada apenas para que ela possa ser devolvida, desta forma é possivel checar se a thread instanciadora ainda esta esperando o retorno desta chave
@return Null, Nulo
/*/
//-------------------------------------------------------------------------------------

Function PdGetStatus(aPHubParams,aTrasaction,cGSName,cGTName,cKey)
    Local aResult   := {}
    Local nI        := 0
    Local cAux      := ""

    PutGlbVars(cGTName,ThreadId())

    cAux := "PaymentHub():New("
    For nI := 1 To Len(aPHubParams)
    
        cAux += "aPHubParams[" + cValtoChar(nI) + "]" 

        If nI <> Len(aPHubParams)
            cAux += ", " 
        EndIf 

    Next nI
    
    cAux += ")"
    oPaymentHub := &cAux

    cAux := "oPaymentHub:StatusLinkPaymentTransaction("
    For nI := 1 To Len(aTrasaction)
                
        cAux += "aTrasaction[" + cValtoChar(nI) + "]"

        If nI <> Len(aTrasaction)
            cAux += ", " 
        EndIf 

    Next nI
    cAux += ")"

    If !Empty(oPaymentHub)
        aResult := &cAux
    EndIf 

    Sleep(1000)

    If aResult[1]
        cResult := oPaymentHub:ResultStatusLinkPaymentTransaction()
        PutGlbVars(cGSName,cResult,cKey)
    Else
        PutGlbVars(cGSName,aResult,cKey)
    EndIf 

Return


Function IsPDOrPix(cFormPayment)    
Return cFormPayment $ "PD|PX"

/*/{Protheus.doc} STBQrPinPad
Envia o Qr-Code do PIX para o Pin-Pad 
@type       Function
@author     Jeferson Mondeki
@since      10/11/2023
@version    P12
@param oTef, Objeto, Objeto contendo os dados da função STBGetTEF()
@param cImg64QrCode, Caracterer, contendo os dados do QrCode para envio ao Pin-Pad.
@param oTpd, Objeto, Objeto contendo os dados do TPD
@return lRet, retorna .T. se enviou corretamente para o pin-pad e .F. se não conseguir enviar.
/*/

Function STBQrPinPad(oTef, cImg64QrCode,oTpd)

Local lRet                      := .F. // Retorna se enviou corretamente ou não 
Local nFuncTef                  := 946 // Função para envio do Qr-Code no TEF  

Default oTef                    := Nil // Objeto contendo os dados da função STBGetTEF()
Default cImg64QrCode            := ""  // Retorno do Qr-Code da API
Default oTpd                    := Nil // Objeto contendo os dados do TPD Para envio ao metodo continua ContinFunc do Tef

If nModulo == 23 .And.  oTef <> Nil .And. ValType(oTef:oConfig:oComPaymentHub) == "O" //Chama o metodo do TEF (TOTVS PDV)
    oTef:oConfig:oComPaymentHub:oTransacao:dData := Date()
    oTef:oConfig:oComPaymentHub:oTransacao:cHora := Time()
    oTef:oConfig:oComPaymentHub:oTransacao:nCupom := Iif(nModulo == 23, Val(STDGPBasket("SL1","L1_NUM")), Val(SL1->L1_NUM))
    oTef:oConfig:oComSitef:oTransacao := oTef:oConfig:oComPaymentHub:oTransacao
    oTef:oConfig:oComSitef:IniciaFunc(nFuncTef,"")
    lRet := .T.

    LjGrvLog("Qr-Code no Pin-Pad","Enviou dados para o metodo IniciaFunc()",lRet,,.T.)

    If lRet .And. oTef <> Nil
        oTef:oConfig:oComSitef:ContinFunc(/*cBuffer*/,/*nContinua*/, cImg64QrCode,oTpd) 
    EndIf
ElseIf nModulo == 12 .Or. nModulo == 05 .And. oTef <> Nil //Chama o metodo do TEF (Venda assistida/Venda Direta)
    //Inicia o processo para enviar o Qr-Code do PIX no PinPad
    oTef:Operacoes("QRCODE_PINPAD",,,,SL1->L1_NUM,,,,,,,,,)
    //Continua o processo para enviar o Qr-Code do PIX no PinPad
    If oTef <> Nil .And. oTpd <> Nil
        oTef:ContinTrn(cImg64QrCode,oTpd)    
    EndIf     
EndIf
Return lRet

/*/{Protheus.doc} STBGetTPD
Função para retornar se o pagamento está aprovado ou não. 
@author  Jeferson Mondeki
@since   17/11/2023
@version P12
@param oTpd, Objeto, Objeto contendo os dados do TPD
@return  lApTPD, logico, variavel que contém o conteúdo .T. se pagamento aprovado .F. se não não aprovado.
@obs     					
@sample
/*/
//-------------------------------------------------------------------

Function STBGetTPD(oTpd)
Local oPaymentHub               := oTpd
Local oResult                   := Nil 
Local aPHubParams               := {}
Local aTrasaction               := {}
Local uGSValue                  := ""
Local cGKeyValue                := ""
Local nGlobalNumberThread       := 0
Local cNameGlobalStatus         := "LJG_STATUSTRANSACTION" + cValTochar(ThreadId()) 
Local cNomeGlobalNumberThread   := "LJG_NUMBERTHREAD"      + cValTochar(ThreadId())
Local oStatus                   := Nil 
Local nOpc 	                    := 0 // Se clicar no botão sair a opção será 1 = sim 

If !lEndQr .And. !lApTPD .And. FWIsInCallStack("STBQrPinPad")
    nOpc := Aviso(STR0027, STR0028, {"Não","Sim"},,,,,,4000) //"Atenção" # "Aguardando leitura do Qr-Code no PinPad. Deseja remover o Qr-Code do PinPad ?"
    If nOpc == 2
        lEndQr := .T.  
    EndIf
EndIf

GetGlbVars(cNomeGlobalNumberThread,nGlobalNumberThread)

If oPaymentHub <> Nil .And. !lEndQr
    aPHubParams := { oPaymentHub:cCodeComp, oPaymentHub:cCurrency, oPaymentHub:cIdPinPed, oPaymentHub:cIdPos                   ,;
                    oPaymentHub:cTenant, oPaymentHub:cUserName, oPaymentHub:cPassword, oPaymentHub:cClientId                   ,;
                    oPaymentHub:cClientSecret, oPaymentHub:cToken, oPaymentHub:dDateExpiration, oPaymentHub:cTimeExpiration    ,;
                    oPaymentHub:cEnvironment }

    oResult:= oPaymentHub:ResultLinkPaymentTransaction()

    aTrasaction := { oResult["externalBusinessUnitId"], oResult["externalPosId"], oResult["processorTransactionId"] }
                    
    PdGetStatus(aPHubParams,aTrasaction, cNameGlobalStatus ,cNomeGlobalNumberThread,oResult["processorTransactionId"] + oResult["externalBusinessUnitId"])
                
    GetGlbVars(cNameGlobalStatus,uGSValue,cGKeyValue)
            
    If oResult <> Nil .And. oResult["processorTransactionId"] + oResult["externalBusinessUnitId"] == cGKeyValue     
        oPaymentHub:SetStatusLinkPaymentTransaction(uGSValue)
        oStatus := oPaymentHub:ResultStatusLinkPaymentTransaction()
        // -- Possiveis Status: ["status": "pending, approved, cancelled, expired, refunded, refund_pending"]
        If ValType(oStatus)=="J" .AND. oStatus["status"] == "approved" 
            lApTPD := .T.
        EndIf
    EndIf    

EndIf

ClearGlbValue(cNomeGlobalNumberThread)  
ClearGlbValue(cNameGlobalStatus) 

Return lApTPD

/*/{Protheus.doc} STBSetTPD
Função para setar se o pagamento foi aprovado ou não;
na variavel lApTPD limpando ao final de cada venda
@param lValue, logico, seta um default para a variavel
@author  Jeferson Mondeki
@version P12
@since   17/11/2023
@return  lValue, logico
@obs     					
@sample
/*/
//-------------------------------------------------------------------

Function STBSetTPD(lValue)
Default lValue := .F.
lApTPD := lValue
Return

/*/{Protheus.doc} STBEnvAutPinPad
responsavel por validar as configurações para envio do qrcode para o pinpad
@type       Function
@author     Mateus Nascimento
@since      19/04/2024
@version    

@@param  cQrCode, Caráter, Responsavel por receber Self:cQrCode 
@@param  oPaymentHub,objeto,Responsavel por receber  self:oPaymentHub
@return  Null
@obs     					
@sample
/*/
//-------------------------------------------------------------------------------------

Static Function STBEnvAutPinPad(cQrCode,oPaymentHub) 

If nModulo == 23  //Valida se utiliza TEF 2.0 sistema(PDV)
    If oTef20 <> Nil .And. oTef20:oConfig:oComSitef <> Nil .And. oTef20:oConfig:oComSitef:VerPinPad() == 1 .And. GetdToVal(oTef20:oConfig:oComSitef:cClisitefI) >= 7.011739 
        STBQrPinPad(oTef20, cQrCode, oPaymentHub)
    Else
        MsgAlert(STR0023 + Chr(13) + Chr(10) + Chr(10) + STR0024 + Chr(13) + Chr(10) + Chr(10) + STR0025 + Chr(13) + Chr(10) + Chr(10) + STR0026, STR0027)// "Envio do Qr-Code para o PinPad não está disponivel !" ## "Verificar os dados abaixo : " ## "As DLLs do CliSitef precisam estar atualizadas." ## "O PinPad precisa estar conectado corretamente. " ## "Atenção "
    Endif    
ElseIf nModulo == 12 .Or. nModulo == 05 //Valida se utiliza TEF (Venda assistida/Venda Direta)
    If Type("oTef") <> "U" .And. oTef <> Nil .And. oAutocom:SIT_VERPIN() == 1 
        STBQrPinPad(oTef,cQrCode, oPaymentHub)
    Else
      MsgAlert(STR0023 + Chr(13) + Chr(10) + Chr(10) + STR0024 + Chr(13) + Chr(10) + Chr(10) + STR0025 + Chr(13) + Chr(10) + Chr(10) + STR0026, STR0027) // "Envio do Qr-Code para o PinPad não está disponivel !" ## "Verificar os dados abaixo : " ## "As DLLs do CliSitef precisam estar atualizadas." ## "O PinPad precisa estar conectado corretamente. " ## "Atenção "
    Endif
Endif 
            
    
Return

/*/{Protheus.doc} STBGetEnd
Função para retornar se retira a imagem do QrCode do PinPad.
@author  Jeferson Mondeki
@since   10/12/2024
@version P12
@return  lEndQr, logico, variavel que contém o conteúdo .T. retira o QrCode do PinPad .F. não Retira o QrCode do PinPad.
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STBGetEnd()
Return lEndQr

/*/{Protheus.doc} STBSetEnd
Função para voltarmos a variavel lEndQr para o seu valor default 
@param lValue, logico, seta um default para a variavel
@author  Jeferson Mondeki
@version P12
@since   10/12/2024
@return  lValue, logico
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STBSetEnd(lValue)
Default lValue := .F.
lEndQr := lValue
Return
