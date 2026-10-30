#Include "TOTVS.ch"
#Include "msobject.ch"
#Include "POSCSS.CH"
#Include "RotinasGerenciais.CH"

/*/{Protheus.doc} RotinasGerenciaisPaymentHub
    Classe utilizada na selecao de rotinas gerenciais do Payment Hub
    @author JMM
    @since  03/08/2020
/*/

Class RotinasGerenciaisPaymentHub

Data cTipoCartao        

Data oFontBold16        
Data oFontBold12        
Data oFontBoldRED16     

// Atributas da Tela de Selecao
Data oScreenRotinas     
Data aBranches          
Data aRotinas           
Data aRotina            

// Atributos da Tela de digitação do Cupom
Data oScreenDigitaCupom 
Data cCupom             
Data aDadosTrasacoes    
Data aDadosTrasacao     

Data nRotina            

// Wizard
Data DialogWizard        
Data cStep1              
Data cStep2              
Data cStep3              
Data aBranchesPg1        
Data aBranchesPg3        

Method New() Constructor

// Metodos da Tela de Selecao
Method RetSelectdRotina()
Method SetSelectdRotina()
Method ListRotinas()
Method RotinaSelectd()

Method SetRotina()
Method GetRotina()

Method RetornaDadosTransacoes()
Method SetDadosTransacoes()
Method GetDadosTransacoes()

Method TransacaoRetornaDados()
Method TransacaoSetDados()
Method TransacaoGetDados()

Method EndScreen()

//---
// Wizard
Method ShowScreenGerencial()
Method GerencialWizard() 
Method WizardPge1()
Method WizardPge2() 
Method WizardPge3() 

EndClass

/*/{Protheus.doc} New
    Metodo construtor da classe
    @author JMM
    @since  03/08/2020
/*/
Method New() Class RotinasGerenciaisPaymentHub

    Self:aRotinas        := Self:ListRotinas()
    Self:aRotina         := Self:SetSelectdRotina({})
    Self:aBranches       := {}
    Self:cTipoCartao     := "CD/CC/PRA/PD/PX"
    Self:aDadosTrasacao  := {}
    Self:aDadosTrasacoes := {}

    Self:oFontBold16     := TFont():New(,,-16,.T.,.T.)
    Self:oFontBold12     := TFont():New(,,-12,.T.,.T.)
    Self:cStep1          := ""
    Self:cStep2          := ""
    Self:cStep3          := ""
    Self:aBranchesPg1    := {}
    Self:aBranchesPg3    := {}
    Self:nRotina         := 0

Return Self

/*/{Protheus.doc} ShowScreenGerencial
    Metodo responsavel ativar a tela de digitação do cupom
    @author JMM
    @since  03/08/2020
    @param  nTipo, numerico, numero correspondente a rotina escolhida, que será utilizado como descriçaõ na tela
/*/
Method ShowScreenGerencial() Class RotinasGerenciaisPaymentHub 
    Self:GerencialWizard()
Return

/*/{Protheus.doc} EndScreen
    Metodo responsavel por desativar a tela informada
    @author JMM
    @since  03/08/2020
    @param  oScreen, objeto, Objeto da tela
/*/
Method EndScreen(oScreen) Class RotinasGerenciaisPaymentHub
    oScreen:End()
    //oScreen:Destroy()
Return

/*/{Protheus.doc} ListRotinas
    Metodo responsavel por retornar as rotinas diponiveis
    @author JMM
    @since  03/08/2020
/*/
Method ListRotinas() Class RotinasGerenciaisPaymentHub
    Local aRotinas := {{STR0001, 01},{STR0003,03}} // "Reimpressão de via" // "Seleção de Terminal" // "Estorno de transação"
return aRotinas

