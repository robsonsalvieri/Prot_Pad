#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//------------------------------------------------------------------
/*/
Este fonte tem objetivo de concentrar todas as funções que criam e manipulam
o componente de fórmulas do configurador de tributos.
Este componente será composto por um get seletor de operandos
4 botões de operadores básicos (+-/*)
2 botões para abertura e fechamento dos parenteses
1 botão para habilitar a edição da fórmula
1 botão para adicionar o opernado na fórmula
1 botão para limpar a fórmula
1 botão par verificar sintaxe da fórmula

Este componente será adicionado nas telas de cadastro de regra de base de cálculo
, regra de alíquota e regra de tributo.

Este componente utilizará a tabela CIN para gravar as informações.
Os Ids dos móduloes e views deverão ser enviados todos por parâmetro para possibilitar
a reutilização deste componente em mais de uma view e modelo.

/*/
//------------------------------------------------------------------
STATIC lCpoNPIMemo := fisExtCmp( '12.1.2410' , .T., 'CIN' , 'CIN_FNPI_M' ) 
//------------------------------------------------------------------
/*/{Protheus.doc} xFisFormul

Função que cria os botões das fórmulas para as telas de regra de base de cálculo, 
alíquota e tributo.

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisFormul(oPanel, cModelo, cViewForm, cTpRegra, cCodCab, cCodModCab, cCodRegra, cViewRegra)

Local cCssBtn	:= getCss()
Local cCssEdit	:= getCss("EDITABLE_OCEAN.PNG")
Local cCssAdd	:= getCss("ADICIONAR_001.PNG")
Local cCssHelp	:= getCss("HELP.PNG")

//Posições do eixo Y das linhas
Local nYFisrtRow       := 1
Local nYSecondRow      := 16

//Posições do exixo X das linhas
Local nXFirstCol       := 2
Local nXSecondCol      := 72
Local nXThirdCol       := 103
Local nXFourthCol      := 134
Local nXFithCol        := 165
Local nXSixthCol        := 196

//Dimensões do tamanho dos botões
Local nWidthBtn        := 30 //Largura do botão
Local nHeightBtn       := 14 //Altura do botão
Local nWidthCss        := 65 //Largura do botão com CSS
Local nHeightCss       := 16 //Altura do botão com CSS

//Variaveis auxiliares para obter o resultado da função xCanAddOpe()
Local nTpOperador        := 1
Local nTpOperando        := 2
Local nTpAbreParenteses  := 3
Local nTpFechaParenteses := 4

Default cTpRegra:= ""
Default cCodCab := ""
Default cCodModCab := ""
Default cCodRegra := CriaVar("CIN_CONSUL")
Default cViewRegra:= ""

//Inicia o botão de editar fórmula habilitado
lclicked    := .T.

If cModelo == "FORMULCAL_ISENTO"
    lclickedI     := .T.
EndIF

If cModelo == "FORMULCAL_OUTROS"
    lclickedO     := .T.
EndIF

//Cria frame para colcoar os componentes
oLayer := FWLayer():New()
oLayer:Init(oPanel, .F.)
oLayer:AddLine('LIN1', 100, .F.)
oPanel1  := oLayer:getLinePanel('LIN1')

//Cria primeira linha dos botôes
oBtnEditar := TButton():New((nYFisrtRow - 1) , nXFirstCol   ,"      Editar Fórmula" ,oPanel1,{|| xEditFor(cModelo) }                                   ,nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND.  HabBtnEdit(cModelo) .And. HabEditTrib(cModelo)}         ,,.F.)
oBtnSom    := TButton():New(nYFisrtRow       , nXSecondCol  ,"+"                    ,oPanel1,{|| xForBtnAct("+", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnSub    := TButton():New(nYFisrtRow       , nXThirdCol   ,"-"                    ,oPanel1,{|| xForBtnAct("-", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnMul    := TButton():New(nYFisrtRow       , nXFourthCol  ,"*"                    ,oPanel1,{|| xForBtnAct("*", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnDiv    := TButton():New(nYFisrtRow       , nXFithCol    ,"/"                    ,oPanel1,{|| xForBtnAct("/", cModelo, .T., cViewForm, cViewRegra) },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .AND. xCanAddOpe(cModelo)[nTpOperador]},,.F.)
oBtnDesfaz := TButton():New(nYFisrtRow       , nXSixthCol   ,"Desfaz"            ,oPanel1,{|| BackSpace(cModelo, .T., cViewForm)                  },nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo)}                                              ,,.F.)

//Cria segunda fileira dos botôes
oBtnEAdd  := TButton():New((nYSecondRow - 1) , nXFirstCol  ,"      Adiciona" ,oPanel1,{|| xForBtnAct(cCodRegra,cModelo, .T., cViewForm, cViewRegra)},nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .And. xCanAddOpe(cModelo)[nTpOperando]}       ,,.F.)
oBtnAbre  := TButton():New(nYSecondRow       , nXSecondCol ,"("              ,oPanel1,{|| xForBtnAct("(", cModelo, .T., cViewForm, cViewRegra) }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .And. xCanAddOpe(cModelo)[nTpAbreParenteses]} ,,.F.)
oBtnFEcha := TButton():New(nYSecondRow       , nXThirdCol  ,")"              ,oPanel1,{|| xForBtnAct(")", cModelo, .T., cViewForm, cViewRegra) }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo) .And. xCanAddOpe(cModelo)[nTpFechaParenteses]},,.F.)
oBtnClear := TButton():New(nYSecondRow       , nXFourthCol ,"Limpar"         ,oPanel1,{|| xForClear(cModelo, .T.,cViewForm, .T. )              }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo)}                                              ,,.F.)
oBtnChk   := TButton():New(nYSecondRow       , nXFithCol   ,"Validar"        ,oPanel1,{|| xForCheck(cModelo,,.T.,cTpRegra, cCodCab,cCodModCab) }    ,nWidthBtn ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .AND. !HabBtnEdit(cModelo)}                                              ,,.F.)
oBtni     := TButton():New(nYSecondRow       , nXSixthCol   ,"   "           ,oPanel1,{|| HelpPrx()}    ,14 ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||.T.}                                              ,,.F.)

//Aplica o CSS nos botões
oBtnSom:SetCss(cCssBtn)
oBtnSub:SetCss(cCssBtn)
oBtnMul:SetCss(cCssBtn)
oBtnDiv:SetCss(cCssBtn)
oBtnDesfaz:SetCss(cCssBtn)
oBtnAbre:SetCss(cCssBtn)
oBtnFEcha:SetCss(cCssBtn)
oBtnClear:SetCss(cCssBtn)
oBtnChk:SetCss(cCssBtn)
oBtnEditar:SetCss(cCssEdit)
oBtnEAdd:SetCss(cCssAdd)
oBtni:SetCss(cCssHelp)

Return NIL

//Função auxiliar para criar label em um painel vazio.
Function xFisLabel(oPanel)

oSay1:= TSay():New(200,200,{||' '},oPanel,,,,,,.T.,,,200,20)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} xForBtnAct
Função para adicionar operandos e parênteses no final da fórmula

@param cText - Operando/Operador a ser adicionado no final da fórmula
@param cModelo - Nome do modelo a qual a fórmula pertence

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xForBtnAct(cText, cModelo, lRefresh, cView, cViewRegra)
Local oModel    :=	FWModelActive()
Local oFormul	:=  oModel:GetModel(cModelo)
Local oView 	:= 	FWViewActive()
Local cFormul   :=  oFormul:GetValue("CIN_FORMUL",1)
Local cFiltro   :=  oFormul:GetValue("CIN_FILTRO",1)
Local lOriTrb   := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0 
Local AUltChar  := {}
Local cOriTrb   := ""

//Somente adicionará se o texto estiver preenchido.
If !Empty(cText) .AND. !Empty(cFiltro)

    //Verifico se estou adicionando o código da CIN, para carregar o valor da tela
    If cText == "CIN_CONSUL"

        If cFiltro == "ZZ" //Valor numérico manual                        
            cText := STRTRAN(Alltrim(cvaltochar(oFormul:GetValue("CIN_VAL",1))),".", ",")
        Else //Demais Códigos de regras cadastradas
            cText:= Alltrim(oFormul:GetValue("CIN_CONSUL",1))

            If lOriTrb
                cOriTrb := Alltrim(oFormul:GetValue("CIN_ORITRB",1))
                cText   := xPrefDef(cText, cOriTrb)
            EndIf

        EndIF

        IF cText == xFisTpForm("9") + "DED_DEPENDENTES" .Or. cText == xFisTpForm("9") +  "DED_TAB_PROGRESSIVA" 
            
            AUltChar  := StrTokArr(alltrim(cFormul)," ")
            IF Len(AUltChar) >= 2 .And. !(AUltChar[Len(AUltChar)]  == "-" .OR. (AUltChar[Len(AUltChar)] == "(" .And. AUltChar[Len(AUltChar)-1] == "-"))
                //Preciso verificar se tem operador de subtração ou subtração e parenteses para adicionar esta dedução
                Help( ,, 'Help',, "Este operando somente poderá ser utilizado na operação de subtração!", 1, 0 )
                return
            ElseIF Len(AUltChar) < 2
                Help( ,, 'Help',, "Este operando somente poderá ser utilizado na operação de subtração!", 1, 0 )
                return
            EndIF

        EndIF

        //Limpando o campo do código da regra e valor
        oFormul:LoadValue("CIN_CONSUL",CriaVar("CIN_CONSUL"))
        oFormul:LoadValue("CIN_VAL",CriaVar("CIN_VAL"))        

        //Atualiza a VIEW_REGRA
        If lRefresh .AND. !Empty(cViewRegra)
            oview:Refresh(cViewRegra)
        EndIf

    EndIf
    //Adiciona o operador no final da fórmula
    oFormul:LoadValue('CIN_FORMUL', cFormul + " " + cText)    

    //Atualiza as Views
    If lRefresh .AND. !Empty(cView)
        oview:Refresh(cView)
    EndIF

    //Atualiza a VIEW_REGRA
    If lRefresh .AND. !Empty(cViewRegra)
        oview:Refresh(cViewRegra)
    EndIf


endif 

Return

//------------------------------------------------------------------
/*/{Protheus.doc} x160CLear
Função que limpa a fórmula e o operador

