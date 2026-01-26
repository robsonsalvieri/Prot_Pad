#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FISA178.CH"
#INCLUDE "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA178 SOURCE FISA178


Static aArrConsul := {}
Static oHMCad     := Nil
STATIC lBuild 	  := GetBuild() >= "7.00.131227A"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA178()

Esta rotina tem objetivo de realizar cadastro de mensagem

Esta rotina estará disponível somente na versão 12.1.33

@author bruce mello
@since 28/04/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function FISA178()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ8")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ8")
    oBrowse:SetDescription(STR0001) // Cadastro de mensagem
    oBrowse:Activate()
Else    
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.


@author bruce mello
@since 28/04/2021
@version 12.1.33

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA178" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro de mensagem

@author bruce mello
@since 28/04/2021
@version 12.1.33

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel := Nil //Criação do objeto do modelo de dados
Local oCabecalho := FWFormStruct(1,"CJ8") //Estrutura Pai do cabeçalho da rotina

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA178',/*Pre-Validacao*/,{|oModel|ValidModel(oModel) })

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA178",,oCabecalho)

//Inicializa campo com ID
oCabecalho:SetProperty('CJ8_ID' , MODEL_FIELD_INIT ,{|| FWUUID("CJ8") } )

//Não permite alterar o conteúdo do campo CJ8_CODREG na edição
oCabecalho:SetProperty('CJ8_CODREF' ,MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('CJ8_CODREF' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

oCabecalho:SetProperty('CJ8_TRIFIL' , MODEL_FIELD_WHEN, {|| AllTrim(oModel:GetValue('FISA178',"CJ8_TPREGR")) $ "1|3|4"})
oCabecalho:SetProperty('CJ8_REGRA'  , MODEL_FIELD_WHEN, {|| EditRegra(oModel)})
oCabecalho:SetProperty('CJ8_CONSUL' , MODEL_FIELD_WHEN, {|| EditConsul(oModel)})
oCabecalho:SetProperty('CJ8_TBCONF' , MODEL_FIELD_WHEN, {|| EditTbConf(oModel) })
oCabecalho:SetProperty('CJ8_MENSG'  , MODEL_FIELD_WHEN, {|| .T. })


oModel:SetPrimaryKey({"CJ8_FILIAL","CJ8_CODREF"})

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) // Cadastro de TMensagem de Tributos.

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.


@author bruce mello
@since 28/04/2021
@version 12.1.33

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA178" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "CJ8", {|x| AllTrim( x ) $ "CJ8_FILIAL/CJ8_ID/CJ8_CODREF/CJ8_DESC"})
Local oRegra     := FWFormStruct(2, "CJ8", {|x| AllTrim( x ) $ "CJ8_CONSUL/CJ8_TPREGR/CJ8_TRIFIL/CJ8_REGRA/CJ8_TBCONF"}) //Somente adiciona na view da regra o campo CJ8_CONSUL
Local oFormula  := FWFormStruct(2, "CJ8", {|x| AllTrim( x ) == "CJ8_MENSG"}) //Somente adiciona na view da fórmula o campo CJ8_MENSG
Local oView      := Nil


oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA178' )

//Retira os campos da View
oCabecalho:RemoveField( 'CJ8_ID' )

//Cria as views do operando e da fórmula
oView:AddField( 'VIEW_FORMULA' , oFormula, 'FISA178')

//Cria as view do campo regra
oView:AddField( 'VIEW_REGRA' , oRegra, 'FISA178')

//Ajuste dos títulos dos campos de filtros de fórmula
oRegra:SetProperty("CJ8_TPREGR", MVC_VIEW_TITULO, "Tipo da Regra")
oRegra:SetProperty("CJ8_TRIFIL", MVC_VIEW_TITULO, "Regra a ser consultada")
oRegra:SetProperty("CJ8_REGRA" , MVC_VIEW_TITULO,  "Tributo para a consulta")
oRegra:SetProperty("CJ8_TBCONF", MVC_VIEW_TITULO, "Tributo Genérico")   
oRegra:SetProperty("CJ8_CONSUL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")   


//Ordem dos campos para realizarem filtros nas fórmulas
oRegra:SetProperty("CJ8_TPREGR" , MVC_VIEW_ORDEM, "01")
oRegra:SetProperty("CJ8_TRIFIL" , MVC_VIEW_ORDEM, "02")    
oRegra:SetProperty("CJ8_REGRA"  , MVC_VIEW_ORDEM, "03")
oRegra:SetProperty("CJ8_TBCONF" , MVC_VIEW_ORDEM, "04")
oRegra:SetProperty("CJ8_CONSUL" , MVC_VIEW_ORDEM, "05")


//Aba da direita dividida em duas partes horizontais
oView:CreateHorizontalBox( 'CABECALHO'              , 100,,.T. )

oView:CreateHorizontalBox( 'TITULO1'                , 30,,.T.,) //Aqui crio um objeto vazio somente para colocar o título
oView:CreateHorizontalBox( 'BOX_SUPERIOR'           , 140,,.T.)
oView:CreateVerticalBox( 'BOX_SUPERIOR_ESQUERDO'    , 70,'BOX_SUPERIOR',.F.) //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
oView:CreateHorizontalBox( 'BOX_INTERMEDIARIO'      , 80 ,,.T.)

oView:CreateHorizontalBox( 'TITULO2'                 , 30,,.T.) //Aqui crio um objeto vazio somente para colocar o título
oView:CreateHorizontalBox( 'BOX_INFERIOR'           , 330,,.T. )
    
//Painel com os botões
//Adiciono componente da fórmula, que está definido por meio da função xMsgFormul().
oView:AddOtherObject("BOTOES", {|oPanel| xMsgFormul(oPanel, "FISA178","VIEW_FORMULA","2", "CJ8_CODREF", "FISA178", "CJ8_CONSUL", "VIEW_REGRA")})

//Painel vazio para ter o título da tela
oView:AddOtherObject("LABEL", {|oPanel| xFisLabel(oPanel)}) 
oView:AddOtherObject("MENSAGEM", {|oPanel| xFisLabel(oPanel)}) 

//Campos de Cabeçalho
oView:SetOwnerView( 'VIEW_CABECALHO'    , 'CABECALHO')              

//Campos de filtros
oView:SetOwnerView( 'LABEL'        , 'TITULO1')       
oView:SetOwnerView( 'VIEW_REGRA'    , 'BOX_SUPERIOR_ESQUERDO')              

//Botões para manipular fórmula
oView:SetOwnerView( 'BOTOES'        , 'BOX_INTERMEDIARIO')       

//Fórmula
oView:SetOwnerView( 'MENSAGEM'        , 'TITULO2')       
oView:SetOwnerView( 'VIEW_FORMULA'  , 'BOX_INFERIOR')

//Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
oView:SetViewProperty( "VIEW_FORMULA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

oView:EnableTitleView('LABEL'   , "Campos de Filtro")     
oView:EnableTitleView('MENSAGEM', "Composição da Mensagem")

oView:SetFieldAction('CJ8_TPREGR' , {|oView| X178TRIFIL(oView,oModel) })
oView:SetFieldAction('CJ8_TRIFIL' , {|oView| X178REGRA(oView,oModel) , X178CONSUL(oView,oModel) })
oView:SetFieldAction('CJ8_REGRA'  , {|oView| X178CONSUL(oView,oModel) })
oView:SetFieldAction('CJ8_TBCONF' , {|oView| X178CONSUL(oView,oModel) })


Return oView
       

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Função que valida se o código de perfil cadastrado já existe

@author Rafael Oliveira 
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCod 	:= oModel:GetValue ('FISA178',"CJ8_CODREF")
Local lRet      := .T.

//Verifico se o perfil já existe.
//Procura se já existe regra de alíquota com o mesmo código e ativa
CJ8->(DbSetOrder(2))

If CJ8->( MsSeek ( xFilial('CJ8') + cCod  ) )
    Help( ,, 'Help',, STR0003, 1, 0 ) 
    return .F.
EndIF

//Não pode digitar operadores e () no código
If "*" $ cCod .Or. ;
   "/" $ cCod .Or. ;
   "-" $ cCod .Or. ;
   "+" $ cCod .Or. ;
   "(" $ cCod .Or. ;
   ")" $ cCod
    Help( ,, 'Help',, STR0004, 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCod)
    Help( ,, 'Help',, STR0005, 1, 0 ) 
    Return .F.
EndIf

Return lRet


/*/{Protheus.doc} EditRegra
    (Regra para liberar campo CJ8_REGRA)    
    /*/
Static Function EditRegra(oModel)
Local lRet    := .F.
Local cTPREGR := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TPREGR"))
Local cTriFil := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TRIFIL"))

IF cTPREGR <> "2" .and. cTriFil $ '1|2|3'
    lRet    := .T.
Endif

Return lRet

/*/{Protheus.doc} EditConsul
    (Regra para liberar campo CJ8_CONSUL)    
    /*/
Static Function EditConsul(oModel)
Local lRet    := .F.
Local cTPREGR := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TPREGR"))
Local cTriFil := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TRIFIL"))
Local cRegra  := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_REGRA"))
Local cTbConf := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TBCONF"))

IF cTPREGR <> "2"
    Do Case
        Case cTPREGR == '1' .and. !EmpTy(cRegra)
            lRet    := .T.
        Case cTPREGR $ '3|4' .and. !EmpTy(cTriFil)
            lRet    := .T.
    EndCase
Elseif cTPREGR == "2" .and. !EmpTy(cTbConf)
    lRet    := .T.
Endif

Return lRet

/*/{Protheus.doc} EditTbConf
    (Regra para liberar campo CJ8_TBCONF)    
    /*/
Static Function EditTbConf(oModel)
Local lRet    := .F.
Local cTPREGR := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TPREGR"))
//Local cTriFil := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TRIFIL"))
//Local cRegra  := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_REGRA"))
//Local cConsul := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_CONSUL"))

IF cTPREGR == "2"
    lRet    := .T. 
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Função responsável por realizar as validações do model 
Será acionada ao salvar o modelo.

@author Rafael Oliveira
@since 21/05/2021
@version P12.1.33

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cMensagem     := oModel:GetValue ('FISA178',"CJ8_MENSG")
Local cId           := oModel:GetValue ('FISA178',"CJ8_ID")
Local lRet          := .T.

//VAlidações para operações de inclusão e alteração.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE


    
    If lRet .AND. Empty(cMensagem)
        lRet:= .F.
        Help( ,, 'Help',, STR0006, 1, 0 ) // 'Valida se foi informado mensagem
    EndIF

EndIF

//Validação da exclusão, para que não permita excluir caso este ID já tenha sido utilizado na gravação da CDA ou CDV.
IF nOperation == MODEL_OPERATION_DELETE

    dbSelectArea("CDA")
    dbSetOrder(3)
    If CDA->(MsSeek(xFilial('CDA') + cId))
        lRet    := .F.
        Help( ,, 'Help',, STR0007, 1, 0 ) //"Esta regra já foi utilizada na gravação dos tributos genéricos e não poderá ser excluída!"
    EndIF

     dbSelectArea("CDV")
    dbSetOrder(4)
    If CDV->(MsSeek(xFilial('CDV') + cId))
        lRet    := .F.
        Help( ,, 'Help',,STR0007, 1, 0 ) //"Esta regra já foi utilizada na gravação dos tributos genéricos e não poderá ser excluída!"
    EndIF

EndIF

Return lRet


         /*/{Protheus.doc} xFisFormul

Função que cria os botões das fórmulas para as telas de regra de base de cálculo, 
alíquota e tributo.

@author Erick G. Dias
@since 28/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Static Function xMsgFormul(oPanel, cModelo, cViewForm, cTpRegra, cCodCab, cCodModCab, cCodRegra, cViewRegra)

//Local cCssBtn	:= getCss()
Local cCssChk	:= getCss("CHECKED.PNG")
Local cCssAdd	:= getCss("ADICIONAR_001.PNG")
Local cCssHelp	:= getCss("HELP.PNG")

//Posições do eixo Y das linhas
Local nYFisrtRow       := 1

//Posições do exixo X das linhas
Local nXFirstCol       := 2
Local nXSecondCol      := 72
Local nXThirdCol       := 150
//Local nXFourthCol      := 134
//Local nXFithCol        := 165
//Local nXSixthCol        := 196

//Dimensões do tamanho dos botões
//Local nWidthBtn        := 65 //Largura do botão
Local nHeightBtn       := 16 //Altura do botão
Local nWidthCss        := 65 //Largura do botão com CSS
Local nHeightCss       := 16 //Altura do botão com CSS
Local nWidthChk        := 77 //Largura do botão Chk

Default cTpRegra:= ""
Default cCodCab := ""
Default cCodModCab := ""
Default cCodRegra := CriaVar("CJ8_CONSUL")
Default cViewRegra:= ""

//Cria frame para colcoar os componentes
oLayer := FWLayer():New()
oLayer:Init(oPanel, .F.)
oLayer:AddLine('LIN1', 100, .F.) 
oPanel1  := oLayer:getLinePanel('LIN1')

oBtnEAdd   := TButton():New((nYFisrtRow - 1) , nXFirstCol   ,"      Adiciona" ,oPanel1,{|| xForBtnAct(cCodRegra,cModelo, .T., cViewForm, cViewRegra)},nWidthCss ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .and. HabBtnEdit(cModelo)  }   ,,.F.)
oBtnChk    := TButton():New(nYFisrtRow       , nXSecondCol  ,"     Validar Mensagem"        ,oPanel1,{|| xForCheck(cModelo,,.T.,cTpRegra, cCodCab,cCodModCab) }    ,nWidthChk ,nHeightCss ,,,.F.,.T.,.F.,,.F.,{||xCanEdit() .and. HabBtnvalid(cModelo)  }    ,,.F.)
oBtni      := TButton():New(nYFisrtRow       , nXThirdCol   ,"   "            ,oPanel1,{|| HelpPrx()}    ,14 ,nHeightBtn ,,,.F.,.T.,.F.,,.F.,{||.T.}                                              ,,.F.)

//Aplica o CSS nos botões
//oBtnDesfaz:SetCss(cCssBtn)
//oBtnClear:SetCss(cCssBtn)
oBtnEAdd:SetCss(cCssAdd)
oBtnChk:SetCss(cCssChk)
oBtni:SetCss(cCssHelp)


Return NIL

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
Static Function xForBtnAct(cText, cModelo, lRefresh, cView, cViewRegra)
Local oModel      := FWModelActive()
Local oView       := FWViewActive()
Local oFormul     := oModel:GetModel(cModelo)
Local cFiltro     := oFormul:GetValue("CJ8_TPREGR",1)
Local cFormul     := oFormul:GetValue("CJ8_MENSG",1)
Local cTPREGR     := AllTrim(oModel:GetValue('FISA178',"CJ8_TPREGR"))
Local cRegra      := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_REGRA"))
Local cTrifil     := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TRIFIL"))
Local cConsul     := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_CONSUL"))
Local cTbConf     := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_TBCONF"))
Local lProcessa   := .F.
Local lTribConfig := .F.
Local nPos        := 0


//Somente adicionará se o texto estiver preenchido.
If !Empty(cText) .And. !EmpTy(cFiltro) .And. !EmpTy(cConsul)

    IF cTPREGR == '2' .and. !EmpTy(cTbConf) //Regras configurador
        lTribConfig  := .T.
        lProcessa    := .T.
    ElseIF cTrifil $ "1|2|3" .and. !EmpTy(cRegra) //Tributos Legados
        lProcessa := .T.
    Elseif cTrifil $ "4|5|6|7|8" // Dados Da nota
        lProcessa := .T.
    Endif

    IF lProcessa
        //Verifico se estou adicionando o código da CJ8_CONSUL, para carregar o valor da tela
        If cText == "CJ8_CONSUL"
            
            //Pega possição selecionada do combo
            nPos := Val(cConsul)
            
            //Retorna com prefixo + Sufixo
            IF lTribConfig //Quando for tributo do configurador substitui TG pelo Codigo do Tributo
                cText := STRTRAN(aArrConsul[nPos][1], 'TG', AllTrim(cTbConf) , , 1 )                
            Else
                cText := aArrConsul[nPos][1]
            Endif

            //Limpando o campo do código da regra e valor
            oFormul:LoadValue("CJ8_CONSUL",CriaVar("CJ8_CONSUL"))

            //Atualiza a VIEW_REGRA
            If lRefresh .AND. !Empty(cViewRegra)
                oview:Refresh(cViewRegra)
            EndIf
        EndIf        
            

        //Adiciona o operador no final da fórmula
        oFormul:LoadValue('CJ8_MENSG', Alltrim(cFormul) + Space(1) + cText + Space(1))    

        //Atualiza as Views
        If lRefresh .AND. !Empty(cView)
            oview:Refresh(cView)
        EndIF

        //Atualiza a VIEW_REGRA
        If lRefresh .AND. !Empty(cViewRegra)
            oview:Refresh(cViewRegra)
        EndIf
    Endif

Endif 

Return             


            
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
cTxtIntro += "<b>Detalhamento Regras para compor a Mensagem.</b>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>"
cTxtIntro += "<tr>"
cTxtIntro += "<td colspan='5'><font face='Tahoma' color='#000099' size='+1'>"
cTxtIntro += "'Tipo de Regra a ser Consultada:' Pode ser selecionado 4 origens de informações: Tributos Legados/ Tributos do Configurador / Dados das Notas / Dados Cadastrais utilizados na Nota.<br><br>"
cTxtIntro += "'Regras a ser Consultada:' Esse campo será filtrado com o retorno do tipo de Regra, quando for Tributo / Dados da Nota / Dados Cadastrais  .<br><br>"
cTxtIntro += "'Tributo para Filtrar a Consulta:' Esse campo irá retornar todos os tributos filtrados pelas esferas Federal, Estadual e Municipal.<br><br>"
cTxtIntro += "'Valor a ser adicionado na Formula:' Retonar a lista de informações disponíveis dos Tributos e Dados da Nota a ser adicionado na Mensagem.<br><br>"
cTxtIntro += "'Trig. Config:'Retorna a consulta Padrão dos Tributos cadastrados no configurador.<br><br>"
cTxtIntro += "Será adicionado no campo Composição da Mensagem as referencias de valores a ser convertida.<br><br>"
cTxtIntro += "O conteudo selecionado e adicioando pode ser validado no intuido de informação, porém não impede a inclusão da mensagem.<br><br>"
cTxtIntro += "</font></td>"
cTxtIntro += "</tr>"
cTxtIntro += "</table>"


DEFINE MSDIALOG oDlgUpd TITLE "TCF(Totvs Configurador de Tributos)" FROM 00,00 TO 430,700 PIXEL
TSay():New(005,005,{|| cTxtIntro },oDlgUpd,,,,,,.T.,,,340,300,,,,.T.,,.T.)       
//TButton():New( 220,180, '&Processar...', oDlgUpd,{|| RpcClearEnv(), oProcess := MsNewProcess():New( {|| FISProcUpd(aEmpr, oProcess) }, 'Aguarde...', 'Iniciando Processamento...', .F.), oProcess:Activate(), oDlgUpd:End()},075,015,,,,.T.,,,,,,)
//TButton():New( 220,270, '&Cancelar', oDlgUpd,{|| RpcClearEnv(), oDlgUpd:End()},075,015,,,,.T.,,,,,,)

ACTIVATE MSDIALOG oDlgUpd CENTERED

Return          
                      
                      
//------------------------------------------------------------------
/*/{Protheus.doc} xCanEdit
Função que verifica o modelo ativo e obtem a operação.
@return bool - verdadeiro se a operação for inclusão ou edição.

@author Erick G. Dias
@since 31/01/2020
@version 12.1.30
/*/
//------------------------------------------------------------------
Static Function xCanEdit()
Local oModel        := FWModelActive()
return oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE


//-------------------------------------------------------------------
/*/{Protheus.doc} X178TPREG
Função para Retornar conteudo para combo do campo CJ8_TPREGR.

@author Bruce Mello
@since 04/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function X178TPREG()
Local cRet := ""

    cRet := '1=Tributos;2=Tributos Genéricos;3=Dados da Nota;4=Cadastro'
    
Return cRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} X178TRIFIL
Função para Retornar conteudo para combo do campo CJ8_TRIFIL
@author Bruce Mello
@since 04/05/2020
@version 1.0.
/*/
//-------------------------------------------------------------------
Function X178TRIFIL(oView,oModel)
Local aArray	:= {}
Local cTpRegr   := ""
Local oFormul   := nil

IF ValType(oView) =='O'
    oModel    := FWModelActive()
    oFormul   := oModel:GetModel("FISA178")
    cTpRegr   := AllTrim(oModel:GetValue('FISA178',"CJ8_TPREGR"))
    
    IF cTpRegr <> "2"
        oFormul:LoadValue("CJ8_TBCONF","")
    Endif

    If cTpRegr == "1"            

        AADD(aArray, '1=Federal')
        AADD(aArray, '2=Estadual')
        AADD(aArray, '3=Municipal')

    ElseIf cTpRegr == "2"
        oFormul:LoadValue("CJ8_REGRA","")
        oFormul:LoadValue("CJ8_CONSUL","")

        AADD(aArray, '')        

    ElseIf cTpRegr == "3"    
        

        AADD(aArray, '4=Cabeçalho da Nota')
        AADD(aArray, '5=Dados dos Itens')

    ElseIf cTpRegr == "4"    
        

        //AADD(aArray, '6=Cadastro de TES')
        AADD(aArray, '6=Cadastro de Produto')
        AADD(aArray, '7=Dados Participante da Nota')
        AADD(aArray, '8=Cadastro de Natureza')
    
    Endif
        
        
        oView:SetFieldProperty("VIEW_REGRA","CJ8_TRIFIL","COMBOVALUES",{aArray})     
        oview:Refresh()        
Else
    Return cRet := "1=Federal;2=Estadual;3=Municipal;4=Cabeçalho da Nota;5=Dados dos Itens;6=Cadastro de Produto;7=Dados Participante da Nota;8=Cadastro de Natureza"    
Endif


Return aArray

//-------------------------------------------------------------------
/*/{Protheus.doc} X178REGRA
Função para Retornar conteudo para combo do campo CJ8_REGRA
@author Bruce Mello
@since 04/05/2020
@version 1.0.
/*/
//-------------------------------------------------------------------
Function X178REGRA(oView,oModel)
Local aArrayRg	 := {}
Local cTpFil     := ""
Local oFormul    := nil
Local lView      := ValType(oView) =='O'
Local cRet       := ""

IF lView
    oModel    := FWModelActive()
    oFormul   := oModel:GetModel("FISA178")
    cTpFil   := AllTrim(oModel:GetValue('FISA178',"CJ8_TRIFIL"))
Endif

AADD(aArrayRg, " "     )    
If cTpFil == "1" .or. !lView
    AADD(aArrayRg, "1=FUNRURAL -  Fundo de Assistência ao Trabalhador Rural")
    AADD(aArrayRg, "2=SENAR - Serviço Nacional de Aprendizagem Rural")
    AADD(aArrayRg, "3=AFRMM - Adicional ao Frete para Renovação da Marinha Mercante")
    AADD(aArrayRg, "4=SEST - Serviço Social do Transporte e o Serviço Nacional de Aprendizagem do Transporte")
    AADD(aArrayRg, "5=PIS - Programa de Integração Social")
    AADD(aArrayRg, "6=COFINS - Contribuição para o Financiamento da Seguridade Social")
    AADD(aArrayRg, "7=II - Imposto de Importação")
    AADD(aArrayRg, "8=IRRF - Imposto de Renda Retido na Fonte")
    AADD(aArrayRg, "9=INSS - Instituto Nacional do Seguro Social")
    AADD(aArrayRg, "10=IPI - Imposto sobre Produtos Industrializados")
    AADD(aArrayRg, "11=CIDE - Contribuição de Intervenção no Domínio Econômico")
    AADD(aArrayRg, "12=CPRB - Contribuição Previdenciária sobre a Receita Bruta")
    AADD(aArrayRg, "13=CSLL - Contribuição Social sobre o Lucro Liquido")
    AADD(aArrayRg, "18=COFINS RETENÇÃO - Contribuição para Financiamento da Seguridade Social")
    AADD(aArrayRg, "19=COFINS SUBSTITUIÇÃO TRIBUTARIA - Contribuição para Financiamento da Seguridade Social ICMS ST")
    AADD(aArrayRg, "20=PIS RETENÇÃO - Programa de Integração Social")
    AADD(aArrayRg, "21=PIS SUBSTITUIÇÃO TRIBUTARIA - Programa de Integração Social ICMS ST")
    AADD(aArrayRg, "22=ZF - Zona Franca de Manaus")

Endif

if cTpFil == "2" .or. !lView
    AADD(aArrayRg, "1=FABOV - Fundo de Apoio a Bovinocultura de Corte")
    AADD(aArrayRg, "2=FACS - Fundo de Apoio à Cultura da Soja")
    AADD(aArrayRg, "3=FAMAD - Fundo de Apoio à Madeira")
    AADD(aArrayRg, "4=FASE/MT - Fundo Mato-Grossense de Apoio à Cultura da Semente")
    AADD(aArrayRg, "5=FETHAB - Fundo Estadual de Transporte e Habitação")
    AADD(aArrayRg, "6=FUNDERSUL - Fundo de Desenvolvimento do Sistema Rodoviário do Estado de Mato Grosso do Sul")
    AADD(aArrayRg, "7=FUNDESA - Fundo de Desenvolvimento e Defesa Sanitária Animal")
    AADD(aArrayRg, "8=IMA/MT - Instituto Mato-Grossense do Algodão" )
    AADD(aArrayRg, "9=TPDP - Taxa de Processamento de Despesa Pública do Estado da Paraíba")
    AADD(aArrayRg, "10=ICMS - Imposto sobre Circulação de Mercadorias e Serviços")
    AADD(aArrayRg, "11=ICMS-ST - Imposto sobre Circulação de Mercadorias e Serviços - Substituição Tributária")
    AADD(aArrayRg, "12=FEEF - Fundo Estadual de Equilíbrio Fiscal")
    AADD(aArrayRg, "13=PROTEG - Fundo de Proteção Social do Estado de Goiás")
    AADD(aArrayRg, "14=Crédito Presumido para Icms")
    AADD(aArrayRg, "15=Crédito Presumido sobre prestação Serviço de Transporte com ICMS/ST")
    AADD(aArrayRg, "16=FRTAUT - Frete Autônomo")
    AADD(aArrayRg, "17=FRTEMB - Frete Embarcado")
    AADD(aArrayRg, "18=PRESCG - Crédito Presumido pela Carga Tributária")
    AADD(aArrayRg, "19=DIFAL - Diferencial de Alíquota")
    AADD(aArrayRg, "20=Icms Complementar")
    AADD(aArrayRg, "21=Antecipação do ICMS")
    AADD(aArrayRg, "22=FECP ICMS - Fundo de Combate à Pobreza")
    AADD(aArrayRg, "23=FECP ICMS ST - Fundo de Combate à Pobreza ICMS-ST")
    AADD(aArrayRg, "24=FECP ICMS COMPLEMENTAR- Fundo de Combate à Probreza")
    AADD(aArrayRg, "25=ESTICM - Estorno Crédito do ICMS")
Endif

If cTpFil == "3" .or. !lView
    AADD(aArrayRg, "1=FUMIPQ - Fundo Municipal de Fomento à Micro e Pequena Empresa")
    AADD(aArrayRg, "2=ISS - Imposto Sobre Serviço")
EndIf

IF lView
    //Atualiza View
    oView:SetFieldProperty("VIEW_REGRA","CJ8_REGRA","COMBOVALUES",{aArrayRg})     
    oview:Refresh()    
Else
    //lista inicial do combo        
    cRet := ArrTokStr(aArrayRg,';') 

    ASize(aArrayRg,0) 

    Return cRet   
Endif

Return aArrayRg

//-------------------------------------------------------------------
/*/{Protheus.doc} X178CONSUL
Função para Retornar conteudo para combo do campo CJ8_CONSUL
@author Bruce Mello
@since 04/05/2020
@version 1.0.
/*/
//-------------------------------------------------------------------
Function X178CONSUL(oView,oModel)
Local aArrayRg := {}
Local cRegra   := ""
Local cTrifil  := ""
Local cTPREGR  := ""
Local cTbConf := ""
Local oFormul  := nil
Local nI       := 0
Local lView    := ValType(oView) == 'O'


IF lView
    oModel    := FWModelActive()
    oFormul   := oModel:GetModel("FISA178")
    cTPREGR   := AllTrim(oModel:GetValue('FISA178',"CJ8_TPREGR"))
    cTrifil   := AllTrim(oModel:GetValue('FISA178',"CJ8_TRIFIL"))    
    cRegra    := AllTrim(oModel:GetValue('FISA178',"CJ8_REGRA"))    
    cTbConf   := AllTrim(oModel:GetValue('FISA178',"CJ8_TBCONF"))
        
    ASize(aArrConsul,0) //Limpa Array 

    AADD(aArrayRg, " "     )
    IF cTPREGR == '2' .and. !EmpTy(cTbConf)
        aArrConsul := LoadMSGhash(Nil,'TG') //Pesquisa Municipal    
        For nI:=1 to len(aArrConsul)
            AADD(aArrayRg ,aArrConsul[nI][7])                    
        Next
    
    ElseIF cTrifil $ "1|2|3" // Tributos Federais, estaduais e Municipais
        IF !EmpTy(cRegra)
            IF cTrifil == '1'
                aArrConsul := LoadMSGhash(Nil,'F'+cRegra)  //Pesquisa Federal  
                For nI:=1 to len(aArrConsul)
                    AADD(aArrayRg ,aArrConsul[nI][7])                    
                Next                       
            Elseif cTrifil == '2'  
                aArrConsul := LoadMSGhash(Nil,'E'+cRegra) //Pesquisa Estadual    
                For nI:=1 to len(aArrConsul)
                    AADD(aArrayRg ,aArrConsul[nI][7])                    
                Next
            Elseif cTrifil == '3'
                aArrConsul := LoadMSGhash(Nil,'M'+cRegra) //Pesquisa Municipal    
                For nI:=1 to len(aArrConsul)
                    AADD(aArrayRg ,aArrConsul[nI][7])                    
                Next
            Endif
        Endif

    ElseIF cTrifil == "4" // Cabeçalho da Nota
        
        aArrConsul := LoadMSGhash(Nil,"NF")
        
        For nI:=1 to len(aArrConsul)
            AADD(aArrayRg ,aArrConsul[nI][7])                    
        Next
    ElseIF cTrifil == "5" //Dados dos Itens
        
        aArrConsul := LoadMSGhash(Nil,"IT")        
        
        For nI:=1 to len(aArrConsul)
            AADD(aArrayRg ,aArrConsul[nI][7])                    
        Next  
    ElseIF cTrifil == "6" // Cadastro de Produto
        aArrConsul := LoadMSGhash(Nil,"SB")
        
        For nI:=1 to len(aArrConsul)
            AADD(aArrayRg ,aArrConsul[nI][7])                    
        Next  
    ElseIF cTrifil == "7" //Dados Participante da Nota
        
        aArrConsul := LoadMSGhash(Nil,"PR")
        
        For nI:=1 to len(aArrConsul)
            AADD(aArrayRg ,aArrConsul[nI][7])                    
        Next
    ElseIF cTrifil == "8"  // 8=Cadastro de Natureza
        
        aArrConsul := LoadMSGhash(Nil,"NT")
        
        For nI:=1 to len(aArrConsul)
            AADD(aArrayRg ,aArrConsul[nI][7])                    
        Next
    Endif
    
    //Atualiza View
    oView:SetFieldProperty("VIEW_REGRA","CJ8_CONSUL","COMBOVALUES",{aArrayRg})
    oview:Refresh()

Else
    //lista inicial do combo 
    aArrConsul := LoadMSGhash(Nil, "Todos")  //Retorna Lista Completa

    For nI:=1 to len(aArrConsul)
        AADD(aArrayRg ,aArrConsul[nI][7])                    
    Next
    
    cRet := ArrTokStr(aArrayRg,';') 
    
    ASize(aArrayRg,0)

    Return cRet
Endif


Return aArrayRg

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

@author Rafael Oliveira 
@since 20/05/2021
@version 12.1.33
/*/
//------------------------------------------------------------------
Static Function xForCheck(cModelo, cRetErro, lShowMsg, cTpRegra, cCodCab, cCodModCab, lEmpty, cExcecao)
Local oModel        := FWModelActive()
Local oFormul	    := oModel:GetModel(cModelo)
Local cMensagem     := oFormul:GetValue("CJ8_MENSG",1)
Local lRet          := .F.
Local aPalavras     := {}


If lBuild .And. !EmpTy(AllTrim(cMensagem))    
    
    IF oHMCad==Nil
        oHMCad:= NewHash(oHMCad)

        //Alimenta o hash
        LoadMSGhash(@oHMCad)         
    Endif

    //Quebra mensagem
    aPalavras := StrTokArr(alltrim(cMensagem),CHR(32)+CHR(13)+CHR(10)) //Espaço + SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)

    //Ordena Array pelo Prefixo+Sufixo
    aSort(aPalavras)
    
    //Processa texto
    Processar(oHMCad, aPalavras , cMensagem)

    //Limpa array aPalavras
    aSize(aPalavras,0)
Endif

Return lRet


Static Function Processar(oHMCad, aPalavras , cMensagem) 

Local aButtons  := {}
Local aRetHash  := {}
Local aTxtAlert := {}
Local cPrefixo  := ""
Local cSufixo   := ""
Local nFim      := 0
Local nInicio   := 0
Local nMeio     := 0
Local nMSG      := 0
Local nPosGen   := 0
Local nX        := 0
Local nTamF2B   := TamSx3("F2B_REGRA")[1]
Local lOk       := .F.


DbSelectArea("F2B")
F2B->(DbSetOrder(7))

//Processa Palavras
For nX := 1 to Len(aPalavras)
    
    // Evita processar mesmo texto
    IF nX > 1 .and. aPalavras[nX-1] == aPalavras[nX] 
        Loop
    Endif            
    
    aRetHash := {}        
    nPosGen  := 0 
    lOk := .F.           

    IF !EmpTy(aPalavras[nX]) .And. (nMeio := AT(":", aPalavras[nX], 1)) > 0 .and. (nInicio := AT("[", aPalavras[nX], 1)) > 0 .and. (nFim := AT("]", aPalavras[nX], 1)) > 0
        
        cPrefixo := SubStr(aPalavras[nX], nInicio,nMeio-nInicio )
        cSufixo  := SubStr(aPalavras[nX], nMeio, nFim-(nMeio-1))
        
        IF !EmpTy(cPrefixo) .And. !EmpTy(cSufixo) //Valida se Existe Sufixo e Prefixo

            //Procura no Legado
            IF cPrefixo <> "[TG" .And. Len(aRetHash := FindHash(oHMCad,cPrefixo+cSufixo)) > 0 // Localiza No hash se existe Prefixo+Sufixo
                
                lOk := .T.

            ElseIf F2B->(MsSeek( xFilial("F2B") + PadR(SubStr(cPrefixo, 2, len(cPrefixo)-1),nTamF2B) + "2")) //Verifica se Existe Tributo

                IF Len(aRetHash := FindHash(oHMCad,'[TG'+cSufixo)) > 0                    
                    
                    lOk := .T.
                    
                Endif
            Endif

            IF !lOk
                IF nPos  := (ASCAN(aTxtAlert, cPrefixo+cSufixo)) == 0
                    aadd(aTxtAlert,cPrefixo+cSufixo)
                Endif
            Endif
        Endif            
    Endif                
Next nX


//Monta mensagem de informação 
nMSG := Len(aTxtAlert)
IF nMSG > 0

    AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )	
    
    FORMBATCH( STR0009, aTxtAlert, aButtons  , /*[ <bValid>  ]  , [ <nAltura>  ] , [  <nLargura>  ] */)