/*/{Protheus.doc} RotinaSelectd
    Metodo responsavel por retornar a rotina selecionada
    @author JMM
    @since  03/08/2020
    @param  nLinha, numerico, linha do browser
/*/
Method RotinaSelectd(nLinha,aBranches) Class RotinasGerenciaisPaymentHub
    Local aSelectdRotina    := ""   
    Local nX                := 0    

    For nX := 1 To Len(Self:aRotinas)
        If aBranches[nLinha][01] == Self:aRotinas[nX][01]
            aSelectdRotina := {Self:aRotinas[nX][01], Self:aRotinas[nX][02]}
            Exit
        EndIf
    Next

    Self:SetSelectdRotina(aSelectdRotina)

return .T.

/*/{Protheus.doc} TransacaoRetornaDados
    Metodo responsavel por indicar os dados a serem gravados no atributo aDadosTrasacao
    @author JMM
    @since  03/08/2020
    @param  nLinha, numerico, linha do browser
/*/
Method TransacaoRetornaDados(nLinha) Class RotinasGerenciaisPaymentHub

    Self:TransacaoSetDados(Self:aDadosTrasacoes[nLinha])

return .T.

/*/{Protheus.doc} RetornaDadosTransacoes
    Retorna os dados referente a transação de cartao do cupom informado
    @author JMM
    @since 03/08/2020
    @param  cCuppDigt, caracter, Codigo do cupom
/*/
Method RetornaDadosTransacoes(oPanelBkg, oSayCupInv, cCupDigt, cSerieDig, cExtTrID, oSayNoTrn) Class RotinasGerenciaisPaymentHub
    Local lRet          := .F.              
    Local aDadosTrans   := {}                 
    Local lCupomValido  := .F.                            
    Local cNome         := ""   
    Local nPos          := 0            
    
    oSayCupInv:Hide()
    oSayNoTrn:Hide()

    If !Empty(cCupDigt)

        DbSelectArea("SL1")
        SL1->( DbSetOrder(2) )	//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
        If DBSeek(xFilial("SL1") + PADR(cSerieDig,TAMSX3("L1_SERIE")[1]) + PADR(cCupDigt,TAMSX3("L1_DOC")[1]))
            
            DbSelectArea("SA1")
            SA1->( DbSetOrder(1) )	//A1_FILIAL+A1_COD+A1_LOJA
            If DBSeek(xFilial("SA1") + SL1->(L1_CLIENTE + L1_LOJA ))
                cNome       := AllTrim(SA1->A1_NOME)
            EndIf

            DbSelectArea("SL4")
            SL4->( DbSetOrder(1) )	//L4_FILIAL+L4_NUM+L4_ORIGEM
            If DBSeek(xFilial("SL4") + SL1->L1_NUM)
                While SL4->(!Eof()) .AND. xFilial("SL4") == SL1->L1_FILIAL .AND. SL4->L4_NUM == SL1->L1_NUM 
                    If AllTrim(SL4->L4_FORMA) $ Self:cTipoCartao .AND. Empty(SL4->L4_DOCCANC) .AND. !Empty(SL4->L4_TRNID + SL4->L4_TRNPCID + SL4->L4_TRNEXID)
                        If (nPos := aScan(aDadosTrans, {|x| AllTrim(x[12]) == AllTrim(SL4->L4_TRNID)})) > 0
                            aDadosTrans[nPos][6] += SL4->L4_VALOR               //Soma o Valor Total da transação
                            aDadosTrans[nPos][7] := aDadosTrans[nPos][7] + 1    //Soma a qtde. de parcelas
                            aAdd( aDadosTrans[nPos][16], SL4->(Recno()) )       //Guarda os Recnos da SL4 referente a transação
                        Else
                            AADD(aDadosTrans, { SL1->L1_DOC             ,; //01-Num. DOC.
                                                SL1->L1_NUM             ,; //02-Num. Orcamento
                                                SL1->L1_CLIENTE         ,; //03-Cod. Cliente
                                                SL1->L1_LOJA            ,; //04-Cod. Loja
                                                cNome                   ,; //05-Nome Cliente
                                                SL4->L4_VALOR           ,; //06-Valor Total da transação
                                                1                       ,; //07-Qtd Parcelas
                                                SL4->L4_DATATEF         ,; //08-Data da Transação
                                                SL4->L4_HORATEF         ,; //09-Hora da Transação
                                                SL4->L4_FORMA           ,; //10-Forma de Pagamento
                                                SL4->L4_DOCTEF          ,; //11-DOCTEF da transação
                                                Alltrim(SL4->L4_TRNID)  ,; //12-ID da Transação
                                                Alltrim(SL4->L4_TRNPCID),; //13-ID Transação Processador
                                                Alltrim(SL4->L4_TRNEXID),; //14-ID da Transação Externa
                                                SL4->L4_NSUTEF          ,; //15-NSU da Transação
                                                { SL4->(Recno()) }      }) //16-Array de Recnos da SL4 referente a transação
                        EndIf
                        SL4->(dbSkip()) 
                    Else
                    SL4->(dbSkip())  
                    EndIf
                EndDo
            EndIf

            lCupomValido := .T.
        EndIf
    ElseIf !Empty(cExtTrID) // Para venda canceladas - Cancelameto via Codigo de Referência
        DbSelectArea("SL4")
        SL4->( DbSetOrder(5) )	// L4_FILIAL+L4_TRNEXID+L4_TRNID+L4_TRNPCID                                                                                                                        
        If SL4->( DBSeek(xFilial("SL4") + cExtTrID) )
            While SL4->(!Eof()) .AND. xFilial("SL4") == cFilAnt .AND. AllTrim(SL4->L4_TRNEXID) == AlLTrim(cExtTrID) 
                If AllTrim(SL4->L4_FORMA) $ Self:cTipoCartao .AND. !Empty(SL4->L4_TRNID + SL4->L4_TRNPCID + SL4->L4_TRNEXID)
                    AADD(aDadosTrans, { Nil                     ,; //01-Num. DOC.
                                        SL4->L4_NUM             ,; //02-Num. Orcamento
                                        Nil                     ,; //03-Cod. Cliente
                                        Nil                     ,; //04-Cod. Loja
                                        Nil                     ,; //05-Nome Cliente
                                        SL4->L4_VALOR           ,; //06-Valor Total da transação
                                        1                       ,; //07-Qtd Parcelas
                                        SL4->L4_DATATEF         ,; //08-Data da Transação
                                        SL4->L4_HORATEF         ,; //09-Hora da Transação
                                        SL4->L4_FORMA           ,; //10-Forma de Pagamento
                                        SL4->L4_DOCTEF          ,; //11-DOCTEF da transação
                                        Alltrim(SL4->L4_TRNID)  ,; //12-ID da Transação
                                        Alltrim(SL4->L4_TRNPCID),; //13-ID Transação Processador
                                        Alltrim(SL4->L4_TRNEXID),; //14-ID da Transação Externa
                                        SL4->L4_NSUTEF          ,; //15-NSU da Transação
                                        { SL4->(Recno()) }      }) //16-Array de Recnos da SL4 referente a transação
                    SL4->(dbSkip()) 
                Else
                    SL4->(dbSkip())  
                EndIf
            EndDo
             lCupomValido := .T.
        EndIf
    EndIf
        
    If !lCupomValido
        oSayCupInv:Show()
        //oPanelBkg:Refresh()
    ElseIf Empty(aDadosTrans)
        oSayNoTrn:Show()
        //oPanelBkg:Refresh()
    Else
        Self:SetDadosTransacoes(aDadosTrans)
        lRet := .T.
    EndIf