@param cModelo - Nome do modelo a qual a fórmula pertence

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xForClear(cModelo, lRefresh, cView, lBtn)
Local oModel    :=	FWModelActive()
Local oFormul	:= oModel:GetModel(cModelo)
Local oView 	:= 	FWViewActive()

Default lBtn    := .F.



If cModelo == "FORMULCAL" .and. lBtn
	//Chama função correspondente da regra de Regra de Tributo    
	If FindFunction("Fsa160AFor")
		//Chama função correspondente do modelo tratado.
		Fsa160AFor()
	EndIF
ElseIf cModelo $ "FORMULCAL_ISENTO/FORMULCAL_OUTROS" .and. lBtn 
	//Chama função correspondente da regra de Regra de Tributo    
	If FindFunction("Fsa160AFor")
		//Chama função correspondente do modelo tratado.
		Fsa160AFor(cModelo)
	EndIF
EndiF

//Limpa o conteúdo das fórmulas e do código da regra
oFormul:LoadValue('CIN_FORMUL', "" )

//Atualiza as Views
If lRefresh .And. !Empty(cView)
	oview:Refresh( cView )
Endif

Return

//------------------------------------------------------------------
/*/{Protheus.doc} xForCheck
Função que verifica a fórmula digitada:
-verificando sintaxe
-caracteres inválidos
-abertura  efechamento de paranteses
-Operandos válidos e devidamente cadastrados
-Problema de recursividade, da fórmula depender dela mesmo

@param cModelo - Nome do modelo a qual a fórmula pertence
@param cRetErro - Mensagem de erro de validação se houver
@param lShowMsg - Indica se esta função exibirá ou não mensagem
@param cTpRegra - Tipo da regra, se base, alíquota, tributo etc
@param cCodCab - Nome do campo que possui o código da regra que está sendo manipulad
@param cCodModCab - Nome do modelo que contem o campo da regra que está sendo manipulad
@param lEmpty - Indica que permite fórmulas vazias
@param - cExcecao - Aqui são operandos que não deverão ser verificados sua existência na CIN, caso seja necessário.

@return lRet - retornar verdadeido se ocorrer algum erro

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xForCheck(cModelo, cRetErro, lShowMsg, cTpRegra, cCodCab, cCodModCab, lEmpty, cExcecao)
Local oModel        := FWModelActive()
Local oFormul	    := oModel:GetModel(cModelo)
Local oCab	        := oModel:GetModel(cCodModCab)
Local cExpressao    := oFormul:GetValue("CIN_FORMUL",1)
Local cCodCIN       :=  ""
Local cFormula      := ""
Local lRet          := .F.
Local cCodCINTrb    := ""

Default cRetErro    := ""
Default lShowMsg    := .F.
Default lEmpty      := .F.
Default cExcecao    := ""

//Somente fará verificação se a fórmula estiver preenchida
If !Empty(cExpressao)    
    //----------------------------------------------------------------
    //Faz verificação de sintaxe de parenteses e caracteres inválidos
    //----------------------------------------------------------------
    cRetErro  := FisChkForm(cExpressao)
    If Empty(cRetErro)
        
        //Converte a fórmula em NPI
        cExpressao    := xFisSYard(cExpressao, @cFormula)

        //Remove prefixos indesejados
        cExpressao := xPrefVld( cExpressao )
        
        //Para o cadastro de regra tributária, preciso fazer a validação do prefixo da fórmula, 
        //deverá corresponder as regras de base e alíquota selecionadas
        //If cModelo == "FORMULCAL"
        //    cRetErro    := ""
        //    vldPreFixFor(cFormula, @cRetErro)            
        //EndIF
        //------------------------------------------------------------
        //Verifica se todos os operandos estão devidamente cadastrados
        //------------------------------------------------------------
        IF Empty(cRetErro) .AND. xFisForCad(cExpressao, @cRetErro, cExcecao)

            cRetErro    := ""
            //-----------------------------
            //Verifica a sintaxe da fórmula
            //-----------------------------
            If xFisSintaxe(cFormula, @cRetErro)

                //------------------------------------------------------------
                //Verifica se o código não está contido na próprioa fórmula
                //Chama função para verificar questão da recursividade       
                //------------------------------------------------------------
                cCodCIN  := xFisTpForm(cTpRegra)
                cCodCIN  += oCab:GetValue(cCodCab,1)
                cRetErro := ""

                If cModelo == "FORMULCAL_ISENTO" .Or. cModelo == "FORMULCAL_OUTROS"
                    cCodCINTrb := xFisTpForm("8") //Pego o prefixo do tributo do modelo FORMULCAL, para garantir que a fórmula não seja dependente de si mesma
                    cCodCINTrb  += oCab:GetValue(cCodCab,1)
                EndIf

                If !xFisFDep(cCodCIN, cExpressao, @cRetErro, cCodCINTrb)
                  
                    lRet := .T.
                    If lShowMsg
                        //Executa fórmula nPI
                        MsgInfo("Resultado = " + cvaltochar(FisExecNPI(cExpressao));
                        + CRLF + CRLF + CRLF + CRLF +;
                        "Expressão em NPI: " + cExpressao)
                    EndIF                
                    
                Else
                    cRetErro := "Regra '" +   oCab:GetValue(cCodCab,1) + "' Não pode ser dependente das regras informadas na fórmula:" + CRLF + CRLF +  substr(Alltrim(cRetErro), 1, len(Alltrim(cRetErro)) - 2)
                EndIf
            
            EndIF

        EndIF

    EndIF
ElseIf lEmpty
    lRet    := .T. //Aqui permito fórmula vazia!
Else
    cRetErro := "Expressão vazia!"
EndIF

//Verifica se deve exibir mensagem de erro
If !lRet .AND. lShowMsg .And. !Empty(cRetErro)
    Help( ,, 'Help',, cRetErro, 1, 0 )
EndIF 

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} GravaCIN
Função que fará gravação da tabela CIN
@param cTpRegra - Tipo da regra, 1=Base, 2=Alíquota, 3=Valor Tributo; 4=Valor padrão
@param cRegra - Código da regra a qual a fórmula está vinculada
@param cIdRegra - ID da regra a qual a fórmula está vinculada
@param cDescri - Descrição da regra
@param cFormula - Fórmula em expressão aritimética
@param cNPI - Fórmula convertida em NPI

@author Erick G. Dias
@since 29/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function GravaCIN(cOpc, cTpRegra, cRegra, cIdRegra, cDescri, cFormula, cAltera, cFormUsuar, cOldIdReg, lVersiona)
Local aAreaAnt  := GETAREA()
Local aAreaCIN := {}

Default cAltera    := "0"
Default cTpRegra   := ""
Default cFormUsuar := cFormula
Default cOldIdReg  := ""
Default lVersiona  := .T.

If cOpc == "1" //inclusão

    RecLock("CIN",.T.)
    CIN->CIN_FILIAL	    := xFilial("CIN")
    CIN->CIN_ID    		:= FWUUID("CIN")
    CIN->CIN_CODIGO	    := xFisTpForm(cTpRegra) + cRegra
    CIN->CIN_DESCR   	:= cDescri
    CIN->CIN_TREGRA	    := cTpRegra
    CIN->CIN_REGRA  	:= Iif(cTpRegra <> "0",cRegra,"")
    CIN->CIN_IREGRA  	:= cIdRegra
    CIN->CIN_FORMUL	    := cFormUsuar
    CIN->CIN_ALTERA	    := cAltera //não alterado
    SetFormula(xFisSYard(cFormula))
    
    MsUnLock()
ElseIf cOpc == "2" //edição
    
    aAreaCIN := CIN->(GetArea())
    
    //Seek para posicionar a CIN
    dbSelectArea("CIN")
    dbSetOrder(3)
    if !lVersiona .AND. CIN->(MsSeek(xFilial('CIN') +cIdRegra+cTpRegra))
        RecLock("CIN",.F.)
        CIN->CIN_CODIGO	    := xFisTpForm(cTpRegra) + cRegra
        CIN->CIN_DESCR   	:= cDescri
        CIN->CIN_TREGRA	    := cTpRegra
        CIN->CIN_REGRA  	:= Iif(cTpRegra <> "0",cRegra,"")
        CIN->CIN_IREGRA  	:= cIdRegra
        CIN->CIN_FORMUL	    := cFormUsuar
        SetFormula(xFisSYard(cFormula))
        
        MsUnLock()
    ElseIf !Empty(cOldIdReg) .AND. !Empty(cIdRegra) .AND. CIN->(MsSeek(xFilial('CIN') +cOldIdReg+cTpRegra))
        //Nesse caso, o sistema irá apenas atualizar o ID da Regra, com o intuito de manter a referência com o registro de origem.
        RecLock("CIN",.F.)
        CIN->CIN_IREGRA := cIdRegra
        MsUnLock()
    ElseIf !Empty(cIdRegra) .AND. CIN->(MsSeek(xFilial('CIN') + cIdRegra+cTpRegra))
        RecLock("CIN",.F.)
        CIN->CIN_ALTERA := "1"//Indica que sofreu alterações
        MsUnLock()
    EndIF

    RestArea(aAreaCIN)
    aSize(aAreaCIN,0)

ElseIf cOpc == "3" //exclusão

    aAreaCIN := CIN->(GetArea())
    //Seek para posicionar a CIN
    dbSelectArea("CIN")
    dbSetOrder(3)
    If !Empty(cIdRegra) .AND. CIN->(MsSeek(xFilial('CIN') + cIdRegra+cTpRegra))
        RecLock("CIN",.F.)
	    CIN->(dbDelete())
    	MsUnLock()
    EndIF

    RestArea(aAreaCIN)
    aSize(aAreaCIN,0)

EndIF

RESTAREA(aAreaAnt)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} xFisTpForm
Função que recebe o tipo de operando e devolve o prefixo correspondente.

Exemplo:
0 = operador primario sera O.
1 = base, o retorno será B.
2 = alíquota o retorno será A.
3 = tributo o retorno será V.

@param cOrig - Origem do operando

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisTpForm(cOrig)

Local cTipo := ""

If cOrig == "0" //Operadores primarios / Valor Origem
	cTipo	:= "O:"
ElseIf cOrig == "1" //Base de cálculo
	cTipo	:= "B:"
ElseIf cOrig == "2" //Alíquota
	cTipo	:= "A:"
ElseIf cOrig == "3" //Tributo
	cTipo	:= "V:"
ElseIf cOrig == "4" //URF
	cTipo	:= "U:"
ElseIf cOrig == "6" //Tipo de fórmulas do tributo base
	cTipo	:= "BAS:"
ElseIf cOrig == "7" //Tipo de fórmulas do tributo aliquota
	cTipo	:= "ALQ:
ElseIf cOrig == "8" //Tipo de fórmulas do tributo valor
	cTipo	:= "VAL:"
ElseIf cOrig == "9" //Índices de Cálculos
	cTipo	:= "I:"    
ElseIf cOrig == "10" //Fórmula MAIOR
	cTipo	:= "MAIOR"
ElseIf cOrig == "11" //Valor de Isento
	cTipo	:= "ISE:"    
ElseIf cOrig == "12" //Valor de Outros
	cTipo	:= "OUT:"    
ElseIf cOrig == "13" //Valor de diferimento
	cTipo	:= "DIF:"    
ElseIf cOrig == "14" //Fórmula MENOR
	cTipo	:= "MENOR"
EndIF

Return cTipo

//------------------------------------------------------------------
/*/{Protheus.doc} xEditFor
Função que habilita a edição da fórmula, executada quando o botão de edição
é acionado.

