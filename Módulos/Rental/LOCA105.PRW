#Include "Totvs.ch"
#Include "LOCA105.ch" 

/*/{Protheus.doc} LOCA105
@description: Wizard/Facilidador de Implantação Rental
@author Dennis Calabrez
@since 09/09/2025
@version version
/*/
Function LOCA105()
Local oNewPag
Local oStepWiz  := Nil
Local oDlg      := Nil
Local oPanelBkg
local cCombo2  := ''   
Private cFile    := ''
Private cCombo1  := ''
//Private cCombo2  := '' 
Private oChkObj0 
Private lChkObj0  := .F.  
Private cChkObj0  := STR0132  //'Concordar em realizar os cadastros Básicos, Lembrando que deve ser realizado somente em Base/Ambiente de TESTE'
Private oFont1
Private oFont2
Private oFontCabec
Private oBrwTrb
  
    /* Define o tipo e tamanho da fonte */
    Define Font oFont1     Name "Verdana" Size 9,18
    Define Font oFontCabec Name "Verdana" Bold Size 7,18 
    Define Font oFont2     Name "Verdana" Bold Size 20,18 
     
    /* Tela Inicial do Wizard */
    DEFINE DIALOG oDlg TITLE STR0001 PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP ) //'Wizard/Facilidador de Implantação Rental'
 
    /* Define tamanho da Dialog que comportará o Wizard */
    oDlg:nWidth := 1250
    oDlg:nHeight := 650
     
    /* Define o tamanho do painel do Wizard */
    oPanelBkg:= tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
 
    /* Instancia a classe FWWizard */
    oStepWiz:= FWWizardControl():New(oPanelBkg)
    oStepWiz:ActiveUISteps()
 
    //**************************//
    // 1 - Pagina de Introdução //
    //**************************//
    /* Define a página 1 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("1")
 
    /* Altera a descrição do step */
    oNewPag:SetStepDescription(STR0133) //"Escopo" //"Introdução"
 
    /* Define o bloco de construção */
    oNewPag:SetConstruction({|Panel|LOCA105C(Panel)})
 
    /* Define o bloco ao clicar no botão Próximo */
    oNewPag:SetNextAction({|| .T.})
     
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| .T., oDlg:End()})


    //**************************//
    // 2 - Pagina de Escopo     //
    //**************************//
    /* Define a página 1 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("2",{|Panel|LOCA1051(Panel)})
 
    /* Altera a descrição do step */
    oNewPag:SetStepDescription(STR0084) //"Escopo"
 
    /* Define o bloco de construção */
    //oNewPag:SetConstruction({|Panel|LOCA1051(Panel)})
 
    /* Define o bloco ao clicar no botão Próximo */
    oNewPag:SetNextAction({|| .T.})
     
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| .T., oDlg:End()})
 
    //**************************//
    // 3 - Pagina de Cadastros  //
    //**************************//
     
    /* Define a página 2 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("3", {|Panel|LOCA1053(Panel,@cCombo2)})
     
    /* Altera a descrição do step */
    oNewPag:SetStepDescription(STR0002) //"Cadastros"
     
    /* Define o bloco ao clicar no botão Próximo */
    oNewPag:SetNextAction({|| LOCA1054(@cCombo2), .T.})
     
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| .T., oDlg:End()})

     /* Define o que será executado se clicar em Cancelar ou Voltar */
    oNewPag:SetPrevAction({||cCombo1:="", .T.}) //"Não pode voltar a partir daqui"    
     
    /* Define o título da tela anterior */
    //oNewPag:SetPrevTitle("Voltar") 
     
    /* Define se permite cancelar */
    oNewPag:SetCancelWhen({||.T.})

    //**************************//
    // 4 - Pagina de Grupos     //
    //**************************//

    /* Define a página 3 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("4", {|Panel|LOCA1056(Panel)})
     
    /* Altera a descrição do step */
    oNewPag:SetStepDescription(STR0128) //"Parametrização" //"Parâmetros"
     
    /* Define o bloco ao clicar no botão Próximo */
    //oNewPag:SetNextAction({|| LOCA1058(), oDlg:End()})
     oNewPag:SetNextAction({|| .T.})
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| .T., oDlg:End()})
     
    /* Define o que será executado se clicar em Cancelar ou Voltar */
    oNewPag:SetPrevAction({||cCombo1:="", .T.}) //"Não pode voltar a partir daqui"
     
    /* Define o título da tela anterior */
    //oNewPag:SetPrevTitle("Voltar") 

    /* Define se permite cancelar */
    oNewPag:SetCancelWhen({||.T.})      

    //**************************//
    // 5 - Pagina de Menu //
    //**************************//
    /* Define a página 1 com a função de montagem dos objetos */
    oNewPag := oStepWiz:AddStep("5")
 
    /* Altera a descrição do step */
    oNewPag:SetStepDescription(STR0134) //"Escopo" //"Menu"
 
    /* Define o bloco de construção */
    oNewPag:SetConstruction({|Panel|LOCA105D(Panel)})
 
    /* Define o bloco ao clicar no botão Próximo */
    oNewPag:SetNextAction({|| .T.,oDlg:End()})
     
    /* Define o bloco ao clicar no botão Cancelar */
    oNewPag:SetCancelAction({|| .T., oDlg:End()})  

    /* Ativa o Wizard */
    oStepWiz:Activate()
 
    ACTIVATE DIALOG oDlg CENTER
     
    /* Destrói o objeto no fechamento total do Wizard */
    oStepWiz:Destroy()
Return
 
/*/{Protheus.doc} LOCA1051
@description: Setp da escolha do escopo de implantação
@author Dennis Calabrez
@since 09/09/2025
@version version
/*/
Static Function LOCA1051(oPanel)
Local oSay1 
Local oSay2
Local oSay3 
Local oSay4
Local oSay6
Local oCombo1
Local aItens  := {STR0085,STR0087,STR0086} //'P=Pequeno' //'G=Grande' //'M=Médio'
Local oBtn
Local oBtn1
Local oBtn2
Local oBtn3
Local cLink    := "https://tdn.totvs.com/pages/viewpage.action?pageId=636321646"
Local cLink1   := "https://tdn.totvs.com/pages/viewpage.action?pageId=636321658"
Local cLink2   := "https://tdn.totvs.com/pages/viewpage.action?pageId=636321670"
Local bBtnObj0 := {|| LOCA105A()} 
Local bBtnObj1 := {|| ShellExecute("Open", cLink, "", "", 1)} 
Local bBtnObj2 := {|| ShellExecute("Open", cLink1, "", "", 1)} 
Local bBtnObj3 := {|| ShellExecute("Open", cLink2, "", "", 1)} 

    oSay1  := TSay():New(10,10,{||"Este assistente tem como finalidade acelerar a implantação do TOTVS RENTAL, conforme o escopo selecionado"},oPanel,,oFontCabec,,,,.T.,,,600,200) //'Esse Wizad tem como finalidade acelerar a implantação to Totvs RENTAL conforme o escopo selecionado'
 
    //oSay3  := TSay():New(115,10,{||STR0088},oPanel,,oFontCabec,,,,.T.,,,200,20) //'Defina o Escopo'
 
    oSay6  := TSay():New(130,10,{||"Defina o Escopo"},oPanel,,oFont1,,,,.T.,,,120,30) //'Tipo de Escopo: '
    

    oBtn1  := TButton():New(66, 10, STR0135, oPanel, bBtnObj1, 100, 15, , oFont1, , .T.) //"Pequeno (TDN)"
    oSay2  := TSay():New(85,10,{||"Operação realizada exclusivamente por contrato (departamento enxuto)."},oPanel,,oFont1,,,,.T.,,,120,30) //"Escopo operação somente pelo contrato, departamento exuto"

    oBtn2  := TButton():New(66, 200, STR0137, oPanel, bBtnObj2, 100, 15, , oFont1, , .T.) //"Médio (TDN)"
    oSay4  := TSay():New(85,200,{||"Operação por contrato com fluxo logístico e integrações."},oPanel,,oFont1,,,,.T.,,,120,30) //"Escopo operação pelo contrato com fluxo logístico e integrações"

    oBtn3  := TButton():New(66, 370, STR0139, oPanel, bBtnObj3, 100, 15, , oFont1, , .T.) //"Grande (TDN)"
    oSay4  := TSay():New(85,370,{||"Operação completa, incluindo logística, mão de obra (MDO) e integrações."},oPanel,,oFont1,,,,.T.,,,120,30) //"Espoco operação completo, logística ,MDO e integrações "

    oCombo1 := TComboBox():New(140,10,{|u|if(PCount() > 0, cCombo1 := u,cCombo1)},aItens,120,10,oPanel,,{||.T.},,,,.T.,,,,,,,,,STR0141) //'cCombo1'

    oBtn  := TButton():New(160, 10, "Exportar Parâmetros", oPanel, bBtnObj0, 100, 15, , oFont1, , .T.) //"Imprime os Parâmetros"
    