return lRet


/*/{Protheus.doc} SetSelectdRotina
    Metodo responsavel por atribuir valor ao atributo aRotina
    @author JMM
    @since  03/08/2020
    @param  aSelectdRotina, array, dados da rotina selecionada
/*/
Method SetSelectdRotina(aSelectdRotina) Class RotinasGerenciaisPaymentHub
    Self:aRotina := aSelectdRotina
return

/*/{Protheus.doc} RetSelectdRotina
    Metodo responsavel por retornar a rotina selecionada para execução
    @author JMM
    @since  03/08/2020
/*/
Method RetSelectdRotina() Class RotinasGerenciaisPaymentHub
return Self:aRotina

/*/{Protheus.doc} TransacaoSetDados
    Metodo responsavel por atribuir valor ao atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
    @param  aDadosTrans, array, Dados da transação
/*/
Method TransacaoSetDados(aDadosTrans) Class RotinasGerenciaisPaymentHub
    Self:aDadosTrasacao := aDadosTrans
return

/*/{Protheus.doc} TransacaoGetDados
    Metodo responsavel por retornar os dados da transação, atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
/*/
Method TransacaoGetDados() Class RotinasGerenciaisPaymentHub
return Self:aDadosTrasacao

/*/{Protheus.doc} SetDadosTransacoes
    Metodo responsavel por atribuir valor ao atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
    @param  aDadosTrans, array, Dados da transação
/*/
Method SetDadosTransacoes(aDadosTrans) Class RotinasGerenciaisPaymentHub
    Self:aDadosTrasacoes := aDadosTrans