@param cModelo - Modelo que deverá refletir as alterações ao habilitar a fórmula

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xEditFor(cModelo)

If cModelo == "FORMULBAS"	
	//Desabilita o botão de editar fórmula
    lclicked    := .F.
    //Chama função correspondente da regra de base de cálculo
	If FindFunction("Fsa161AFor")
		//Chama função correspondente do modelo tratado.
		Fsa161AFor()
	EndIF
ElseIf cModelo == "FORMULALQ"
    //Desabilita o botão de editar fórmula
    lclicked    := .F.
    //Função do FISA162 que muda a opção da alíquota para função manual
	If FindFunction('Fsa162AFor')
		lRet := Fsa162AFor()	
	EndIf    
ElseIf cModelo == "FORMULCAL"
    //Desabilita o botão de editar fórmula
    lclicked    := .F.
    //Função do FISA160 que da refresh na view
	If FindFunction('Fsa160AFor')
		lRet := Fsa160AFor("FISCOMPFOR")	
	EndIf

ElseIf cModelo == "FORMULCAL_ISENTO"
    //Desabilita o botão de editar fórmula
    lclickedI    := .F.
    //Função do FISA160 que da refresh na view
	If FindFunction('Fsa160AFor')
		lRet := Fsa160AFor("FISCOMPFOR")	
	EndIf

ElseIf cModelo == "FORMULCAL_OUTROS"
    //Desabilita o botão de editar fórmula
    lclickedO    := .F.
    //Função do FISA160 que da refresh na view
	If FindFunction('Fsa160AFor')
		lRet := Fsa160AFor("FISCOMPFOR")	
	EndIf    

EndiF

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} HabBtnEdit
Esta função indica se os componentes de composição das fórmulas deverão 
estar habilitados ou não.

@param cModelo - Modelo que deverá refletir as alterações ao habilitar a fórmula

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function HabBtnEdit(cModelo)

 Local lRet := .T.

If cModelo == "FORMULBAS"
	If FindFunction('Fsa161HBtn')
		lRet := Fsa161HBtn()	
	EndIf
ElseIf cModelo == "FORMULALQ"
    //Função do fonte FISA162 que valida se está na opção para edição da fórmula
	If FindFunction('Fsa162HBtn')
		lRet := Fsa162HBtn()	
	EndIf
ElseIf cModelo $ "FORMULCAL/FORMULCAL_ISENTO/FORMULCAL_OUTROS"
    IF FindFunction('Fsa160HBtn')
        lRet := Fsa160HBtn(cModelo)
    Endif