Return ( Nil )
 
/*/{Protheus.doc} LOCA1053
@description: Geração dos Cadastros
@author Dennis Calabrez
@since 09/00/2025
@version version
/*/
Static Function LOCA1053(oPanel,cCombo2)
Local oSay
Local oSay1
Local oSay2
Local oSay3
Local oCombo2
Local aCombo := {STR0108,STR0109} //"N=NÃO" //"S=SIM"
 
    oSay  := TSay():New(05,20,{||STR0004},oPanel,,oFontCabec,,,,.T.,,,400,20) //'Nesse passo será realizado so cadasatros básicos do Rental'
    oSay1 := TSay():New(15,20,{||"Necessário escolher se vai desejar cadastrar ou não, realizar somente em base/ambiente de testes"},oPanel,,oFontCabec,,,,.T.,,,400,20)  //"Necessário escolher se vai desejar cadastrar ou não, sugerido realizar em base/ambiente de testes"

    oSay3 := TSay():New(30,20,{||STR0143},oPanel,,oFontCabec,,,,.T.,CLR_RED,CLR_WHITE,400,250) //"SOMENTE EXECUTAR EM BASE/AMBIENTE DE TESTES"

    oSay2 := TSay():New(66,10,{|| "Deseja executar os cadastros básicos?"},oPanel,,oFont1,,,,.T.,,,140,30)  //"Deseja excutar os cadastros básicos?"

    oCombo2 := TComboBox():New(66,140,{|u|if(PCount() > 0, cCombo2 := u,cCombo2)},aCombo,050,10,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo2')

    oChkObj0  := TCheckBox():New(90, 10, cChkObj0, {|u| Iif(PCount() > 0 , lChkObj0 := u, lChkObj0)}, oPanel, 400, 250, , /*{||LOCA1054()}*/, , /*{||LOCA1054()}*/, /*nClrText*/, /*nClrPane*/, , .T.)       
              
Return ( Nil )
 
/*/{Protheus.doc} LOCA1054
@description: Processamento dos Cadastros
@author Dennis Calabrez
@since 09/09/2025
@version version
/*/
Static Function LOCA1054(cCombo2)
Local oSay
Local lRet := .F.

    If cCombo2 == "S" .AND. lChkObj0//Se executa os cadastros básico do Rental
        If MSGYESNO(STR0144,STR0145) //"Tem certeza que deseja realizar os cadastros?" //"Wizard RENTAL"
            FWMsgRun(, {|oSay| LOCA1055(oSay) }, STR0005, STR0006) //"Processando" //"Processando os cadastros Totvs Rental"
             lRet := .T.    
        EndIf 
    ElseIf cCombo2 == "N"
        lRet := .T.                    
    Else 
        alert(STR0146)                              
    EndIf     

Return lRet

/*/{Protheus.doc} LOCA1055
@description: Gravação dos Cadastros
@author Dennis Calabrez
@since 09/09/2025
@version version
/*/
Static Function LOCA1055(oSay)
Local nI       := 0
Local nY       := 0
Local nX       := 0
Local nJ       := 0
Local cComando := ""
Local lCli     := .T.//Cliente
Local lFor     := .T.//Fornecedor
Local lFam     := .T.//Familia
Local lTip     := .T.//Tipo Modelo
Local lTur     := .T.//Turnos
Local lStr     := .T.//Status Rental
Local lStm     := .T.//Status MNT
Local lProd    := .T.//Produto
Local lMot     := .T.//Motorista
Local lVeic    := .T.//Veiculo
Local lCent    := .T.//Centro de Custo
Local lCond    := .T.//Condição de pagamento
Local lNat     := .T.//Natureza Financeira
Local lTes     := .T.//TES - Tipos de Entrada e Saída
Local lBem     := .T.//Bem
//Variáveis boleanas para o cadastro de Status Rental
Local lPrim    := .T.
Local lSegu    := .T.
Local lTerc    := .T.
Local lQuar    := .T.
Local lQuin    := .T.
Local lSext    := .T.
Local lSeti    := .T.
//Variáveis boleanas para o cadastro de Status MNT
Local lPri     := .T.
Local lSeg     := .T.
Local lTer     := .T.
Local lQua     := .T.
Local lQui     := .T.
Local lSex     := .T.
//Variáveis boleanas para o cadastro de Centro de Custo e Naturezas e TES
Local lUm      := .T.
Local lDois    := .T.
Local lTres    := .T.
Local lQuat    := .T.
Local cArqLog  := STR0090 + dToS(Date()) + STR0091 + StrTran(Time(), ':', '-') + ".log" //"WIZRENTAL_" //"_"

Private cDirLog := STR0092//GetTempPath() + "x_importacao\" //"C:\RENTAL\"
Private cLog    := ""

    If ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIf

    oSay:SetText(STR0007) //"Iniciando processamento..."
    ProcessMessages()
    Sleep(2000)

    For nI := 1 to 15
         
         If lCli//1
            oSay:SetText(STR0009  + STR0008) //"..." //"Cadastrando Cliente "
            ProcessMessages()
            Sleep(2000)
            If SA1->(dbSeek(xFilial("SA1")+"RENTAL"))
                cLog += STR0010+ CRLF + CRLF //"Cliente RENTAL já cadastrado"
                lCli := .F.
                Loop
            EndIf              
            RecLock("SA1", .T.)     
            SA1->A1_FILIAL := xFilial("SA1")            
            SA1->A1_COD := "RENTAL"
            SA1->A1_LOJA := "01"
            SA1->A1_NOME := "CLIENTE RENTAL IMPLANTAÇÃO"
            SA1->A1_NREDUZ := "RENTAL"
            SA1->A1_TIPO := "F"
            SA1->A1_EST := "SP"
            SA1->A1_COD_MUN := "50308"
            SA1->A1_MUN := "SÃO PAULO"
            SA1->(MsUnlock()) 
            lCli := .F.
            cLog += STR0093 + CRLF //"Cliente:"
            cLog += STR0011+ CRLF + CRLF //"Código: RENTAL - Loja: 01 cadastrado com sucesso"
        EndIf  

         If lFor//2
             oSay:SetText(STR0012  + STR0008) //"..." //"Cadastrando Fornecedor "
             ProcessMessages()
             Sleep(2000)
            If SA2->(dbSeek(xFilial("SA2")+"RENTAL"))
                cLog += STR0013 + CRLF + CRLF//"Fornecedor RENTAL já cadastrado"
                lFor := .F.
                Loop
            EndIf              
            RecLock("SA2", .T.)   
            SA2->A2_FILIAL := xFilial("SA2")                
            SA2->A2_COD := "RENTAL"
            SA2->A2_LOJA := "01"
            SA2->A2_NOME := "CLIENTE RENTAL IMPLANTAÇÃO"
            SA2->A2_NREDUZ := "RENTAL"
            SA2->A2_TIPO := "F"
            SA2->A2_EST := "SP"
            SA2->A2_COD_MUN := "50308"
            SA2->A2_MUN := "SÃO PAULO"
            SA2->(MsUnlock()) 
            lFor := .F.
            cLog += STR0094 + CRLF //"Fornecedor:"
            cLog += STR0014+ CRLF + CRLF //"Fornecedor Código - RENTAL/Loja - 01 cadastrado com sucesso"
        EndIf 

         If lFam//3
             oSay:SetText(STR0015  + STR0008) //"..." //"Cadastrando Familia "
             ProcessMessages()
             Sleep(2000)
            If ST6->(dbSeek(xFilial("ST6")+STR0095)) //"001LOC"
                cLog += STR0016 + CRLF + CRLF//"Familia 001LOC já cadastrada"
                lFam := .F.
                Loop
            EndIf    
            RecLock("ST6", .T.)   
            ST6->T6_FILIAL := xFilial("ST6")                
            ST6->T6_CODFAMI := "001LOC"
            ST6->T6_NOME := "FAMILIA SIGALOC"
            ST6->T6_PERLOCA := "1"
            ST6->T6_MOVIBEM := "S"
            ST6->T6_TIPOFAM := "1"
            ST6->T6_SINCRON := "1"
            ST6->(MsUnlock()) 
            lFam := .F.
            cLog += STR0096 + CRLF //"Familia:"
            cLog += STR0017+ CRLF + CRLF //"Código: 001LOC cadastrada com sucesso"
        EndIf 

         If lTip//4
             oSay:SetText(STR0018  + STR0008) //"..." //"Cadastrando Modelo "
             ProcessMessages()
             Sleep(2000)
            If TQR->(dbSeek(xFilial("TQR")+"0000000001"))
                cLog +=STR0019+ CRLF + CRLF //"Tipo Modelo 0000000001 já cadastrado"
                lTip := .F.
                Loop
            EndIf    
            RecLock("TQR", .T.)   
            TQR->TQR_FILIAL := xFilial("TQR")                
            TQR->TQR_TIPMOD := "0000000001"
            TQR->TQR_DESMOD := "MODELO SIGALOC"
            TQR->(MsUnlock()) 
            lTip := .F.
            cLog += STR0097 + CRLF //"Tipo Modelo:"
            cLog += STR0020+ CRLF + CRLF //"Código: 0000000001 cadastrado com sucesso"
        EndIf 

         If lTur//5
             oSay:SetText(STR0021  + STR0008) //"..." //"Cadastrando Turno "
             ProcessMessages()
             Sleep(2000)
            If SH7->(dbSeek(xFilial("SH7")+"000"))
                cLog +=  STR0022 + CRLF + CRLF //"Turno 000 já cadastrado"
                lTur := .F.
                Loop
            EndIf    
            RecLock("SH7", .T.)   
            SH7->H7_FILIAL := xFilial("SH7")                
            SH7->H7_CODIGO := "000"
            SH7->H7_ALOC   := "                                XXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXX                                                          XXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXX                                                          XXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXX                                                          XXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXX                                                          XXXXXXXXXXXXXXXX      XXXXXXXXXXXXXXXX                                                                                                                                                                                                                          "
            SH7->H7_DESCRI := "CALENDARIO RENTAL"
            SH7->(MsUnlock()) 
            cLog += STR0098 + CRLF //"Tunro:"
            cLog += STR0023+ CRLF + CRLF //"Código: 000 cadastrado com sucesso"
            lTur := .F.
        EndIf    

         If lStr//6
             oSay:SetText(STR0024  + STR0008) //"..." //"Cadastrando Status Rental "
             ProcessMessages()
             Sleep(2000)
             For nY := 1 to 7  
                If lPrim
                    cLog += STR0099 + CRLF //"Status Rental:"
                    If FQD->(dbSeek(xFilial("FQD")+"00"+"00"))
                        cLog +=STR0025 + CRLF//"Status Renal 00 já cadastrado"
                        lPrim := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "00"
                    FQD->FQD_STATQY := "00"
                    FQD->FQD_DESTQY := "DISPONIVEL"
                    FQD->(MsUnlock()) 
                    cLog += STR0026+ CRLF //"00 cadastrado com sucesso"
                    lPrim := .F.
                EndIf
                If lSegu
                    If FQD->(dbSeek(xFilial("FQD")+"10"+"10"))
                        cLog +=STR0027 + CRLF //"Status Renal 10 já cadastrado"
                        lSegu := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "10"
                    FQD->FQD_STATQY := "10"
                    FQD->FQD_DESTQY := "CONTRATO GERADO"
                    FQD->(MsUnlock()) 
                    cLog += STR0028+ CRLF //"10 cadastrado com sucesso"
                    lSegu := .F.
                EndIf 
                If lTerc
                    If FQD->(dbSeek(xFilial("FQD")+"20"+"20"))
                        cLog +=STR0029 + CRLF //"Status Renal 20 já cadastrado"
                        lTerc := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "20"
                    FQD->FQD_STATQY := "20"
                    FQD->FQD_DESTQY := "NF DE REMESSA GERADA"
                    FQD->(MsUnlock()) 
                    cLog += STR0030+ CRLF //"20 cadastrado com sucesso"
                    lTerc := .F.
                EndIf
                If lQuar
                    If FQD->(dbSeek(xFilial("FQD")+"50"+"50"))
                        cLog +=STR0031+ CRLF  //"Status Renal 50 já cadastrado"
                        lQuar := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "50"
                    FQD->FQD_STATQY := "50"
                    FQD->FQD_DESTQY := "RETORNO DE LOCACAO"
                    FQD->(MsUnlock()) 
                    cLog += STR0032+ CRLF //"50 cadastrado com sucesso"
                    lQuar := .F.
                EndIf 
                If lQuin
                    If FQD->(dbSeek(xFilial("FQD")+"60"+"60"))
                        cLog += STR0033+ CRLF //"Status Renal 60 já cadastrado"
                        lQuin := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "60"
                    FQD->FQD_STATQY := "60"
                    FQD->FQD_DESTQY := "NF DE RETORNO GERADA"
                    FQD->(MsUnlock()) 
                    cLog += STR0034+ CRLF //"60 cadastrado com sucesso"
                    lQuin := .F.
                EndIf 
                If lSext
                    FQD->(dbsetorder(2))
                    If FQD->(dbSeek(xFilial("FQD")+" "))
                        cLog += STR0035+ CRLF //"Status Renal 00(Minuta) já cadastrado"
                        lSext := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "00"
                    FQD->FQD_STATQY := ""
                    FQD->FQD_DESTQY := "MINUTA"
                    FQD->(MsUnlock()) 
                    cLog += STR0036+ CRLF //"00(Minuta) cadastrado com sucesso"
                    lSext := .F.
                EndIf   
                If lSeti
                    If FQD->(dbSeek(xFilial("FQD")+"70"+"70"))
                        cLog +=STR0037+ CRLF //"Status Renal 70 já cadastrado"
                        lSeti := .F.
                        Loop
                    EndIf                 
                    RecLock("FQD", .T.)   
                    FQD->FQD_FILIAL := xFilial("FQD")                
                    FQD->FQD_STAREN := "70"
                    FQD->FQD_STATQY := "70"
                    FQD->FQD_DESTQY := "MANUTENCAO"
                    FQD->(MsUnlock()) 
                    cLog += STR0038+ CRLF + CRLF //"70 cadastrado com sucesso"
                    lSeti := .F.
                EndIf                                                                                              
             Next nY     
            lStr := .F.
        EndIf      

         If lStm//7
             oSay:SetText(STR0039  + STR0008) //"..." //"Cadastrando Status Manutenção de Ativos "
             ProcessMessages()
             Sleep(2000)
             For nX := 1 to 7  
                If lPri
                    cLog += STR0100 + CRLF //"Status MNT:"
                    If TQY->(dbSeek(xFilial("TQY")+"00"))
                        cLog +=STR0040+ CRLF //"Status MNT 00 já cadastrado"
                        lPri := .F.
                        Loop
                    EndIf                 
                    RecLock("TQY", .T.)   
                    TQY->TQY_FILIAL := xFilial("TQY")                
                    TQY->TQY_STATUS := "00"
                    TQY->TQY_DESTAT := "DISPONIVEL"
                    TQY->TQY_CATBEM := "1"
                    TQY->(MsUnlock()) 
                    cLog += STR0026+ CRLF //"00 cadastrado com sucesso"
                    lPri := .F.
                EndIf
                If lSeg
                    If TQY->(dbSeek(xFilial("TQY")+"10"))
                        cLog +=STR0041+ CRLF //"Status MNT 10 já cadastrado"
                        lSeg := .F.
                        Loop
                    EndIf                 
                    RecLock("TQY", .T.)   
                    TQY->TQY_FILIAL := xFilial("TQY")                
                    TQY->TQY_STATUS := "10"
                    TQY->TQY_DESTAT := "CONTRATO GERADO"
                    TQY->TQY_CATBEM := "1"
                    TQY->(MsUnlock()) 
                    cLog += STR0028+ CRLF //"10 cadastrado com sucesso"
                    lSeg := .F.
                EndIf 
                If lTer
                    If TQY->(dbSeek(xFilial("TQY")+"20"))
                        cLog +=STR0042+ CRLF //"Status MNT 20 já cadastrado"
                        lTer := .F.
                        Loop
                    EndIf                 
                    RecLock("TQY", .T.)   
                    TQY->TQY_FILIAL := xFilial("TQY")                
                    TQY->TQY_STATUS := "20"
                    TQY->TQY_DESTAT := "NF DE REMESSA GERADA"
                    TQY->TQY_CATBEM := "1"
                    TQY->(MsUnlock()) 
                    cLog += STR0030+ CRLF //"20 cadastrado com sucesso"
                    lTer := .F.
                EndIf
                If lQua
                    If TQY->(dbSeek(xFilial("TQY")+"50"))
                        cLog += STR0043+ CRLF //"Status MNT 50 já cadastrado"
                        lQua := .F.
                        Loop
                    EndIf                 
                    RecLock("TQY", .T.)   
                    TQY->TQY_FILIAL := xFilial("TQY")                
                    TQY->TQY_STATUS := "50"
                    TQY->TQY_DESTAT := "RETORNO DE LOCACAO"
                    TQY->TQY_CATBEM := "1"
                    TQY->(MsUnlock()) 
                    cLog += STR0032+ CRLF //"50 cadastrado com sucesso"
                    lQua := .F.
                EndIf 
                If lQui
                    If TQY->(dbSeek(xFilial("TQY")+"60"))
                        cLog +=STR0044+ CRLF //"Status MNT 60 já cadastrado"
                        lQui := .F.
                        Loop
                    EndIf                 
                    RecLock("TQY", .T.)   
                    TQY->TQY_FILIAL := xFilial("TQY")                
                    TQY->TQY_STATUS := "60"
                    TQY->TQY_DESTAT := "NF DE RETORNO GERADA"
                    TQY->TQY_CATBEM := "1"
                    TQY->(MsUnlock()) 
                    cLog += STR0034+ CRLF //"60 cadastrado com sucesso"
                    lQui := .F.
                EndIf 
                If lSex
                    If TQY->(dbSeek(xFilial("TQY")+"70"))
                        cLog +=STR0045+ CRLF //"Status MNT 70 já cadastrado"
                        lSex := .F.
                        Loop
                    EndIf                 
                    RecLock("TQY", .T.)   
                    TQY->TQY_FILIAL := xFilial("TQY")                
                    TQY->TQY_STATUS := "70"
                    TQY->TQY_DESTAT := "MANUTANCAO"
                    TQY->TQY_CATBEM := "1"
                    TQY->(MsUnlock()) 
                    cLog += STR0038+ CRLF + CRLF //"70 cadastrado com sucesso"
                    lSex := .F.
                EndIf   

             Next nX     
            lStm := .F.
        EndIf 

         If lProd//8
             oSay:SetText(STR0046  + STR0008) //"..." //"Cadastrando Produto "
             ProcessMessages()
             Sleep(2000)
            If SB1->(dbSeek(xFilial("SB1")+"000LOC1"))
                cLog +=STR0047+ CRLF //"Produto 000LOC1 já cadastrado"
                lProd := .F.
                Loop
            EndIf    
            RecLock("SB1", .T.)   
            SB1->B1_FILIAL := xFilial("SB1")                
            SB1->B1_COD    := "000LOC1"
            SB1->B1_DESC   := "PRODUTO LOCAÇÃO"
            SB1->B1_TIPO   := "AI"
            SB1->B1_UM     := "UN
            SB1->B1_LOCPAD := "90""
            SB1->(MsUnlock()) 
            cLog += STR0101 + CRLF //"Produto:"
            cLog += STR0048+ CRLF + CRLF //"Código: 000LOC1 cadastrado com sucesso"
            lProd := .F.
        EndIf   

         If lMot//9
             oSay:SetText(STR0049  + STR0008) //"..." //"Cadastrando Motorista "
             ProcessMessages()
             Sleep(2000)
            If DA4->(dbSeek(xFilial("DA4")+"000001"))
                cLog +=STR0050+ CRLF //"Motorista 000001 já cadastrado"
                lMot := .F.
                Loop
            EndIf    
            RecLock("DA4", .T.)   
            DA4->DA4_FILIAL := xFilial("DA4")                
            DA4->DA4_COD    := "000001"
            DA4->DA4_NOME   := "MOTORISTA LOCAÇÃO"
            DA4->DA4_NREDUZ := "MOTORISTA LOCAÇÃO"
            DA4->(MsUnlock()) 
            cLog += STR0051 + CRLF //"Motorista:"
            cLog += STR0052+ CRLF + CRLF //"Código: 000001 cadastrado com sucesso"
            lMot := .F.
        EndIf

         If lVeic//10
             oSay:SetText(STR0053  + STR0008) //"..." //"Cadastrando Veiculo "
             ProcessMessages()
             Sleep(2000)
            If DA3->(dbSeek(xFilial("DA3")+"000001"))
                cLog +=STR0054 + CRLF  //"Veiculo 000001 já cadastrado"
                lVeic := .F.
                Loop
            EndIf    
            RecLock("DA3", .T.)   
            DA3->DA3_FILIAL := xFilial("DA3")                
            DA3->DA3_COD    := "000001"
            DA3->DA3_DESC   := "VEICULO TERCEROS"
            DA4->(MsUnlock()) 
            cLog += STR0055 + CRLF //"Veiculo:"
            cLog += STR0052+ CRLF + CRLF //"Código: 000001 cadastrado com sucesso"
            lVeic := .F.
        EndIf 

         If lCent//11
             oSay:SetText(STR0056  + STR0008) //"..." //"Cadastrando Centro de Custo "
             ProcessMessages()
             Sleep(2000)
             For nJ := 1 to 4  
                If lUm
                    cLog += STR0057 + CRLF //"Centro de Custo:"
                    If CTT->(dbSeek(xFilial("CTT")+"COMERCIAL"))
                        cLog +=  STR0058+ CRLF //"Centro de Custo COMERCIAL já cadastrado"
                        lUm := .F.
                        Loop
                    EndIf                 
                    RecLock("CTT", .T.)   
                    CTT->CTT_FILIAL := xFilial("CTT")                
                    CTT->CTT_CUSTO := "COMERCIAL"
                    CTT->CTT_CLASSE := "2"
                    CTT->CTT_DESC01 := "COMERCIAL"
                    CTT->(MsUnlock()) 
                    cLog += STR0059+ CRLF //"COMERCIAL cadastrado com sucesso"
                    lUm := .F.
                EndIf
                If lDois
                    If CTT->(dbSeek(xFilial("CTT")+"OPERACION"))
                        cLog +=STR0060 + CRLF//"Centro de Custo OPERACIONAL já cadastrado"
                        lDois := .F.
                        Loop
                    EndIf                 
                    RecLock("CTT", .T.)   
                    CTT->CTT_FILIAL := xFilial("CTT")                
                    CTT->CTT_CUSTO := "OPERACION"
                    CTT->CTT_CLASSE := "2"
                    CTT->CTT_DESC01 := "OPERACIONAL"
                    CTT->(MsUnlock()) 
                    cLog += STR0061+ CRLF //"OPERACIONAL cadastrado com sucesso"
                    lDois := .F.
                EndIf
                If lTres
                    If CTT->(dbSeek(xFilial("CTT")+"ADMINISTR"))
                        cLog +=STR0062+ CRLF  //"Centro de Custo ADMINISTRACAO já cadastrado"
                        lTres := .F.
                        Loop
                    EndIf                 
                    RecLock("CTT", .T.)   
                    CTT->CTT_FILIAL := xFilial("CTT")                
                    CTT->CTT_CUSTO := "ADMINISTR"
                    CTT->CTT_CLASSE := "2"
                    CTT->CTT_DESC01 := "ADMINISTRACAO"
                    CTT->(MsUnlock()) 
                    cLog += STR0063+ CRLF //"ADMINISTRACAO cadastrado com sucesso"
                    lTres := .F.
                EndIf
                If lQuat
                    If CTT->(dbSeek(xFilial("CTT")+"RH"))
                        cLog += STR0064+ CRLF //"Centro de Custo RH já cadastrado"
                        lTres := .F.
                        Loop
                    EndIf                 
                    RecLock("CTT", .T.)   
                    CTT->CTT_FILIAL := xFilial("CTT")                
                    CTT->CTT_CUSTO := "RH"
                    CTT->CTT_CLASSE := "2"
                    CTT->CTT_DESC01 := "RH"
                    CTT->(MsUnlock()) 
                    cLog += STR0065+ CRLF + CRLF //"RH cadastrado com sucesso"
                    lQuat := .F.
                EndIf   

             Next nJ     
            lCent  := .F.
            lUm    := .T.
            lDois  := .T.
            lTres  := .T.
            lQuat  := .T.  
            nJ     := 0          
        EndIf  

         If lCond//12
             oSay:SetText(STR0066  + STR0008) //"..." //"Cadastrando Condição de Pagamento "
             ProcessMessages()
             Sleep(2000)
            If SE4->(dbSeek(xFilial("SE4")+"000"))
                cLog +=STR0067+ CRLF //"Condição de Pagamento 000 já cadastrada"
                lCond := .F.
                Loop
            EndIf    
            RecLock("SE4", .T.)   
            SE4->E4_FILIAL := xFilial("SE4")                
            SE4->E4_CODIGO    := "000"
            SE4->E4_TIPO   := "1"
            SE4->E4_COND   := "00"
            SE4->E4_DESCRI   := "A VISTA"
            SE4->E4_MSBLQL   := "2"
            SE4->E4_CCORREN   := "2"
            SE4->(MsUnlock()) 
            cLog += STR0102 + CRLF //"Condição de Pagamento:"
            cLog += STR0068+ CRLF + CRLF //"Código: 000 cadastrada com sucesso"
            lCond := .F.
        EndIf 

         If lNat//13
             oSay:SetText(STR0069  + STR0008) //"..." //"Cadastrando Naturezas Financeiras "
             ProcessMessages()
             Sleep(2000)
             For nJ := 1 to 2  
                If lUm
                    cLog += STR0103 + CRLF //"Natureza Financeira"
                    If SED->(dbSeek(xFilial("SED")+"RENTAL    "))
                        cLog +=STR0070+ CRLF //"Natureza RENTAL já cadastrada"
                        lUm := .F.
                        Loop
                    EndIf                 
                    RecLock("SED", .T.)   
                    SED->ED_FILIAL := xFilial("SED")                
                    SED->ED_CODIGO := "RENTAL"
                    SED->ED_DESCRIC := "REMESSA"
                    SED->ED_CALCIRF := "N"
                    SED->ED_CALCISS := "N"
                    SED->ED_CALCINS := "N"
                    SED->ED_CALCCSL := "N"
                    SED->ED_CALCCOF := "N"
                    SED->ED_DEDPIS := "N"
                    SED->ED_DEDCOF := "N"
                    SED->ED_TIPO := "2"
                    SED->(MsUnlock()) 
                    cLog += STR0071+ CRLF //"RENTAL cadastrada com sucesso"
                    lUm := .F.
                EndIf
                If lDois
                    If SED->(dbSeek(xFilial("SED")+"RENTAL2"))
                        cLog +=STR0072+ CRLF //"Natureza RENTAL2 já cadastrada"
                        lDois := .F.
                        Loop
                    EndIf                 
                    RecLock("SED", .T.)   
                    SED->ED_FILIAL := xFilial("SED")                
                    SED->ED_CODIGO := "RENTAL2"
                    SED->ED_DESCRIC := "LOCACAO"
                    SED->ED_CALCIRF := "N"
                    SED->ED_CALCISS := "N"
                    SED->ED_CALCINS := "N"
                    SED->ED_CALCCSL := "N"
                    SED->ED_CALCCOF := "N"
                    SED->ED_DEDPIS := "N"
                    SED->ED_DEDCOF := "N"
                    SED->ED_TIPO := "2"
                    SED->(MsUnlock()) 
                    cLog += STR0073+ CRLF + CRLF //"RENTAL2 cadastrada com sucesso"
                    lDois := .F.
                EndIf

             Next nJ     
            lNat := .F.
            lUm    := .T.
            lDois  := .T.
            lTres  := .T.
            lQuat  := .T.  
            nJ := 0          
        EndIf 

         If lTes//14
             oSay:SetText(STR0074  + STR0008) //"..." //"Cadastrando Tipo de Entrada e Saída (TES) "
             ProcessMessages()
             Sleep(2000)
             For nJ := 1 to 3  
                If lUm
                    cLog += STR0104 + CRLF //"Tipos de Entrada e Saída (TES)"
                    If SF4->(dbSeek(xFilial("SF4")+"001"))
                        cLog += STR0075+ CRLF //"Tipo de Entrada e Saída (TES) 001 já cadastrada"
                        lUm := .F.
                        Loop
                    EndIf                 
                    RecLock("SF4", .T.)   
                    SF4->F4_FILIAL := xFilial("SF4") 
                    SF4->F4_CODIGO := "001"          
                    SF4->F4_TIPO := "E"                         
                    SF4->F4_CREDICM := "N"                      
                    SF4->F4_CREDIPI := "N"            
                    SF4->F4_DUPLIC := "S"                     
                    SF4->F4_ESTOQUE := "S"         
                    SF4->F4_PODER3 := "N"                     
                    SF4->F4_ICM := "N"          
                    SF4->F4_IPI := "N"              
                    SF4->F4_CF := "1908"            
                    SF4->F4_TEXTO := "RETORNO LOCACAO"           
                    SF4->F4_LFICM := "N"                
                    SF4->F4_LFIPI := "N"            
                    SF4->F4_DESTACA := "N"                
                    SF4->F4_INCIDE := "N"              
                    SF4->F4_COMPL := "N" 
                    SF4->(MsUnlock()) 
                    cLog += STR0076+ CRLF //"RETORNO cadastrada com sucesso"
                    lUm := .F.
                EndIf
                If lDois
                    If SF4->(dbSeek(xFilial("SF4")+"600"))
                        cLog +=STR0077+ CRLF //"Tipo de Entrada e Saída (TES) 600 já cadastrada"
                        lDois := .F.
                        Loop
                    EndIf                 
                    RecLock("SF4", .T.)   
                    SF4->F4_FILIAL := xFilial("SF4") 
                    SF4->F4_CODIGO := "600"          
                    SF4->F4_TIPO := "E"                         
                    SF4->F4_CREDICM := "N"                      
                    SF4->F4_CREDIPI := "N"            
                    SF4->F4_DUPLIC := "S"                     
                    SF4->F4_ESTOQUE := "S"         
                    SF4->F4_PODER3 := "N"                     
                    SF4->F4_ICM := "N"          
                    SF4->F4_IPI := "N"              
                    SF4->F4_CF := "5102"            
                    SF4->F4_TEXTO := "FATURAMENTO"           
                    SF4->F4_LFICM := "N"                
                    SF4->F4_LFIPI := "N"            
                    SF4->F4_DESTACA := "N"                
                    SF4->F4_INCIDE := "N"              
                    SF4->F4_COMPL := "N" 
                    SF4->(MsUnlock()) 
                    cLog += STR0078+ CRLF //"FATURAMENTO cadastrada com sucesso"
                    lDois := .F.
                EndIf
                If lTres
                    If SF4->(dbSeek(xFilial("SF4")+"501"))
                        cLog +=STR0105+ CRLF //"Tipo de Entrada e Saída (TES) 501 já cadastrada"
                        lTres := .F.
                        Loop
                    EndIf                 
                    RecLock("SF4", .T.)   
                    SF4->F4_FILIAL := xFilial("SF4") 
                    SF4->F4_CODIGO := "501"          
                    SF4->F4_TIPO := "E"                         
                    SF4->F4_CREDICM := "N"                      
                    SF4->F4_CREDIPI := "N"            
                    SF4->F4_DUPLIC := "S"                     
                    SF4->F4_ESTOQUE := "S"         
                    SF4->F4_PODER3 := "N"                     
                    SF4->F4_ICM := "N"          
                    SF4->F4_IPI := "N"              
                    SF4->F4_CF := "5908"            
                    SF4->F4_TEXTO := "REMESSA"           
                    SF4->F4_LFICM := "N"                
                    SF4->F4_LFIPI := "N"            
                    SF4->F4_DESTACA := "N"                
                    SF4->F4_INCIDE := "N"              
                    SF4->F4_COMPL := "N" 
                    SF4->(MsUnlock()) 
                    cLog += STR0079+ CRLF + CRLF //"RENESSA cadastrada com sucesso"
                    lTres := .F.
                EndIf                

             Next nJ     
            lTes := .F.
            lUm    := .T.
            lDois  := .T.
            lTres  := .T.
            lQuat  := .T.  
            nJ := 0          
        EndIf  

         If lBem//15
             oSay:SetText(STR0080  + STR0008) //"..." //"Cadastrando Bem "
             ProcessMessages()
             Sleep(2000)
            If ST9->(dbSeek(xFilial("ST9")+"00001LOC"))
                cLog +=STR0081+ CRLF //"Produto 00001LOC já cadastrado"
                lBem := .F.
                Loop
            EndIf    
            RecLock("ST9", .T.)   
            ST9->T9_FILIAL := xFilial("ST9") 
            ST9->T9_CODBEM := "00001LOC"
            ST9->T9_TIPMOD := "0000000001"
            ST9->T9_CODFAMI := "001LOC"
            ST9->T9_NOME := "BEM TESTE"
            ST9->T9_STATUS := "00"
            ST9->T9_CALENDA := "000"
            ST9->T9_CCUSTO := "COMERCIAL"
            ST9->T9_VALCPA := 1000.00
            ST9->T9_CODESTO := "000LOC1"
            ST9->(MsUnlock()) 
            cLog += "BEM:" + CRLF
            cLog += STR0082+ CRLF + CRLF //"BEM: 00001LOC cadastrado com sucesso"
            lBem := .F.
        EndIf                                                 

    Next nI

    //Se tiver log, mostra ele
    If ! Empty(cLog)
        cLog := STR0083 + CRLF + CRLF + cLog //"Processamento concluído."
        cComando:= "MemoWrite(cDirLog + cArqLog, cLog)"
        &(cComando)
        ShellExecute("OPEN", cArqLog, "", cDirLog, 1)
    EndIf    
Return ()

/*/{Protheus.doc} LOCA1056
@description: Parâmetros escopo Pequeno/Médio/Grande
@author Dennis Calabrez
@since 15/09/2025
@version version
/*/ 
Static Function LOCA1056(oPanel)
Local oBtn
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5
Local oBtn6
Local bBtnObj0 := {|| LOCA106(cCombo1)} 
Local bBtnObj1 := {|| MsgInfo("Escopo operação somente pelo contrato, departamento exuto")} 
Local bBtnObj2 := {|| LOCA105A()} 
Local bBtnObj3 := {|| LOCA1063(cCombo1)} 
Local bBtnObj4 := {|| LOCA1066(cCombo1)}
Local bBtnObj5 := {|| LOCA106A(cCombo1)}
Local bBtnObj6 := {|| LOCA106D(cCombo1)}
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5

    If cCombo1 == "P"
        oBtn1  := TButton():New(20, 50, STR0147, oPanel, bBtnObj1, 500, 15, , oFont1, , .T.) //"Pequeno"
    EndIf
    If cCombo1 == "M"
        oBtn1 := Nil 
        oBtn1  := TButton():New(20, 50, STR0148, oPanel, bBtnObj1, 500, 15, , oFont1, , .T.) //"Médio"
    EndIf
    If cCombo1 == "G"
        oBtn1 := Nil 
        oBtn1  := TButton():New(20, 50, STR0149, oPanel, bBtnObj1, 500, 15, , oFont1, , .T.) //"Grande"
    EndIf

    oSay1  := TSay():New(52,120,{||STR0150},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Determinações imprescendíveis para o Funcionamento do Rental"

    oBtn   := TButton():New(50, 10, STR0151, oPanel, bBtnObj0, 100, 15, , oFont1, , .T.) //"Basicos"

    oSay2  := TSay():New(82,120,{||STR0152},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Determinações imprescendíveis para o Faturamento do Rental processar"

    oBtn2  := TButton():New(80, 10, STR0153, oPanel, bBtnObj3, 100, 15, , oFont1, , .T.) //"Faturamento"

    oSay3  := TSay():New(112,120,{||STR0154},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Determinações imprescendíveis para o Logístico do Rental processar"

    oBtn3  := TButton():New(110, 10, STR0155, oPanel, bBtnObj4, 100, 15, , oFont1, , .T.) //"Logístico"

    oSay4  := TSay():New(142,120,{||STR0156},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Determinações imprescendíveis para as Integrações do Rental"

    oBtn4  := TButton():New(140, 10, STR0157, oPanel, bBtnObj5, 100, 15, , oFont1, , .T.) //"Integrações"

    If cCombo1 == "G"
        oSay5  := TSay():New(172,120,{||STR0158},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Determinações imprescendíveis para as MDO e Minuta do Rental"

        oBtn6  := TButton():New(170, 10, STR0159, oPanel, bBtnObj6, 100, 15, , oFont1, , .T.)     //"MDO E Minuta"
    EndIf

    oBtn5  := TButton():New(200, 250, STR0160, oPanel, bBtnObj2, 100, 15, , oFont1, , .T.) //"Exportar Parâmetros"

Return()

/*/{Protheus.doc} LOCA105A
@description: impressão dos Parâmetros do Rental para Excel
@author Dennis Calabrez
@since 18/09/2025
@version version
/*/ 
Static Function LOCA105A()
Local oSay

    FWMsgRun(, {|oSay| LOCA105B(oSay) }, STR0127, STR0005) //"Processando" //"Processando Impressão dos Parâmetros"
Return()

/*/{Protheus.doc} LOCA105B
@description: Processa a impressão dos Parâmetros do Rental para Excel
@author Dennis Calabrez
@since 18/09/2025
@version version
/*/ 
Static Function LOCA105B(oSay)
Local oFWMsExcel
Local oExcel
Local cArquivo  := GetTempPath()+'zTstExc1.xml'
Local cQry      := ""
Local cCmd1     := ""
Local cCmd2     := ""
Local cCmd3     := ""
Local cCmd4     := ""

    cQry := " SELECT "                                   
    cQry += "     X6_VAR, "                                          
    cQry += "     X6_TIPO, "                                     
    cQry += "     X6_DESCRIC, "                                    
    cQry += "     X6_CONTEUD, "                                 
    cQry += "     R_E_C_N_O_ RECNO "                                     
    cQry += " FROM "                                               
    cQry += "     " + RetSQLName('SX6') + " SX6 "      
    //Escopo P - Pequeno              
    If cCombo1 == 'P'
        cQry += " WHERE "                                                 
        cQry += "X6_FIL = '" + xFilial('SX6') + "' AND "             
        cQry += "X6_VAR = 'MV_LOCX007' OR X6_VAR = 'MV_LOCX008' OR X6_VAR = 'MV_LOCX014' OR "  
        cQry += "X6_VAR = 'MV_LOCX019' OR X6_VAR = 'MV_LOCX020' OR X6_VAR = 'MV_LOCX022' OR "  
        cQry += "X6_VAR = 'MV_LOCX023' OR X6_VAR = 'MV_LOCX024' OR X6_VAR = 'MV_LOCX025' OR " 
        cQry += "X6_VAR = 'MV_LOCX026' OR X6_VAR = 'MV_LOCX027' OR X6_VAR = 'MV_LOCX028' OR "  
        cQry += "X6_VAR = 'MV_LOCX030' OR X6_VAR = 'MV_LOCX049' OR X6_VAR = 'MV_LOCX051' OR "  
        cQry += "X6_VAR = 'MV_LOCX061' OR X6_VAR = 'MV_LOCX065' OR X6_VAR = 'MV_LOCX066' OR "  
        cQry += "X6_VAR = 'MV_LOCX069' OR X6_VAR = 'MV_LOCX071' OR X6_VAR = 'MV_LOCX078' OR "  
        cQry += "X6_VAR = 'MV_LOCX079' OR X6_VAR = 'MV_LOCX080' OR X6_VAR = 'MV_LOCX083' OR "  
        cQry += "X6_VAR = 'MV_LOCX186' OR X6_VAR = 'MV_LOCX201' OR X6_VAR = 'MV_LOCX278' OR "  
        cQry += "X6_VAR = 'MV_LOCX279' OR X6_VAR = 'MV_LOCX304' OR X6_VAR = 'MV_LOCX305' OR "  
        cQry += "X6_VAR = 'MV_GERNFS' OR X6_VAR = 'MV_NG1LOC' OR X6_VAR = 'MV_1DUPNAT' OR "    
        cQry += "X6_VAR = 'MV_LOCX308' OR X6_VAR = 'MV_LOCX211' OR X6_VAR = 'MV_LOCX303' OR "  
        cQry += "X6_VAR = 'MV_LOCX006' OR X6_VAR = 'MV_LOCX279' OR X6_VAR = 'MV_GSXRENT' OR "  
        cQry += "X6_VAR = 'MV_LOCX207' OR X6_VAR = 'MV_LOCX068' OR X6_VAR = 'MV_LOCX063' OR "  
        cQry += "X6_VAR = 'MV_LOCX064' OR X6_VAR = 'MV_LOCX248' "                            
        cQry += "     AND SX6.D_E_L_E_T_ = ' ' "                           
        cQry += "ORDER BY SX6.R_E_C_N_O_ " 
    EndIf
    //Escopo M - Médio
    If cCombo1 == 'M'
        cQry += " WHERE "                                                 
        cQry += "X6_FIL = '" + xFilial('SX6') + "' AND "             
        cQry += "X6_VAR = 'MV_LOCX007' OR X6_VAR = 'MV_LOCX008' OR X6_VAR = 'MV_LOCX014' OR "  
        cQry += "X6_VAR = 'MV_LOCX019' OR X6_VAR = 'MV_LOCX020' OR X6_VAR = 'MV_LOCX022' OR "  
        cQry += "X6_VAR = 'MV_LOCX023' OR X6_VAR = 'MV_LOCX024' OR X6_VAR = 'MV_LOCX025' OR " 
        cQry += "X6_VAR = 'MV_LOCX026' OR X6_VAR = 'MV_LOCX027' OR X6_VAR = 'MV_LOCX028' OR "  
        cQry += "X6_VAR = 'MV_LOCX030' OR X6_VAR = 'MV_LOCX049' OR X6_VAR = 'MV_LOCX051' OR "  
        cQry += "X6_VAR = 'MV_LOCX061' OR X6_VAR = 'MV_LOCX065' OR X6_VAR = 'MV_LOCX066' OR "  
        cQry += "X6_VAR = 'MV_LOCX069' OR X6_VAR = 'MV_LOCX071' OR X6_VAR = 'MV_LOCX078' OR "  
        cQry += "X6_VAR = 'MV_LOCX079' OR X6_VAR = 'MV_LOCX080' OR X6_VAR = 'MV_LOCX083' OR "  
        cQry += "X6_VAR = 'MV_LOCX186' OR X6_VAR = 'MV_LOCX201' OR X6_VAR = 'MV_LOCX278' OR "  
        cQry += "X6_VAR = 'MV_LOCX279' OR X6_VAR = 'MV_LOCX304' OR X6_VAR = 'MV_LOCX305' OR "  
        cQry += "X6_VAR = 'MV_GERNFS' OR X6_VAR = 'MV_NG1LOC' OR X6_VAR = 'MV_1DUPNAT' OR "    
        cQry += "X6_VAR = 'MV_LOCX308' OR X6_VAR = 'MV_LOCX211' OR X6_VAR = 'MV_LOCX303' OR "  
        cQry += "X6_VAR = 'MV_LOCX006' OR X6_VAR = 'MV_LOCX279' OR X6_VAR = 'MV_GSXRENT' OR "  
        cQry += "X6_VAR = 'MV_LOCX207' OR X6_VAR = 'MV_LOCX068' OR X6_VAR = 'MV_LOCX063' OR "  
        cQry += "X6_VAR = 'MV_LOCX064' OR X6_VAR = 'MV_LOCX248' OR X6_VAR = 'MV_LOCX008' OR "                            
        cQry += "X6_VAR = 'MV_LOCX071' OR X6_VAR = 'MV_NG1LOC' OR X6_VAR = 'MV_GSXRENT' OR "  
        cQry += "X6_VAR = 'MV_LOC299' OR X6_VAR = 'MV_LOCX084' " 
        cQry += "     AND SX6.D_E_L_E_T_ = ' ' "                           
        cQry += "ORDER BY SX6.R_E_C_N_O_ " 
    EndIf
    //Escopo G - Grande
    If cCombo1 == 'G'
        cQry += " WHERE "                                                 
        cQry += "X6_FIL = '" + xFilial('SX6') + "' AND "             
        cQry += "X6_VAR = 'MV_LOCX007' OR X6_VAR = 'MV_LOCX008' OR X6_VAR = 'MV_LOCX014' OR "  
        cQry += "X6_VAR = 'MV_LOCX019' OR X6_VAR = 'MV_LOCX020' OR X6_VAR = 'MV_LOCX022' OR "  
        cQry += "X6_VAR = 'MV_LOCX023' OR X6_VAR = 'MV_LOCX024' OR X6_VAR = 'MV_LOCX025' OR " 
        cQry += "X6_VAR = 'MV_LOCX026' OR X6_VAR = 'MV_LOCX027' OR X6_VAR = 'MV_LOCX028' OR "  
        cQry += "X6_VAR = 'MV_LOCX030' OR X6_VAR = 'MV_LOCX049' OR X6_VAR = 'MV_LOCX051' OR "  
        cQry += "X6_VAR = 'MV_LOCX061' OR X6_VAR = 'MV_LOCX065' OR X6_VAR = 'MV_LOCX066' OR "  
        cQry += "X6_VAR = 'MV_LOCX069' OR X6_VAR = 'MV_LOCX071' OR X6_VAR = 'MV_LOCX078' OR "  
        cQry += "X6_VAR = 'MV_LOCX079' OR X6_VAR = 'MV_LOCX080' OR X6_VAR = 'MV_LOCX083' OR "  
        cQry += "X6_VAR = 'MV_LOCX186' OR X6_VAR = 'MV_LOCX201' OR X6_VAR = 'MV_LOCX278' OR "  
        cQry += "X6_VAR = 'MV_LOCX279' OR X6_VAR = 'MV_LOCX304' OR X6_VAR = 'MV_LOCX305' OR "  
        cQry += "X6_VAR = 'MV_GERNFS' OR X6_VAR = 'MV_NG1LOC' OR X6_VAR = 'MV_1DUPNAT' OR "    
        cQry += "X6_VAR = 'MV_LOCX308' OR X6_VAR = 'MV_LOCX211' OR X6_VAR = 'MV_LOCX303' OR "  
        cQry += "X6_VAR = 'MV_LOCX006' OR X6_VAR = 'MV_LOCX279' OR X6_VAR = 'MV_GSXRENT' OR "  
        cQry += "X6_VAR = 'MV_LOCX207' OR X6_VAR = 'MV_LOCX068' OR X6_VAR = 'MV_LOCX063' OR "  
        cQry += "X6_VAR = 'MV_LOCX064' OR X6_VAR = 'MV_LOCX248' OR X6_VAR = 'MV_LOCX008' OR "                            
        cQry += "X6_VAR = 'MV_LOCX071' OR X6_VAR = 'MV_NG1LOC' OR X6_VAR = 'MV_GSXRENT' OR "  
        cQry += "X6_VAR = 'MV_LOC299' OR X6_VAR = 'MV_LOCX084' OR X6_VAR = 'MV_LOCX159' OR " 
        cQry += "X6_VAR = 'MV_LOCX191' OR X6_VAR = 'MV_LOCX056' OR X6_VAR = 'MV_LOCX097' " 
        cQry += "     AND SX6.D_E_L_E_T_ = ' ' "                           
        cQry += "ORDER BY SX6.R_E_C_N_O_ " 
    EndIf          

	If Select("TRBSX6") > 0
		TRBSX6->(DbCloseArea())
	EndIf
     cQry := CHANGEQUERY(cQry)
     MPSysOpenQuery(cQry,"TRBSX6",,,)


    ProcessMessages()

    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()   

    //Aba Parâmetros
    oFWMsExcel:AddworkSheet(STR0128) //"Parâmetros"

    //Criando as Colunas
    oFWMsExcel:AddTable(STR0128,STR0128) //STR0128 //"Parâmetros"
    oFWMsExcel:AddColumn(STR0128,STR0128,STR0118,1) //"Parâmetro" //STR0128 //"Parâmetros"
    oFWMsExcel:AddColumn(STR0128,STR0128,STR0119,1) //"Tipo" //STR0128 //"Parâmetros"
    oFWMsExcel:AddColumn(STR0128,STR0128,STR0129,1) //"Descricao" //STR0128 //"Parâmetros"
    oFWMsExcel:AddColumn(STR0128,STR0128,STR0130,1) //"Conteudo" //STR0128 //"Parâmetros"

    //Criando as Linhas no Excel
    While ! TRBSX6->(EoF())

        cCmd1  := "TRBSX6->X6_VAR"
        cCmd2  := "TRBSX6->X6_TIPO"
        cCmd3  := "TRBSX6->X6_DESCRIC"
        cCmd4  := "TRBSX6->X6_CONTEUD"    

        oSay:SetText(STR0131) //"Imprimindo Parâmentos"
        ProcessMessages()      

        oFWMsExcel:AddRow(STR0128,STR0128,{; //STR0128 //"Parâmetros"
                    &(cCmd1),;
                    &(cCmd2),;
                    &(cCmd3),;
                    &(cCmd4);
            })
        TRBSX6->(DbSkip())    
    EndDo

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)

    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()//Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)//Abre uma planilha
    oExcel:SetVisible(.T.)//Visualiza a planilha
    oExcel:Destroy()//Encerra o processo do gerenciador de tarefas
     
Return()

/*/{Protheus.doc} LOCA105C
@description: Página de Introdução 
@author Dennis Calabrez
@since 15/09/2025
@version version
/*/ 
Static Function LOCA105C(oPanel)
Local oBtn2
Local oBtn3
Local oBtn4
Local oBtn5
Local cLink    := "https://tdn.totvs.com/pages/viewpage.action?pageId=592557488"
Local bBtnObj0 := {||MsgInfo(STR0161)}  //"Passo 1 - Crie cadastros de forma fácil"
Local bBtnObj1 := {||MsgInfo(STR0162)}  //"Passo 2 - Parametrize conforme escopo negociado de forma fácil"
Local bBtnObj2 := {||MsgInfo(STR0163)}  //"Passo 3 - Libera um novo menu padrão pautado no escopo"
Local bBtnObj3 := {||ShellExecute("Open", cLink, "", "", 1)} 
Local oSay1
Local oSay2
Local oSay3
Local oSay4



oSay1  := TSay():New(20,110,{||STR0164},oPanel,,oFont2,,,,.T.,,,1000,500) //"Bem vindo ao Wizard do módulo TOTVS RENTAL"

oSay2  := TSay():New(82,120,{||STR0161},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Passo 1 - Crie cadastros de forma fácil"

oBtn2  := TButton():New(80, 10, STR0002, oPanel, bBtnObj0, 100, 15, , oFont1, , .T.) //"Cadastros"

oSay3  := TSay():New(112,120,{||STR0162},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Passo 2 - Parametrize conforme escopo negociado de forma fácil"

oBtn3  := TButton():New(110, 10, STR0128, oPanel, bBtnObj1, 100, 15, , oFont1, , .T.) //"Parâmetros"

oSay4  := TSay():New(142,120,{||STR0163},oPanel,,oFontCabec,,,,.T.,,,600,200) //"Passo 3 - Libera um novo menu padrão pautado no escopo"

oBtn4  := TButton():New(140, 10, STR0134, oPanel, bBtnObj2, 100, 15, , oFont1, , .T.) //"Menu"

oBtn5  := TButton():New(200, 250, STR0165, oPanel, bBtnObj3, 100, 15, , oFont1, , .T.) //"TDN"

Return()

/*/{Protheus.doc} LOCA105D
@description: Menu Renta - Será desenvolvido ainda
@author Dennis Calabrez
@since 15/09/2025
@version version
/*/ 
Static Function LOCA105D(oPanel)
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oBtn1
Local bBtnObj1 := {||LOCA107(cCombo1)} 

    oSay1  := TSay():New(20,110,{||"Menu do módulo TOTVS RENTAL"},oPanel,,oFont2,,,,.T.,,,1000,500)

    oSay2  := TSay():New(82,120,{||"Nesse passo, será definido o menu do TOTVS RENTAL conforme o escopo."},oPanel,,oFontCabec,,,,.T.,,,600,200)

    oSay3  := TSay():New(90,120,{||"Será gerado um arquivo .xnu com o nome do escopo, por exemplo: sigaloc_pequeno.xnu."},oPanel,,oFontCabec,,,,.T.,,,600,200)

    oSay4  := TSay():New(98,120,{||"Após a geração, renomeie o arquivo para sigaloc.xnu, acesse o Configurador (SIGACFG) e realize a restauração utilizando o novo menu."},oPanel,,oFontCabec,,,,.T.,,,600,200)

    oBtn1  := TButton():New(90, 10, "Definir Menu", oPanel, bBtnObj1, 100, 15, , oFont1, , .T.) 

    

Return()