return

/*/{Protheus.doc} GetDadosTransacoes
    Metodo responsavel por retornar os dados da transação, atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
/*/
Method GetDadosTransacoes() Class RotinasGerenciaisPaymentHub
return Self:aDadosTrasacoes

/*/{Protheus.doc} SetRotina
    Metodo responsavel por atribuir valor ao atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
    @param  aDadosTrans, array, Dados da transação
/*/
Method SetRotina(nOpcao) Class RotinasGerenciaisPaymentHub
    Self:nRotina := nOpcao
return

/*/{Protheus.doc} GetRotina
    Metodo responsavel por retornar os dados da transação, atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
/*/
Method GetRotina() Class RotinasGerenciaisPaymentHub
return Self:nRotina

/*/{Protheus.doc} GerencialWizard
    Metodo responsavel por retornar os dados da transação, atributo aDadosTrasacao
    @author JMM
    @since  04/08/2020
/*/
Method GerencialWizard() Class RotinasGerenciaisPaymentHub
    Local oNewPag   := Nil          
    Local oStepWiz := Nil           
    Local oPanelBkg                 
    Local lTransparent  := .T.       

    // Pagina 01
    Local oTCBrowsePg1 := Nil          

    // Pagina 02
    Local oGroup    := NIL          
    Local oTGet1    := NIL           
    Local cTGet1    := Space(15) 
    Local oTGet2    := NIL           
    Local cTGet2    := STFGetStation("SERIE")      
    Local cTGet3    := Space(TamSx3("L4_TRNEXID")[1])
    Local oSayCupInv:= NIL
    Local oSayNoTrn := NIL

    // Pagina 03
    Local oTCBrowsePg3              

    Self:cStep1        := ""
    Self:cStep2        := ""
    Self:cStep3        := ""

    Self:DialogWizard := TDialog():New(0,0,495,595,STR0004,,,,,,,,,.T.,,,,,,lTransparent) // 'Rotinas Gerenciais'

    oPanelBkg:= tPanel():New(0,0,"",Self:DialogWizard,,,,,,300,250)
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
 
    // Pagina 1
    oNewPag := oStepWiz:AddStep("1")
    //Altera a descrição do step
    oNewPag:SetStepDescription(Self:cStep1)
    //Define o bloco de construção
    oNewPag:SetConstruction({|Panel|Self:WizardPge1(Panel, @oTCBrowsePg1)})    
    //Define o bloco ao clicar no botão Próximo
     oNewPag:SetNextAction({|| Self:RotinaSelectd(oTCBrowsePg1:nAt, Self:aBranchesPg1)})    
    //Define o bloco ao clicar no botão Cancelar
    oNewPag:SetCancelAction({|| Self:SetRotina(0), Self:EndScreen(Self:DialogWizard)})
    
    // Pagina 2
    oNewPag := oStepWiz:AddStep("2", {|Panel|Self:WizardPge2(Panel, @Self:DialogWizard, @oGroup, @oTGet1, @cTGet1, @oSayCupInv, @oTGet2, @cTGet2, @cTGet3, @oSayNoTrn)})
    oNewPag:SetStepDescription(Self:cStep2)
    oNewPag:SetNextAction({|| Self:RetornaDadosTransacoes(oPanelBkg, oSayCupInv, cTGet1, cTGet2, cTGet3, oSayNoTrn) } )
    oNewPag:SetCancelAction({|| Self:SetRotina(0), Self:EndScreen(Self:DialogWizard)})
    oNewPag:SetPrevWhen({|| .F. })
 
    // Pagina 3
    oNewPag := oStepWiz:AddStep("3", {|Panel|Self:WizardPge3(Panel, @oTCBrowsePg3)})
    oNewPag:SetStepDescription(Self:cStep3)
    oNewPag:SetNextAction( {|| Self:TransacaoRetornaDados(oTCBrowsePg3:nAt), Self:EndScreen(Self:DialogWizard)} )
    oNewPag:SetCancelAction({|| Self:SetRotina(0), Self:EndScreen(Self:DialogWizard) })
    oNewPag:SetPrevWhen({|| .F. })

    oStepWiz:Activate()

    Self:DialogWizard:Activate(Nil,Nil,Nil,.T.)
    oStepWiz:Destroy()