EndIF

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} xCanEdit
Função que verifica o modelo ativo e obtem a operação.
@return bool - verdadeiro se a operação for inclusão ou edição.

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xCanEdit()
Local oModel        := FWModelActive()
return oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE

//------------------------------------------------------------------
/*/{Protheus.doc} getCss
Função que monta o CSS

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Static Function getCss(cImg)

Local cEstilo	:= ""

cEstilo := "QPushButton {"  

If !Empty(cImg)
	//Usando a propriedade background-image, inserimos a imagem que será utilizada, a imagem pode ser pega pelo repositório (RPO)
	cEstilo += " background-image: url(rpo:" + cImg + ");background-position: left center;background-repeat: no-repeat; margin: 2px;"
EndIF

cEstilo += " border-style: outset;"
cEstilo += " border-width: 1px;"
cEstilo += " border: 1px solid #03396C;"
cEstilo += " border-radius: 6px;"
cEstilo += " border-color: #03396C;"
cEstilo += " font: bold 12px Arial;"
cEstilo += " padding: 6px;"
cEstilo += " background-color: #f4f7f9;"
cEstilo += "}"

//Na classe QPushButton:pressed , temos o efeito pressed, onde ao se pressionar o botão ele muda
cEstilo += "QPushButton:pressed {"
cEstilo += " background-color: #e68a2c;"
cEstilo += " border-style: inset;"
cEstilo += "}" 

Return cEstilo

//------------------------------------------------------------------
/*/{Protheus.doc} xCanAddOpe

Função que analisará se operando/operador/parenteses pode ou não ser
adicionado na fórmula.

@param - cFormul - Fórmula atual
@param - cText -  Texto a ser adicionado no final da fórmula

@author Erick G. Dias
@since 03/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xCanAddOpe(cModelo)
Local oModel        :=	FWModelActive()
Local oFormul	    := oModel:GetModel(cModelo)
Local cFormul       := Alltrim(oFormul:GetValue("CIN_FORMUL",1))
local cUltChar      := Alltrim(substring(cFormul , Len(cFormul)  ,1))
Local lOperador  := .F.
Local lOperando  := .F.
Local lAbertura  := .F.
Local lFechament := .F.
/*
Fórmula vazia, ou Ultimo caracter é abertura de parenteses, ou Último caracter é um operandor:
    Somente habilitar botões de adicionar operando e abertura de parenteses

Último caracter é fechamento de parenteses ou Último caracter é um operando:
    Habilitar somente Botão de operadores botão de fechar parenteses

*/
If Empty(cUltChar) .Or. cUltChar $ "(" .Or. cUltChar $ "+-/*"
    //Somente habilitar botões de adicionar operando e abertura de parenteses    
    lOperando  := .T.
    lAbertura  := .T.    

Else //Aqui restarem as hipóteses de fechamento de parenteses e operando
    //Habilitar somente Botão de operadores botão de fechar parenteses
    lOperador   := .T.
    lFechament  := .T.

EndIF

Return {lOperador,lOperando, lAbertura, lFechament}

//------------------------------------------------------------------
/*/{Protheus.doc} xFisForCad

Função que fará validação dos operandos contidos na fórmula, se realmente
existem na base de dados ou não.
Caso todos estejam devidamente cadastrados a função retornará verdadeiro.
Caso contrário a função retornará falso e também a mensagem de erro com
etalhe de qual operando não está cadastrado. Somente serão permitidos operandos
devidamente cadastrados

@param - cFormul - Fórmula atual com sintaxe 
@param - cErro - Mensagem com erro de validação 
@param - cExcecao - Aqui são operandos que não deverão ser verificados, caso seja necessário.
@return - lret - indica se ao menos algum operando não foi encontrado no cadastro

@author Erick G. Dias
@since 05/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisForCad(cFormula, cErro, cExcecao)

Local aFormula	:= StrTokArr(alltrim(cFormula)," ")
Local nX        := 0 
Local lRet      := .T.
Local nTamCINCod := TamSx3("CIN_CODIGO")[1]
Default cExcecao    := ""

cErro := "As regras abaixo não foram encontradas no cadastro, por favor verifique: "  + CRLF + CRLF

//Itero o array para verifica se todos os operandos estão devidamente cadastrados.
For nX := 1 to Len(aFormula)

    //Não preciso verificar operadores e parenteses e números
    If (!aFormula[nX] $ "+-*/()," .AND. aFormula[nX] <> "MAIOR" .AND. aFormula[nX] <> "MENOR") .And. !aFormula[nX] $ cExcecao .AND. !Empty(aFormula[nX]) .And. !IsDigit(aFormula[nX])
        
        //Seek na CIN buscando o código da regra        
        dbSelectArea("CIN")
        dbSetOrder(1) //CIN_FILIAL+CIN_CODIGO+CIN_ALTERA+CIN_ID
        If !CIN->(MsSeek(xFilial('CIN') + Padr(aFormula[nX],nTamCINCod)  + "0" ))
            //Se não encontrou então atualizará a mensagem de erro com o código da regra
            cErro += iif(lRet, "", ", ") +  Padr(aFormula[nX],nTamCINCod)
            lRet := .F.
        EndIF        
    EndIF

Next nX

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} xFisFDep

Função que faz validação se o operador atual está contido 
em sua própria fórmula, seja de forma direta ou indireta.
Farei esta verificação com uma função recusriva, como não sei
quantos níveis de fórmulas pode ter, preciso verificar fórmula da fórmula
para certificar que o operador não está contido em sua própria fórmula.
Irei até encontrar um operador primário, URF ou numérico, mas enquanto houver
operador composto continuarei verificando.
Esta verificação é devida para evitar problema de recursividade, pois 
se A depende de B, e B depende de A, nunca seria possível resolver esta fórmula,
ficaria em loop infinito.

@param - cCodCIN - Código da fórmula 
@param - cFormula - Fórmula que deverá ser verificada
@param - cErro - Mensagem de erro com detalhamento, caso o operando esteja contido em sua própria fórmula
@return - lret - Indica que operando está contido em sua própria fórmula.

@author Erick G. Dias
@since 07/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisFDep(cCodCIN, cFormula, cErro, cCodCINTrb)

Local aOperadores   := {}
Local nX            := 0
Local lRet          := .F.

Default cCodCINTrb  := ""

//Se a fórmula ou código estiverem vazios então retorno .F., pois não tem como verificar
If Empty(cCodCIN) .Or. Empty(cFormula)    
    Return .F.
EndIF

//Prossigo verificando o código está contido na fórmula, se estiver já retorno verdadeiro e atualizo a mensagem
If Alltrim(cCodCIN)  $ Alltrim(cFormula)
    cErro += "'" + cCodCIN + "' >> "
    Return .T.
//No caso das fórmulas de regra de cálculo das abas Isento e Outros, verifico se o operando da aba Tributada está contida na fórmula para evitar o loop infinito.
ElseIf !Empty(cCodCINTrb) .And. Alltrim(cCodCINTrb) $ Alltrim(cFormula)
    cErro += "'" + cCodCINTrb + "' >> "
    Return .T.
Else
    //Se não estiver contido preciso então verificar todos os operandos para saber se tem mais alguma dependencia.
    dbSelectArea("CIN")
    dbSetOrder(1)
    //Split da fórmula
    aOperadores := StrTokArr(alltrim(cFormula)," ")
    
    //Laço nos operandos da fórmula
    For nX := 1 to Len(aOperadores)
        
        //Operando numérico não precisa ser verificado, pois não possui fórmula
        //Operador também não precisa ser verificado
        If !(IsDigit(aOperadores[nx]) .Or. aOperadores[nx] $ "+-*/()")
            //Posiciono a CIN
            If CIN->(MsSeek(xFilial('CIN') + aOperadores[nx])) .And. Alltrim(CIN->CIN_TREGRA) $ "1#2#6#7#8#"
                //Se for operando composto, então Verifico se está contido nesta fórmula e chama novamene a mesma fuinção.
                lRet := xFisFDep(cCodCIN, CIN->CIN_FORMUL, @cErro, cCodCINTrb)
                If lRet                    
                    cErro += "'"+  aOperadores[nx] +  "' >> "
                    Exit //Se está contido sai do laço e retorna                    
                EndIF            
            EndIF

            //Operando primário também não precisa ser verificado
        Else    
            //Aqui provavelmente é um operador primário ou URF, ou ainda não estar cadastrado na CIN, em todo caso não estará contido aqui 
            //Vai para próximo operador
        EndIF                

    Next NX