Else
    MsgInfo(STR0008,"Validação")

Endif


//Limpa Array
ASize(aTxtAlert,0)
ASize(aRetHash,0)

Return 

/*/{Protheus.doc} NewHash
	(Função Cria objetos do hash)

	@type Static Function
	@author Bruce Egnor, Rafael Oliveira
	@since 05/04/2021

	
	/*/
Static Function NewHash(oHMCad)
    
    oHMCad  := HMNew()

Return(oHMCad)


//------------------------------------------------------------------
/*/{Protheus.doc} HabBtnEdit
Esta função indica se opção adicionar estara habilitado ou não.

@param cModelo - Modelo que deverá refletir as alterações ao habilitar a fórmula

@author Rafael Oliveira
@since 21/05/2021
@version 12.1.33
/*/
//------------------------------------------------------------------
Static Function HabBtnEdit(cModelo)
Local oModel      := FWModelActive()
Local cConsul     := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_CONSUL"))
Local lRet := .T.

If EmpTy(cConsul)
     lRet := .F.
EndIF

Return lRet


//------------------------------------------------------------------
/*/{Protheus.doc} HabBtnvalid
Esta função indica se opção de validar estara habilitado ou não.

@param cModelo - Modelo que deverá refletir as alterações ao habilitar a fórmula

@author Rafael Oliveira
@since 21/05/2021
@version 12.1.33
/*/
//------------------------------------------------------------------
Static Function HabBtnvalid(cModelo)
Local oModel  := FWModelActive()
Local cFormul := AllTrim(oModel:GetValue( 'FISA178' ,"CJ8_MENSG"))
Local lRet := .T.

If EmpTy(cFormul)
     lRet := .F.
EndIF

Return lRet