Return
 
/*/{Protheus.doc} WizardPge1
    Metodo responsavel por criar os elementos da pagina 1 no Wizard
    @author JMM
    @since  04/08/2020
/*/
Method WizardPge1(oPanel, oTCBrowse) Class RotinasGerenciaisPaymentHub
    Local nX    := 0    

    oTCBrowse := TCBrowse():New( 000 , 005, 290, 140,, {STR0005},{160}, oPanel,,,,,{||},,,,,,/*cMsg*/,.F.,,.T.,,.F.,,, ) // "Rotina a ser executada"
    
    For nX := 1 To Len(Self:aRotinas) 
        aAdd(Self:aBranchesPg1, {Self:aRotinas[nX][01]} )  
    Next

    oTCBrowse:SetArray( Self:aBranchesPg1 )
    oTCBrowse:bLine := {||	{ Self:aBranchesPg1[oTCBrowse:nAt][1] }} 

Return  
 
/*/{Protheus.doc} WizardPge2
    Metodo responsavel por criar os elementos da pagina 2 no Wizard
    @author JMM
    @since  04/08/2020
/*/
Method WizardPge2( oPanel, DialogWizard, oGroup, oTGet1, cTGet1, oSayCupInv, oTGet2, cTGet2, cTGet3, oSayNoTrn) Class RotinasGerenciaisPaymentHub   

    Local nTipo         := Self:aRotina[02]                                     
    Local aRotinas      := Self:ListRotinas()                                   
    Local cTitulo       := aRotinas[AScan(aRotinas,{|x| x[02] == nTipo })][01]  
    Local oSayCup       := NIL
    Local oSaySer       := NIL
    Local oExtTrnID     := NIL
    Local oTGet3        := NIL
    
    Self:SetRotina(Self:aRotina[02])

    If Self:aRotina[02] == 2
        Self:EndScreen(Self:DialogWizard)
    Else
        Self:cStep2        := STR0006 // "Cupom"
        Self:cStep3        := STR0007 // "Seleção"
        DialogWizard:Refresh()

        oGroup      := TGroup():New(010,010,130,290,cTitulo,oPanel,,CLR_HGRAY,.T.)
        
        oSayCup     := TSay():New(020,015,{||STR0008},oPanel,,Self:oFontBold12,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // 'Digite o código do cupom'
        oTGet1      := TGet():New(030,015,bSetGet(cTGet1),oPanel,100,010,"@!",/*bValid*/,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet1,,,, )
        oSaySer     := TSay():New(020,125,{||"Serie"},oPanel,,Self:oFontBold12,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // "Serie"
        oTGet2      := TGet():New(030,125,bSetGet(cTGet2),oPanel,025,010,"@!",/*bValid*/,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet2,,,, )

        oGroupID    := TGroup():New(050,015,090,280,"Pela Referência",oPanel,,CLR_HGRAY,.T.) // "Pela Referência"
        oExtTrnID   := TSay():New(060,015,{||"Código de Referência"},oPanel,,Self:oFontBold12,,,,.T.,CLR_BLACK,CLR_WHITE,200,20) // "Código de Referência"
        oTGet3      := TGet():New(070,015,bSetGet(cTGet3),oPanel,100,010,"@!",/*bValid*/,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet3,,,, )

        oSayCupInv  := TSay():New(032,160,{||STR0009},oPanel,,Self:oFontBold16,,,,.T.,CLR_RED,CLR_WHITE,200,20) // 'Código inválido'
        oSayCupInv:Hide()

        oSayNoTrn   := TSay():New(090,015,{||STR0018},oPanel,,Self:oFontBold16,,,,.T.,CLR_RED,CLR_WHITE,280,20) // 'Código inválido' // "Não foram encontradas transações ativas para o cupom informado."
        oSayNoTrn:Hide()

        oTGet1:SetFocus()
    EndIf

Return
 
/*/{Protheus.doc} WizardPge3
    Metodo responsavel por criar os elementos da pagina 3 no Wizard
    @author JMM
    @since  04/08/2020
/*/
Method WizardPge3(oPanel, oTCBrowse) Class RotinasGerenciaisPaymentHub
    Local nX            := 0   

    If Len(Self:aDadosTrasacoes) > 0
        oTCBrowse := TCBrowse():New( 000 , 005, 290, 140,, {STR0010, STR0011, STR0013, STR0014, STR0015, STR0019, STR0020},{20,160,10,05,10,20,30}, oPanel,,,,,{||},,,,,,/*cMsg*/,.F.,,.T.,,.F.,,, ) // "Cupom", "Referencia", "Valor", "Forma", "Parcelas", "Data da transação", "Hora da transação", "Data", "Hora"
        
        For nX := 1 To Len(Self:aDadosTrasacoes)        
            aAdd(Self:aBranchesPg3, {   Self:aDadosTrasacoes[nX][01],;                                      //01-Cupom
                                        Self:aDadosTrasacoes[nX][14] + "." + Self:aDadosTrasacoes[nX][12],; //02-NSU - Referencia
                                        Self:aDadosTrasacoes[nX][06],;                                      //03-Valor
                                        Self:aDadosTrasacoes[nX][10],;                                      //04-Forma
                                        Self:aDadosTrasacoes[nX][07],;                                      //05-Parcelas
                                        Self:aDadosTrasacoes[nX][08],;                                      //06-Data da transação
                                        Self:aDadosTrasacoes[nX][09] } )                                    //07-Hora da transação
        Next

        oTCBrowse:SetArray( Self:aBranchesPg3 )
        oTCBrowse:bLine := {|| {    Self:aBranchesPg3[oTCBrowse:nAt][01],;                                          //01-Cupom
                                    Self:aBranchesPg3[oTCBrowse:nAt][02],;                                          //02-NSU - Referencia
                                    Transform(Self:aBranchesPg3[oTCBrowse:nAt][03], PesqPict("SL4", "L4_VALOR") ),; //03-Valor
                                    Self:aBranchesPg3[oTCBrowse:nAt][04],;                                          //04-Forma
                                    Self:aBranchesPg3[oTCBrowse:nAt][05],;                                          //05-Parcela
                                    sToD(Self:aBranchesPg3[oTCBrowse:nAt][06]),;                                    //06-Data da transação
                                    Transform(Self:aBranchesPg3[oTCBrowse:nAt][07],"@R 99:99:99") } }               //07-Hora da transação	
    
    EndIf

Return