EndIF

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} xFisSintaxe

Função que verifica a sintaxe da fórmula, após validações de dependências,
e de operandos devidamente cadastrados

@param - cFormula - Fórmula informada pelo usuáro
@param - cError - VAriável que terá o detalhamento de erro caso houver algumm problema de sintaxe da fórmula

@return - lret - Retorna .T. se fórmula estiver sem erros

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function xFisSintaxe(cFormula, cError)

Local aFormula  := {}
Local nX        := 0
Local cLastPos  := ""
Local cType     := ""
Local cDetalhe  := " "
Local nParamMax := 0
Local lContinue := .F.

//Verifico se a fórmula está preenchida antes de fazer o split
If !Empty(cFormula)
    aFormula	:= StrTokArr(alltrim(cFormula)," ")
Else
    cError := "Fórmula está vazia!"
    return .f.
EndIF

//Itero o array para verificar a sintaze da fórmula
For nX:=1 to Len(aFormula)
    
    //Obtem o tipo do componente da fórmula
    cType   := RetTypeFor(aFormula[nX])
    lContinue   := .F.

    //Primeiro componente, somente poderá ser abertura de parenteses ou operando
    If Empty(cLastPos)
        If cType == "OPERANDO" .Or. cType == "ABERTURA" .Or. cType == "FORMULA_MAIOR_MENOR"
            lContinue   := .T.
        Else
            cError  := "Fórmula somente pode ser iniciada com operando, abertura de parenteses ou fórmula!"
        EndIf            
    
    //Se anterior foi um operando, então somente  poderá ser somente poderá ser um operador ou fechamento de parenteses    
    ElseIf cLastPos == "OPERANDO"
        If cType == "OPERADOR" .OR. cType == "FECHAMENTO"
            lContinue   := .T.
        ElseIF nParamMax > 0 //Aqui tem uma exceção, permitirá dois operandos seguidos caso seja argumento da funçã MAIOR ou MENOR.
            lContinue   := .T.
            nParamMax  -= 1 //Removo, indicando que já foi utilizado operando da função MAIOR ou MENOR
        Else
            cError  := "Esperado um operador ou fechamento de paranteses!"
        EndIF
    
    //Se anterior foi um operador, entao somente peritirá um operando ou abertura de parenteses    
    ElseIF cLastPos == "OPERADOR"
        If cType == "OPERANDO" .Or. cType == "ABERTURA"        
            lContinue   := .T.
        Else
            cError  := "Esperado um operando ou abertura de parenteses!"
        EndIf
    
    //Se anterior for abertura de parenteses, somene permitira outra abertura de parenteses ou um operando    
    ElseIF cLastPos == "ABERTURA"      
        If cType == "ABERTURA" .OR. cType == "OPERANDO" .OR. cType == "FORMULA_MAIOR_MENOR"
            lContinue   := .T.
        Else
            cError  := "Esperado um operando, abertura de parenteses ou fórmula!"
        EndIf    
    
    //Se anterior for fechamento de parenteses, somene permitira outro fechamento ou um operador
    ElseIF cLastPos == "FECHAMENTO"
        If cType == "OPERADOR" .OR. cType == "FECHAMENTO"        
            lContinue   := .T.            
        Else
            cError  := "Esperado operador ou fechamento de parenteses!"
        EndIf
    
    ElseIF cLastPos == "FORMULA_MAIOR_MENOR"
        If cType == "ABERTURA"
            lContinue   := .T.  
            nParamMax   := 2 //Para fórmula MAIOR ou MENOR pode esperar dois operandos seguidos como argumentos da função
        Else
            cError  := "Esperado abertura de parenteses!"
        EndIf

    EndIF 

    If lContinue
        //Atualiza o último componente
        cLastPos    := cType
    Else
        //Alguma condição acima não foi respeitada e existe algum erro na fórmula        
        //Verifico se posso buscar operando anterior
        If nX > 1
            cDetalhe    += aFormula[nX-1] + " "
        EndIF

        //Adiciono operando atual
        cDetalhe    += aFormula[nX] + " "

        //Verifico se posso buscar próximo operando
        If nX < len(aFormula) 
            cDetalhe    += aFormula[nX+1]
        EndIF        

        cError  += + CRLF + CRLF + " Verifique o trecho abaixo:"  + CRLF + CRLF + cDetalhe
        
        exit
    EndiF

Next nX

//Caso o último elemento da fórmula seja operador ou abertura de parenteses exibirá erro, pois não será permitido
If nX > Len(aFormula) .And. cType == "OPERADOR" .Or. cLastPos == "ABERTURA"
    cError  := "Fórmula não pode terminar com operadores + - * / ou abertura de parenteses!"
    lContinue   := .F.
EndIF

Return lContinue

//------------------------------------------------------------------
/*/{Protheus.doc} IsOperador

Verifica se texto é um operador
@param - cCode - Fórmula informada pelo usuáro
@return - Retorna .T. caso seja um operador

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function IsOperador(cCode)
Return "*" $ cCode .Or. "/" $ cCode .Or. "-" $ cCode .Or. "+" $ cCode

//------------------------------------------------------------------
/*/{Protheus.doc} IsAbertura

Verifica se texto é abertura de parenteses
@param - cCode - Fórmula informada pelo usuáro
@return - Retorna .T. caso seja abertura de parenteses

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Function IsAbertura(cCode)
return "(" $ cCode

//------------------------------------------------------------------
/*/{Protheus.doc} IsFechamento

Verifica se texto é fechamento de parenteses
@param - cCode - Fórmula informada pelo usuáro
@return - Retorna .T. caso seja fechamento de parenteses

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//-----------------------------------------------------------------
Function IsFechamento(cCode)
return ")" $ cCode

//------------------------------------------------------------------
/*/{Protheus.doc} RetTypeFor

Função que recebe texto e retorna o tipo do elemento da fórmual
@param - cCode - Fórmula informada pelo usuáro
@return - cType - retorna o tipo do elemento da fórmula

@author Erick G. Dias
@since 10/02/2020
@version 12.1.30
/*/
//-----------------------------------------------------------------
Function RetTypeFor(cCode)

Local cType := ""

If IsFechamento(cCode)
    //Fechamento de parenteses
    cType := "FECHAMENTO"
ElseIf IsAbertura(cCode)    
    //Abertura de parenteses
    cType := "ABERTURA"
ElseIf IsOperador(cCode)    
    //Operador de parenteses
    cType := "OPERADOR"
ElseIf cCode == "MAIOR" .Or. cCode == "MENOR"
    //Aqui é fórmula
    cType := "FORMULA_MAIOR_MENOR"
Else
    //Aqui somente sobrou operador
    cType := "OPERANDO"
EndIF

Return cType

//-------------------------------------------------------------------
/*/{Protheus.doc} FORMCARG

Função responsável por efetuar a carga dos operandos primários

@author Rafael S Oliveira
@since 06/02/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Function FORMCARG()

//Grava os operandos de valor de origem
GrvOpSys("0")
//Grava os operandos de índices de cálculos
GrvOpSys("9")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvOpSys

Função que grava os operandos gerados automaticamente pelo sistema

@author Erick Dias
@since 29/06/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Static Function GrvOpSys(cTpRegra)

Local aOp         := {}
Local nX          := 0
Local cAlias as character
Local cPrefixo    := ""
Local cCodigo     := ""
Local cFormula    := ""
Local cDescri     := ""
Local oCIN  as object
Local oCIN2 as object
Local nTotReg     := 0

//Abaixo resolve quais informações deverão ser gravadas/verificadas
If cTpRegra == "0"
    aOp := FormOperPri()
    cPrefixo    := xFisTpForm("0") //"0" = Operador primário
ElseIf cTpRegra == "9"
    //Dados a serem carregados com operandos de índice de cálculos
    aOp := FIndicesCalc()
    cPrefixo    := xFisTpForm("9") //"9" = Operador de índice de cálculo
EndIf

//Query na CIN
cQuery := "SELECT COUNT(CIN.CIN_ID) REGISTROS FROM "+RetSqlName("CIN")+" CIN "
cQuery += "WHERE CIN.CIN_FILIAL = ? AND CIN.CIN_TREGRA = ? AND D_E_L_E_T_ = ? "
cQuery := ChangeQuery(cQuery)
oCIN  := FwExecStatement():New(cQuery)

oCIN:SetString(1, xFilial('CIN'))
oCIN:SetString(2, cTpRegra)
oCIN:SetString(3, ' ')

nTotReg := oCIN:ExecScalar('REGISTROS')

FREEOBJ(oCIN)

//Se a quantidade de registros retornada na query for igual a quantidade das informações, então não precisa ser feito nada.
//Porém se a quantidade for diferente, então existe alguma informação que não está gravada no banco, e será verificado uma a uma para gravar
If nTotReg < Len(aOp)    
    
    dbSelectArea("CIN")
    CIN->(dbSetOrder(1)) //CIN_FILIAL+CIN_CODIGO+CIN_ALTERA+CIN_ID
    CIN->(dbGoTop())

    //Laço doas fórmuas verificando se estão gravadas no banco. Se não estiver, então o banco será atualizado.
    For nX := 1 to Len(aOp)

        cCodigo     := aOp[nX][2]
        cFormula    := cPrefixo + aOp[nX][2]
        cDescri     := aOp[nX][1]

        cQuery := "SELECT CIN_FILIAL, CIN_CODIGO "
        cQuery += "FROM "+RetSqlName("CIN")
        cQuery += " WHERE CIN_FILIAL = ? AND CIN_CODIGO = ? AND D_E_L_E_T_ = ? "
        cQuery := ChangeQuery(cQuery)
        oCIN2  := FwExecStatement():New(cQuery)

        oCIN2:SetString(1, xFilial('CIN'))
        oCIN2:SetString(2, cFormula)
        oCIN2:SetString(3, ' ')

        cAlias := oCIN2:OpenAlias()

        If (cAlias)->(EOF())  
            GravaCIN("1", cTpRegra, cCodigo, "", cDescri, cFormula)
        EndIf
                
        (cAlias)->(dbCloseArea())

        FREEOBJ( oCIN2 )
    Next
Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FormOperPri

Função responsável definir os operandos primários

@author Rafael S Oliveira
@since 06/02/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Static Function FormOperPri()

Local aOpBase := {}
Local aOpAliq := {}
Local aCarga  := {}
Local nI      := 0
    
    //Adiciona Base
    aOpBase := FSA161VORI(.T.)
    
    For nI := 1  to len(aOpBase)
        If !Empty(aOpBase[nI][2]) .and. !Empty(aOpBase[nI][3])
            aAdd(aCarga,{aOpBase[nI][2] , aOpBase[nI][3]})       
        Endif
    Next

    //Adicionado registros que não estão no Combo da base    
    aAdd(aCarga,{"Valor do Desconto"                                                ,"DESCONTO"                 })    
    aAdd(aCarga,{"Valor do Seguro"                                                  ,"SEGURO"                   })
    aAdd(aCarga,{"Valor das Despesas"                                               ,"DESPESAS"                 })
    aAdd(aCarga,{"ICMS Desonerado"                                                  ,"ICMS_DESONERADO"          })       
    aAdd(aCarga,{"ICMS Retido"                                                      ,"ICMS_RETIDO"              })
    aAdd(aCarga,{"Dedução de Subempreitada"                                         ,"DEDUCAO_SUBEMPREITADA"    })
    aAdd(aCarga,{"Dedução de Materiais"                                             ,"DEDUCAO_MATERIAIS"        })
    aAdd(aCarga,{"Dedução INSS Subcontratada"                                       ,"DEDUCAO_INSS_SUB"         })
    aAdd(aCarga,{"Dedução INSS"                                                     ,"DEDUCAO_INSS"             })
    aAdd(aCarga,{"Base do IPI na Transferência"                                     ,"BASE_IPI_TRANSFERENCIA"   })
    aAdd(aCarga,{"Custo (Última Aquisição)"                                         ,"CUSTO_ULT_AQUI"          })
    aAdd(aCarga,{"Desconto (Última Aquisição)"                                      ,"DESCONTO_ULT_AQUI"       })
    aAdd(aCarga,{"MVA (Última Aquisição)"                                           ,"MVA_ULT_AQUI"            })
    aAdd(aCarga,{"Quantidade (Última Aquisição)"                                    ,"QUANTIDADE_ULT_AQUI"     })
    aadd(aCarga,{"Valor unitario (Última Aquisição)"                                ,"VLR_UNITARIO_ULT_AQUI"})
    aadd(aCarga,{"Valor antecipação (Última Aquisição)"                             ,"VLR_ANTECIPACAO_ULT_AQUI"})
    aadd(aCarga,{"Valor ICMS (Última Aquisição)"                                    ,"ICMS_ULT_AQUI"})
    aadd(aCarga,{"Indice auxiliar de FECP (Última Aquisição)"                       ,"IND_AUXILIAR_FECP_ULT_AQUI"})
    aadd(aCarga,{"Base ICMS ST (Última Aquisição)"                                  ,"BASE_ICMSST_ULT_AQUI"})
    aadd(aCarga,{"Aliquota ICMS ST (Última Aquisição)"                              ,"ALQ_ICMSST_ULT_AQUI"})
    aadd(aCarga,{"Valor ICMS ST (Última Aquisição)"                                 ,"VLR_ICMSST_ULT_AQUI"})
    aadd(aCarga,{"Base FECP ST (Última Aquisição)"                                  ,"BASE_FECP_ST_ULT_AQUI"})
    aadd(aCarga,{"Aliquota FECP ST (Última Aquisição)"                              ,"ALQ_FECP_ST_ULT_AQUI"})
    aadd(aCarga,{"Valor FECP ST (Última Aquisição)"                                 ,"VLR_FECP_ST_ULT_AQUI"})
    aadd(aCarga,{"Base ICMS ST Recolhido Anteriormente (Última Aquisição)"          ,"BASE_ICMSST_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Aliquota ICMS ST Recolhido Anteriormente (Última Aquisição)"      ,"ALQ_ICMSST_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Valor ICMS ST Recolhido Anteriormente (Última Aquisição)"         ,"VLR_ICMSST_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Base FECP Recolhido Anteriormente (Última Aquisição)"             ,"BASE_FECP_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Aliquota FECP Recolhido Anteriormente (Última Aquisição)"         ,"ALQ_FECP_REC_ANT_ULT_AQUI"})
    aadd(aCarga,{"Valor FECP Recolhido Anteriormente (Última Aquisição)"            ,"VLR_FECP_REC_ANT_ULT_AQUI"})
    aAdd(aCarga,{"Valor Zero de Base / Alíquota"                                    ,"ZERO"                    })
    aAdd(aCarga,{"Aliq.Contribuição Previdenciária (CPRB)"                          ,"ALQ_CPRB"                 })
    aAdd(aCarga,{"Valor Manual"                                                     ,"VAL_MANUAL"              })
    aadd(aCarga,{"Base ICMS (Última Aquisição)"                                     ,"BASE_ICMS_ULT_AQUI"})
    aadd(aCarga,{"Aliquota ICMS (Última Aquisição)"                                 ,"ALQ_ICMS_ULT_AQUI"})
    aadd(aCarga,{"Valor do ICMS (Ultima Aquisição de Estrutrura de Produto)"        ,"VLR_ICMS_ULT_AQUI_ESTRUTURA"})
    aadd(aCarga,{"Base ICMS ST Recolhido Anteriormente "                            ,"BASE_ICMSST_REC_ANT"})
    aadd(aCarga,{"Aliquota ICMS ST Recolhido Anteriormente "                        ,"ALQ_ICMSST_REC_ANT"})
    aadd(aCarga,{"Valor ICMS ST Recolhido Anteriormente "                           ,"VLR_ICMSST_REC_ANT"})
    aadd(aCarga,{"Base FECP Recolhido Anteriormente "                               ,"BASE_FECP_REC_ANT"})
    aadd(aCarga,{"Aliquota FECP Recolhido Anteriormente "                           ,"ALQ_FECP_REC_ANT"})
    aadd(aCarga,{"Valor FECP Recolhido Anteriormente "                              ,"VLR_FECP_REC_ANT"})
    aadd(aCarga,{"Valor do Desconto de ICMS da Zona Franca de Manaus "              ,"DESC_ICMS_ZF    "})
    aadd(aCarga,{"Valor do Desconto de PIS da Zona Franca de Manaus "               ,"DESC_PIS_ZF     "})
    aadd(aCarga,{"Valor do Desconto de COFINS da Zona Franca de Manaus "            ,"DESC_COF_ZF     "})
    aadd(aCarga,{"Valor do Desconto de ICMS+PIS+COFINS da Zona Franca de Manaus "   ,"DESC_TOTAL_ZF   "})
    aadd(aCarga,{"Valor do Frete Pauta "                                            ,"VAL_FRETE_PAUTA"})
    aadd(aCarga,{"Base do IPI na nota de origem "                                   ,"BASE_IPI_RASTRO_ORIG"})
    aadd(aCarga,{"Valor do Pedágio "                                                ,"VLR_PEDAGIO"})
    aadd(aCarga,{"Base via Integração"                                              ,"BASE_INTEGRACAO"})
    aadd(aCarga,{"Alíquota via Integração"                                          ,"ALIQUOTA_INTEGRACAO"})
    aadd(aCarga,{"Valor via Integração"                                             ,"VALOR_INTEGRACAO"})
    aadd(aCarga,{"Valor de PIS - apuração"                                          ,"VAL_PS2"})
    aadd(aCarga,{"Valor de COFINS - apuração"                                       ,"VAL_CF2"})
    aadd(aCarga,{"Valor Imposto de Importação"                                      ,"VAL_II"})
    aadd(aCarga,{"Valor do DIFAL"                                                   ,"VAL_DIFAL"})
    aadd(aCarga,{"Valor do FECP"                                                    ,"VAL_FECP"})
    aadd(aCarga,{"Valor de FECP Diferencial"                                        ,"VAL_FCPDIF"})
    aadd(aCarga,{"Valor de ISS"                                                     ,"VAL_ISS"})   
   
    //Adicona Aliquota 
    aOpAliq := C162CBOX(.T.) 
    
    For nI := 1  to len(aOpAliq)
        If !Empty(aOpAliq[nI][2]) .and. !Empty(aOpAliq[nI][3])  
            aAdd(aCarga,{aOpAliq[nI][2] , aOpAliq[nI][3]})         
        Endif
    Next          

    //Adicionado registro que não estão no Combo da alíquota
    aAdd(aCarga,{"Alq. Apuração SN ISS"     ,"ALQ_SIMPLES_NACIONAL_ISS"     })
    aAdd(aCarga,{"Alq. Apuração SN ICMS"    ,"ALQ_SIMPLES_NACIONAL_ICMS"    })

Return aCarga


//-------------------------------------------------------------------
/*/{Protheus.doc} FIndicesCalc

Função responsável por retornar os operandos dos índices de cálculos, como
MVA, Majoraçã, Pauta.

@author Erick Dias
@since 29/06/2020
@version 12.1.30

/*/
//-------------------------------------------------------------------
Static Function FIndicesCalc()
Local aCarga    := {}

//Adicionando os operandos de índice de cálculos vinculados ao cadastro de NCM 
aAdd(aCarga,{"Percentual Redução de Base"                   ,"PERC_REDUCAO_BASE"         })
aAdd(aCarga,{"Margem de Valor Agregado"                     ,"MVA"                       })
aAdd(aCarga,{"Percentual de Majoração de Alíquota"          ,"MAJORACAO"                 })
aAdd(aCarga,{"Valor de Pauta"                               ,"PAUTA"                     })
aAdd(aCarga,{"Índice Auxiliar de MVA"                       ,"INDICE_AUXILIAR_MVA"       })
aAdd(aCarga,{"Índice Auxiliar de Majoração"                 ,"INDICE_AUXILIAR_MAJORACAO" })   
aAdd(aCarga,{"Alíquota Tabela Progressiva"                  ,"ALIQ_TAB_PROGRESSIVA"      })   
aAdd(aCarga,{"Dedução Tabela Progressiva"                   ,"DED_TAB_PROGRESSIVA"       })   
aAdd(aCarga,{"Dedução por Dependentes"                      ,"DED_DEPENDENTES"           })   
aAdd(aCarga,{"Alíquota da operação de Serviço"              ,"ALQ_SERVICO"               })
aAdd(aCarga,{"Indicadores Econômicos FCA"                   ,"INDICE_AUXILIAR_FCA"       })
aAdd(aCarga,{"Percentual de Diferimento"                    ,"PERC_DIFERIMENTO"          })

If fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')
    aAdd(aCarga,{"Alíquota do NCM"                              ,"ALIQ_NCM"              })
EndIf

if fisExtCmp('12.1.2510', .T.,'F28','F28_REDALI')
    aAdd(aCarga,{"Percentual de Redução de Alíquota"      ,"PERC_REDUCAO_ALIQ"})
EndIf

Return aCarga

//-------------------------------------------------------------------
/*/{Protheus.doc} PesqCIN
Função executada quando usuário entrada na rotina FISA170
Esta rotina verifica a inexistencia de formlas para regras de base, aliquota ou calculo 

Retorna registros da tabela especificada não encontrados na CIN

@author Rafael S Oliveira
@since 10/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------

Function PesqCIN(cTab) 
Local cAlias    := GetNextAlias()
Local cId	    := cTab+"_ID"
Local cFrom	    := RetSqlName(cTab) + " "+ cTab
Local cWhere	:= cTab+".D_E_L_E_T_=' '"

cId     := "%"+cId+"%" 
cFrom   := "%"+cFrom+"%"
cWhere  := "%"+cWhere+"%"

//Retorna registros não encontrados em ambas as tabelas
BeginSql Alias cAlias

    SELECT
        %Exp:cId%
    FROM
        %Exp:cFrom%
    LEFT OUTER JOIN %TABLE:CIN% CIN ON (CIN_IREGRA = %Exp:cId% AND CIN.%NOTDEL%)
    WHERE 
        CIN.CIN_IREGRA IS NULL
        AND	 %Exp:cWhere%

EndSql

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} vldPreFixFor
Função que realizar a validação do prfixo da fórmula do tributo com as 
regras de base e alíquota selecionadas.
Isso é necessário pois o usuário somente poderá editar a fórmula
depois da base * alíquota, do contrário não saberemos o que gravar no campo
base e alíquota, teríamos somente o valor.

@param cFormula - Fórmula atual da regra
@param cRetErro - Erro a ser exibido caso o prefixo não corresponda
@return - retorna verdadeiro se o prefixo corresponder

@author Erick Dias
@since 11/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
//Static Function vldPreFixFor(cFormula, cRetErro)
//
//Local aFormula	:= StrTokArr(alltrim(cFormula)," ")
//Local lRet      := .F.
//Local cPrefixo  := ""
//Local cRegras   := Fsa160Prefix()
//Local nX        := 0 
//TODO rever aqui esta validação...podemos ter diversos modelos e não dá pra chumbar somente um padrão.
// cRetErro    := "O prefixo da fórmula deve corresponder as regras de base e alíquota informadas:" +  CRLF +  CRLF + cRegras

// //Itero o array para verifica se todos os operandos estão devidamente cadastrados.
// For nX := 1 to Len(aFormula)
//     cPrefixo += Alltrim(aFormula[nX])
//     If cPrefixo == cRegras
//         lRet    := .T.
//         cRetErro    := ""
//     EndIF
// Next nX

//Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} HabEditTrib
Função auxiliar que permte habilitar o botão de edição da fórmula
no cadastro do tributo.

@param cModelo - Modelo a qual está consumindo o componente da fórmula
@return - Retorna verdadeiro se deve habilitar o botão editar.

@author Erick Dias
@since 13/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function HabEditTrib(cModeloCab,cModelo)
Local lRet  := .T.

IF cModelo == "FORMULCAL"
    lRet    := Fsa160ETrb()
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTPCIN
Função auxiliar que retorna os tipo da CIN
conforme selecionado no combo.
A princípio esta função será utilizada na consulta padrão da CIN

@author Erick Dias
@since 16/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function xFisTPCIN()
Local nTipo := M->CIN_FILTRO
Local cRet  := ""

If nTipo == "01" //Regras Primárias
    cRet  := "0 "
ElseIf nTipo == "02" //Regras de Base de Cálculo
    cRet  := "1 "
ElseIf nTipo == "03" //Regras de Alíquota
    cRet  := "2 "
ElseIf nTipo == "04" //URF
    cRet  := "4 "
ElseIf nTipo $ "05/Z1" //Regras de Tributos
    cRet  := "6 /7 /8 /11/12/13"
ElseIf nTipo == "06" //Índices de cálculo
    cRet  := "9 "    
ElseIf nTipo == "07" //Alíquotas da tabela progressiva
    cRet  := "11"    
ElseIf nTipo == "08" //Dedução da tabela progressiva
    cRet  := "12"            
ElseIf nTipo == "09" //Dedução por dependentes
    cRet  := "13"            
EndIF
 
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTRBCIN
Função auxiliar que retorna o tributo selecionado pelo usuário
para poder filtrar a consulta das regras

@author Erick Dias
@since 16/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function xFisTRBCIN()
Return M->CIN_TRIB

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTRBCIN
Função que retorna as opções do combo para filtrar o tipo das regras.
@author Erick Dias
@since 16/06/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Function XFISTREGRA()                                                                                                                   

Local cRet := '01=Valores de Origem;02=Regra Base de Cálculo;03=Regra de Alíquota;04=Regras de URF;05=Regras de Tributo;06=Índices de Cálculo;ZZ=Valor Manual'

if F2B->(FieldPos("F2B_STATUS")) > 0
    cRet += ";Z1=Regras em teste"
endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} HelpPrx
Função que monta tela com mais informações e eplicações sobre os prefixos.

@author Erick Dias
@since 08/07/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function HelpPrx()

Local cTxtIntro := ""
cTxtIntro += "<table width='100%' border=2 cellpadding='15' cellspacing='5'>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='5' align='center'><font face='Tahoma' size='+2'>"
cTxtIntro += "<b>Detalhamento dos Prefixos das Regras.</b>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='5'><font face='Tahoma' color='#000099' size='+1'>"
cTxtIntro += "'O:' Regras criadas automaticamente pelo sistema, possuem valores de origem do documento fiscal, tais como frete, desconto e valor da mercadoria.<br><br>"
cTxtIntro += "'B:' Regras de Base de Cálculo criadas pelo usuário.<br><br>"
cTxtIntro += "'A:' Regras de Alíquota criadas pelo usuário.<br><br>"
cTxtIntro += "'U:' Regras de Unidade de Referência Fiscal(URF) criadas pelo usuário.<br><br>"
cTxtIntro += "'I:' Índices criados automaticamente pelo sistema, tais como percentual de Majoração, MVA e Pauta.<br><br>"
cTxtIntro += "'BAS:' Base de Cálculo do Tributo.<br><br>"
cTxtIntro += "'ALQ:' Alíquota do Tributo.<br><br>"
cTxtIntro += "'VAL:' Valor do Tributo.<br><br>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>"
cTxtIntro += "</table>"

DEFINE MSDIALOG oDlgUpd TITLE "TCF(Totvs Configurador de Tributos)" FROM 00,00 TO 430,700 PIXEL
TSay():New(005,005,{|| cTxtIntro },oDlgUpd,,,,,,.T.,,,340,300,,,,.T.,,.T.)       
//TButton():New( 220,180, '&Processar...', oDlgUpd,{|| RpcClearEnv(), oProcess := MsNewProcess():New( {|| FISProcUpd(aEmpr, oProcess) }, 'Aguarde...', 'Iniciando Processamento...', .F.), oProcess:Activate(), oDlgUpd:End()},075,015,,,,.T.,,,,,,)
//TButton():New( 220,270, '&Cancelar', oDlgUpd,{|| RpcClearEnv(), oDlgUpd:End()},075,015,,,,.T.,,,,,,)

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BackSpace
Função que deleta o último operando/operador da fórmula, para que não seja
necessário refazer toda a fórmula

@author Erick Dias
@since 14/07/2020
@version P12.1.30
/*/
//-------------------------------------------------------------------
Static Function BackSpace(cModelo, lRefresh, cView)

Local oModel    :=	FWModelActive()
Local oFormul	:= oModel:GetModel(cModelo)
Local oView 	:= 	FWViewActive()
Local cForm     := oFormul:GetValue("CIN_FORMUL",1)
Local aFormula	:= StrTokArr(alltrim(cForm)," ")
Local cNewFor   := " "
Local nX        := 0

//Montarei a fórmula sem último elemento
For nX:= 1 to Len(aFormula) - 1
    cNewFor += aFormula[nX]
    cNewFor += " "
Next nX

//Limpa o conteúdo das fórmulas e do código da regra
oFormul:LoadValue('CIN_FORMUL', cNewFor )

//Atualiza as Views
If lRefresh .And. !Empty(cView)
	oview:Refresh( cView )
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FsOriTrb
Lista de opções para o campo de origem do tributo
fisa
@author Erich Buttner
@since 19/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function FsOriTrb(lValid)
Local xRet := ""

Default lValid := .F.

If lValid

    xRet := .T.

Else

    xRet :=  '01=Própria operação;02=Nota fiscal referenciada como origem;'

Endif

RETURN xRet

/*/{Protheus.doc} xPrefVld
   Função responsavel por acertar a formula para validação, removendo prefixos indesejados.
    @type  Static Function
    @author Erich Buttner
    @since 20/03/2024
    @version 12.1.2210, 12.1.2310
    @param cText - texto da formula é passado como refencia pois é retirado o prefixo para efeito de validação,
    @param cOriTrb - Origem do tributo
    @param lValid - Validação da formula 
    @return cText - retorna o texto da formula sem o prefixo
/*/
Static Function xPrefVld(cText)

cText := StrTran(cText,"ORI:","")

Return cText

/*/{Protheus.doc} xPrefDef
   Função responsavel por definir o prefixo da formula de acordo com a referencia do tributo
    @type  Static Function
    @author Erich Buttner
    @since 20/03/2024
    @version 12.1.2210, 12.1.2310
    @param cText - texto da formula é passado como refencia pois é retirado o prefixo para efeito de validação,
    @param cOriTrb - Origem do tributo
    @param lValid - Validação da formula 
    @return cText - retorna o texto da formula sem o prefixo
/*/
Static Function xPrefDef(cText, cOriTrb)

If cOriTrb == "02"
    cText := "ORI:" + cText
EndIf

Return cText

/*/{Protheus.docn xForGVld
    Função responsável pelo gatilho do campo CIN_ORITRB
    @type  Function
    @author Erich Buttner
    @since 19/03/2024
    @version 12.1.2210, 12.1.2310
    @param oModel - objeto do mvc da tela de base de calculo, cmpTrigger - campo que disparou o gatilho
    @return cRet - retorna o valor do campo CIN_ORITRB
    @example
    (examples)
    @see (links_or_references)
/*/
Function xForGVld(oModel, cmpTrigger,cModForm)
Local oView 	:= 	FWViewActive()
Local cFiltro	:= oModel:GetValue(cModForm, cmpTrigger)
Local oFormul   := oModel:GetModel(cModForm)
Local lOriTrb   := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0 
Local lRet      := .T.

If lOriTrb
    If cFiltro $ '05/Z1'
        oModel:SetValue(cModForm,'CIN_ORITRB','01')
    Else
        oFormul:LoadValue('CIN_ORITRB' , Criavar("CIN_ORITRB")) 
        oview:Refresh( 'VIEW_FORMULA')
    EndIf
EndIf
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFormula
Atribui aos campos de formula em formato NPI da tabela CIN a formula
transformada conforme o tamanho destes campos.
@author Nilson César
@since 11/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetFormula( cFormNPI )

    CIN->CIN_FNPI     := cFormNPI

    If lCpoNPIMemo
        CIN->CIN_FNPI_M   := cFormNPI
    EndIf
    
return
