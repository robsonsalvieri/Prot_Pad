#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA162.ch"
#Include "FWEditPanel.CH"

STATIC cOperRedAliq  := "PERC_REDUCAO_ALIQ"
STATIC lCmpRedAliq   :=  F28->(FieldPos("F28_REDALI")) > 0

PUBLISH MODEL REST NAME FISA162

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA162()

Cadastro de Regra da aliquota
Esta rotina fará cadastro de Regra da Aliquota

Esta rotina estará disponível somente na versão 12.

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA162()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F28") 
    dbSelectArea("F28")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F28")
    oBrowse:SetFilterDefault("F28_ALTERA == '2'")
    oBrowse:SetDescription(STR0001) // Cadastro de Regra de Aliquota
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0018 ACTION 'VIEWDEF.FISA162' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0019 ACTION 'VIEWDEF.FISA162' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0020 ACTION 'VIEWDEF.FISA162' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0021 ACTION 'VIEWDEF.FISA162' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0022 ACTION 'VIEWDEF.FISA162' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0023 ACTION 'FSA162Hist'      OPERATION 4 ACCESS 0 //'Histórico de Alterações'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil
Local lCIN := AliasIndic("CIN") .And. FindFunction("xFisFormul")

//Estrutura Pai correspondete a tabela de perfil F28
Local oCabecalho := FWFormStruct(1, "F28" )
Local oFORMULALQ := Iif(lCIN,FWFormStruct(1,"CIN"),nil)

Local lOriTrb := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0 

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA162',/*Pre-Validacao*/,{|oModel|ValidModel(oModel) },{|oModel|FSA162Grava(oModel)})

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA162",,oCabecalho)

//Verifico se tabela CIN existe
If lCIN
    //Atribuindo estruturas para o modelo
    oModel:AddFields("FORMULALQ","FISA162",oFORMULALQ)
EndIF

//Inicializa a variavel
oCabecalho:SetProperty('F28_UFRPER' , MODEL_FIELD_INIT ,{|| 100 } )


//Não permite alterar o conteúdo do campo F20_CODIGO na edição
oCabecalho:SetProperty('F28_CODIGO' , MODEL_FIELD_WHEN, {||  (oModel:GetOperation()==3 ) })
oCabecalho:SetProperty('F28_TPALIQ' , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")$"04#06#07") })
oCabecalho:SetProperty('F28_ALIQ'   , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="04") })
oCabecalho:SetProperty('F28_URF'    , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="05") })
oCabecalho:SetProperty('F28_DSURF'  , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="05") })
oCabecalho:SetProperty('F28_UFRPER' , MODEL_FIELD_WHEN, {||  (oModel:GetValue ('FISA162',"F28_VALORI")=="05") })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oCabecalho:SetProperty('F28_CODIGO' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

If lCIN
    
    //O campo de fórmula ficará habilitado, somente após o valor de origem for igual a 06
    //A função Fsa162HFor() indica se deve ou não estar habilitado
    oFORMULALQ:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {|| Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") <> "ZZ" .And. FSA160HCon(oModel, "FORMULALQ", "CIN_TRIB") })
    oFORMULALQ:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {|| .T. })

    oFORMULALQ:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa162HFor() })
    oFORMULALQ:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") == "ZZ" })
    oFORMULALQ:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") $ "05/Z1" } )

    If lOriTrb
        oFORMULALQ:SetProperty('CIN_ORITRB'   , MODEL_FIELD_WHEN, {||  Fsa162HFor() .And. oModel:GetValue('FORMULALQ',"CIN_FILTRO") $ "05/Z1" } )
        oFORMULALQ:SetProperty('CIN_FILTRO' , MODEL_FIELD_VALID ,{||  xForGVld(oModel,"CIN_FILTRO","FORMULALQ")} )
    EndIf

    //Adicionei no valid dos campos abaixo a chamada da função Fsa161HBtn(), para atualizar a fórmula
    oCabecalho:SetProperty('F28_VALORI' , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_TPALIQ' , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_ALIQ'   , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_URF'    , MODEL_FIELD_VALID, {|| Fsa162Form() })
    oCabecalho:SetProperty('F28_UFRPER' , MODEL_FIELD_VALID, {|| Fsa162Form() })

    If lCmpRedAliq
        oCabecalho:SetProperty('F28_REDALI' , MODEL_FIELD_VALID, {|| Fsa162Form() .and. (oModel:GetValue('FISA162',"F28_REDALI") >= 0 .and. oModel:GetValue('FISA162',"F28_REDALI") <= 100)})
    Endif

    //Cria relacionamento entre a tabela F28 e CIN.
    oModel:SetRelation( 'FORMULALQ', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F28_ID'}, {'CIN_TREGRA', "'2 '"}}, CIN->( IndexKey(3)))

EndIF

oModel:SetPrimaryKey( {"F28_FILIAL","F28_CODIGO","F28_ALTERA","F28_ID"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) // Cadastro de Perfil Tributário de Produto

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA162" )
Local lCIN      := AliasIndic("CIN") .And. FindFunction("xFisFormul")
Local lOriTrb := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0 
Local cCmpCIN := Iif(lOriTrb,"CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB/CIN_ORITRB","CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB")

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho:= FWFormStruct(2, "F28")
Local oFormula  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) //Somente adiciona na view da fórmula o campo CIN_FORMUL
Local oRegra    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ cCmpCIN}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL

Local oView := Nil
Local cGrupoRef := "GRUPO03" // "Unidade de Referência Fiscal"

oCabecalho:AddGroup( 'GRUPO01', OemToAnsi(STR0003), '', 2 ) // "Definição da Alíquota"
oCabecalho:AddGroup( 'GRUPO02', OemToAnsi(STR0004), '', 2 ) // "Aliquota Informada Manualmente"

If lCmpRedAliq
    oCabecalho:AddGroup( 'GRUPO03', OemToAnsi(STR0030), '', 2 ) // "Redução de Alíquota"
    cGrupoRef := "GRUPO04" // "Unidade de Referência Fiscal
EndIf

oCabecalho:AddGroup( cGrupoRef, OemToAnsi(STR0005), '', 2 ) // "Unidade de Referência Fiscal"


oCabecalho:SetProperty( 'F28_CODIGO'    ,   MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oCabecalho:SetProperty( 'F28_DESC'      ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oCabecalho:SetProperty( 'F28_VALORI'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oCabecalho:SetProperty( 'F28_TPALIQ'    ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oCabecalho:SetProperty( 'F28_ALIQ'      ,	MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oCabecalho:SetProperty( 'F28_URF'       ,	MVC_VIEW_GROUP_NUMBER, cGrupoRef )
oCabecalho:SetProperty( 'F28_DSURF'     ,	MVC_VIEW_GROUP_NUMBER, cGrupoRef )
oCabecalho:SetProperty( 'F28_UFRPER'    ,	MVC_VIEW_GROUP_NUMBER, cGrupoRef )

If lCmpRedAliq
    oCabecalho:SetProperty( 'F28_REDALI',	MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )    
    oCabecalho:SetProperty("F28_REDALI", MVC_VIEW_TITULO, "% Redução de Alíquota")    
Endif

//Picture do campo código
oCabecalho:SetProperty('F28_CODIGO' , MVC_VIEW_PICT, "@!")

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho  , 'FISA162' )

//Se a tabela CIN existir então dividirei a tela em duas partes, uma para dados cadastrais da regr e outra com detalhamento da fórmula
If lCIN
    oFormula:SetProperty("CIN_FORMUL"  , MVC_VIEW_CANCHANGE, .F.)

    //Remove o campo da View
    oCabecalho:RemoveField("F28_ID")

    //Cria as views do operando e da fórmula
    oView:AddField( 'VIEW_FORMULA' , oFormula, 'FORMULALQ')

    //Cria as view do campo regra
    oView:AddField( 'VIEW_REGRA' , oRegra, 'FORMULALQ')

    //Ajuste dos títulos dos campos de filtros de fórmula
    oRegra:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegra:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegra:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegra:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    If lOriTrb
        oRegra:SetProperty("CIN_ORITRB", MVC_VIEW_TITULO, "Referencia do Tributo")
    EndIf

    //Ordem dos campos da CIN para realizarem filtros nas fórmulas
    oRegra:SetProperty("CIN_FILTRO" , MVC_VIEW_ORDEM, "01")
    oRegra:SetProperty("CIN_TRIB"   , MVC_VIEW_ORDEM, "02")
    oRegra:SetProperty("CIN_CONSUL" , MVC_VIEW_ORDEM, "03")
    oRegra:SetProperty("CIN_VAL"    , MVC_VIEW_ORDEM, "04")    

    If lOriTrb
        oRegra:SetProperty("CIN_ORITRB" , MVC_VIEW_ORDEM, "05")    
    EndIf

     //Divide a tela em duas pastas
     oView:CreateFolder( 'PASTAS' )
     oView:AddSheet( 'PASTAS', 'ABA01', "Definição da Alíquota"       )
     oView:AddSheet( 'PASTAS', 'ABA02', "Detalhamento da Fórmula de Cálculo" )
    
    //Aba da esquerda cheia
     oView:CreateHorizontalBox( 'ESQUERDA', 100,,, 'PASTAS', 'ABA01' ) //Aqui ficarão todos os componentes de tela que já estavam na onda 1
    
    //Aba da direita dividida em duas partes horizontais
    oView:CreateHorizontalBox( 'TITULO'              , 30,,.T., 'PASTAS', 'ABA02') //Aqui crio um objeto vazio somente para colocar o título
    oView:CreateHorizontalBox( 'BOX_SUPERIOR'        , 200,,.T., 'PASTAS', 'ABA02') 
    oView:CreateVerticalBox( 'BOX_SUPERIOR_ESQUERDO' , 600,'BOX_SUPERIOR',.T., 'PASTAS', 'ABA02') //Aqui ficarão os campos para seleção das regras a serem adicionadas na fórmula
    oView:CreateHorizontalBox( 'BOX_INTERMEDIARIO'   , 80,,.T., 'PASTAS', 'ABA02') //Aqui ficarão os botões de adicionar, limpar dos operadores etc
    oView:CreateHorizontalBox( 'BOX_INFERIOR'        , 230,,.T., 'PASTAS', 'ABA02') //Aqui ficará o campo memo de fórmula
     
    //Painel com os botões
    //Adiciono componente da fórmula, que está definido por meio da função xFisFormul().
    oView:AddOtherObject("BOTOES", {|oPanel| xFisFormul(oPanel, "FORMULALQ","VIEW_FORMULA","2", "F28_CODIGO", "FISA162", "CIN_CONSUL", "VIEW_REGRA")})

    //Painel vazio para ter o título da tela
    oView:AddOtherObject("LABEL", {|oPanel| xFisLabel(oPanel)}) 
       
    //Aba da esquerda
    oView:SetOwnerView( 'VIEW_CABECALHO', 'ESQUERDA')   
    
    //Título
    oView:SetOwnerView( 'LABEL'        , 'TITULO')       

    //Campos de filtros
    oView:SetOwnerView( 'VIEW_REGRA'    , 'BOX_SUPERIOR_ESQUERDO')              
    
    //Botões para manipular fórmula
    oView:SetOwnerView( 'BOTOES'        , 'BOX_INTERMEDIARIO')       
    
    //Fórmula
    oView:SetOwnerView( 'VIEW_FORMULA'  , 'BOX_INFERIOR')
    
    //Seto o layout para que o campo memo fique um pouco maior, preenchendo mais tela    
    oView:SetViewProperty( "VIEW_FORMULA", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4 } )

    //Atribuo um título para a segunda aba.
    oView:EnableTitleView('LABEL'  , "Composição da Fórmula")

    oView:SetFieldAction("CIN_TRIB", { |oView, cIDView| FSA162SFoc(oView, cIDView,"CIN_FILTRO")})

EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Função que valida se o código de perfil cadastrado já existe

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodAliq 	:= oModel:GetValue ('FISA162',"F28_CODIGO")
Local lRet      := .T.

//Verifico se o perfil já existe.
//Procura se já existe regra de alíquota com o mesmo código e ativa
If F28->( MsSeek ( xFilial('F28') + cCodAliq + '2' ) )
    Help( ,, 'Help',, "Código já cadastrado!", 1, 0 ) 
    return .F.
EndIF

//Não pode digitar operadores e () no código
If "*" $ cCodAliq .Or. ;
   "/" $ cCodAliq .Or. ;
   "-" $ cCodAliq .Or. ;
   "+" $ cCodAliq .Or. ;
   "(" $ cCodAliq .Or. ;
   ")" $ cCodAliq
    Help( ,, 'Help',, "Código da regra não pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodAliq)
    Help( ,, 'Help',, "Código não pode conter espaço.", 1, 0 ) 
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} C162CBOX
Função que valida se o código de perfil cadastrado já existe

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Function C162CBOX(lCarga)

Local nI	:= 0
Local cRet	:= ""
Local aOpc	:= {} 

Default lCarga := .F.

/*
Ao adicionar novas opções é nescessario informar a segunda coluna com descrição da formula e terceira valor da formula
Desta forma ao processar FISA170 sera dado carga da tabela CIN
Quando não informar segunda ou terceira coluna não sera dado carga na CIN
*/

//        F28 Combo     |       CIN Descrição               |  CIN Formula
AADD(aOpc,{STR0011      ,"Alíquota do ICMS"                 ,"ALQ_ICMS"})       //"01=Alíquota do ICMS"
AADD(aOpc,{STR0012      ,"Alíquota do Crédito Presumido"    ,"ALQ_CREDPRESU"})  //"02=Alíquota do Crédito Presumido"
AADD(aOpc,{STR0013      ,"Alíquota do ICMS-ST"              ,"ALQ_ICMSST"})     //"03=Alíquota do ICMS-ST"
AADD(aOpc,{STR0014      ,""                                 ,""})               //"04=Alíquota Informada Manualmente"
AADD(aOpc,{STR0015      ,""                                 ,""})               //"05=Unidade de Referencia Fiscal (URF)"
AADD(aOpc,{STR0017      ,""                                 ,""})               //"06=Fórmula Manual"

//Esta opção do combo não será adicionada como origem, e sim como indexde cálculo
IF !lCarga
    AADD(aOpc,{"07=Tabela Progressiva"      ,""                                 ,""})               //"07 =Tabela Progressiva"
    AADD(aOpc,{"08=Alíquota do NCM"      ,"Alíquota do NCM"                  ,"ALIQ_NCM"})       //"08=Alíquota do NCM"
    AADD(aOpc,{"09=Pauta do NCM"      ,"Pauta do NCM"                      ,"PAUTA"})     //"09=Pauta do NCM"
EndIF


If lCarga
    Return aOpc
Endif

For nI:=1 To Len(aOpc)
	cRet += IIf(empty(cRet),'',';') + aOpc[nI][1]
Next

Return (cRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Função responsável por realizar as validações do model 
Será acionada ao salvar o modelo.

@author Erich M. Buttner
@since 21/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cValOri 		:= oModel:GetValue ('FISA162',"F28_VALORI")
Local nURFPerc 		:= oModel:GetValue ('FISA162',"F28_UFRPER")
Local cURF   		:= oModel:GetValue ('FISA162',"F28_URF")
Local cTpAliq       := oModel:GetValue ('FISA162',"F28_TPALIQ")
Local nAliq         := oModel:GetValue ('FISA162',"F28_ALIQ")
Local lRet          := .T.
Local lCIN          := AliasIndic("CIN") .And. FindFunction("xFisFormul")
Local cErrForml     := ""
Local nRedAliq      := 0

If lCmpRedAliq
    nRedAliq      := oModel:GetValue ('FISA162',"F28_REDALI")
Endif

//VAlidações para operações de inclusão e alteração.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If cValOri == "05" .And. nURFPerc == 0
        lRet:= .F.
        Help( ,, 'Help',, STR0006, 1, 0 ) // "Por Favor, Preencher o percentual da URF"
    EndIF

    If lRet .And. Empty(AllTrim(cURF)) .And. cValOri == "05"
        lRet:= .F.
        Help( ,, 'Help',, STR0007, 1, 0 ) //"Por Favor, Informe o Codigo da URF"   
    EndIf

    If lRet .And. Empty(AllTrim(cTpAliq)) .And. cValOri $ "04#06#07"
        lRet:= .F.
        Help( ,, 'Help',, STR0008, 1, 0 ) //"Por Favor, Informe o Tipo da Aliquota"
    EndIf

    If lRet .And. nAliq == 0 .And. cValOri == "04"
        IF !(lCIN .and. AllTrim(cTpAliq) == '1') //Quando utilizado aliquota 0 com percentual permite cadastro
            lRet:= .F.
            Help( ,, 'Help',, STR0009, 1, 0 ) //"Por Favor, Informe o Valor da Aliquota"   
        Endif
    EndIf

    If lRet .And. nAliq < 0 .And. cValOri == "04"         
        lRet:= .F.
        Help( ,, 'Help',, STR0010, 1, 0 ) //"Por Favor, Informe o Valor da Aliquota Positivo"          
    EndIf
    
    //Validação de reducao alíquota utilizando fórmula manual     
    If lCmpRedAliq

        If nRedAliq > 0 .and. cValOri $ "06|08|09" .and. !cOperRedAliq $ oModel:GetValue('FORMULALQ',"CIN_FORMUL")
            //Neste caso não temos operando de redução na fórmula, porém temos o percentual preenchido no campo específico
            //Poderia alertar o usuário para limpar, mas acho melhor e seguro a própria rotina limpar este campo automaticamente

            //Zerando percentual de redução de alíquota
            oModel:LoadValue('FISA162',"F28_REDALI",0)

        Elseif nRedAliq == 0 .and. cValOri $ "06|08|09" .and. cOperRedAliq $ oModel:GetValue('FORMULALQ',"CIN_FORMUL")
            //Neste caso temos operando de redução na fórmula, porém não temos o percentual preenchido no campo específico
            lRet:= .F.
            Help( ,, 'Help',, "Por favor, informe percentual de redução da alíquota", 1, 0 ) 
        Endif

    Endif

    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .AND. !xForCheck("FORMULALQ", @cErrForml, .F., "2", "F28_CODIGO", "FISA162")
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula: -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

EndIF

//Validação da exclusão, para que não permita excluir caso este ID já tenha sido utilizado na gravação da F2D.
IF nOperation == MODEL_OPERATION_DELETE

    dbSelectArea("F2D")
    dbSetOrder(4)
    If F2D->(MsSeek(xFilial('F2D') + F28->F28_ID))
        lRet    := .F.
        Help( ,, 'Help',, STR0016, 1, 0 ) //"Esta regra já foi utilizada na gravação dos tributos genéricos e não poderá ser excluída!"
    EndIF

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162Grava
Função responsável por realizar a gravação da regra de alíquota.
Aqui faremos o tratamento do histórico de alterações

@author Erick Dias
@since 13/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA162Grava(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cCodigo 		:= oModel:GetValue ('FISA162',"F28_CODIGO")
Local cDescri 		:= oModel:GetValue ('FISA162',"F28_DESC")
Local cValOri 		:= oModel:GetValue ('FISA162',"F28_VALORI")
Local cTpAliq 		:= oModel:GetValue ('FISA162',"F28_TPALIQ")
Local nAliq 		:= oModel:GetValue ('FISA162',"F28_ALIQ")
Local cUrf  		:= oModel:GetValue ('FISA162',"F28_URF")
Local nPerURF  		:= oModel:GetValue ('FISA162',"F28_UFRPER")
Local cFormula     	:= ""
Local cIdRegra      := ""
Local lCIN          := AliasIndic("CIN") .And. FindFunction("xFisFormul")
Local lChvMD5       := F28->(FieldPos('F28_CHVMD5') > 0)
Local cChvMD5       := ""
Local nRedAliq      := 0

If lCmpRedAliq
    nRedAliq      := oModel:GetValue ('FISA162',"F28_REDALI")
    If cValOri == "08" // Alíquota do NCM
        //Neste caso o tipo de alíquota é 1 - Alíquota
        cTpAliq := "1"
    ElseIf cValOri == "09" // Pauta do NCM
        //Neste caso o tipo de alíquota é 2 - Pauta
        cTpAliq := "2"
    EndIf
Endif

If nOperation == MODEL_OPERATION_INSERT 

    If ( lCIN .And. lChvMD5 )
        cChvMD5 := GetChvMd5()
    EndIf

    //Chama função para gravar nova informação na tabela F28
    cIdRegra:= GravaF28(1, cCodigo, cDescri, cValOri, cTpAliq, nAliq, cUrf, nPerURF, cChvMD5, nRedAliq)

    //Grava as informações da fórmula na tabela CIN
    If lCIN        
        cFormula    := oModel:GetValue ('FORMULALQ',"CIN_FORMUL")
        GravaCIN("1","2", cCodigo, cIdRegra, cDescri, cFormula)
    EndIF
ElseIF  nOperation == MODEL_OPERATION_UPDATE
    //Chama função para alterar registro atual
    cIdRegra:= GravaF28(2)

    //Grava as informações da fórmula na tabela CIN
    If lCIN
        //Chama função para editar a regra CIN
        GravaCIN("2",,, cIdRegra)

        If ( lChvMD5 )
            cChvMD5 := GetChvMd5()
        EndIf
    EndIF

    //Agora chamo função para inserir novo registro
    cIdRegra := GravaF28(1, cCodigo, cDescri, cValOri, cTpAliq, nAliq, cUrf, nPerURF, cChvMD5, nRedAliq)

    //Grava as informações da fórmula na tabela CIN
    If lCIN
        //Chama função para editar a regra CIN
        GravaCIN("2",,, cIdRegra)
        
        //Chama função para gravar nova linha na CIN
        cFormula    := oModel:GetValue ('FORMULALQ',"CIN_FORMUL")
        GravaCIN("1","2", cCodigo, cIdRegra	, cDescri, cFormula)
    EndIF
    
ElseIf nOperation == MODEL_OPERATION_DELETE

     If lCIN
        //Chama função para excluir a regra CIN antes de excluir a F28
        GravaCIN("3",,, F28->F28_ID)
    EndIF
 
    //Faz exclusão do registro
    RecLock("F28",.F.)
	F28->(dbDelete())
	MsUnLock()
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaF28
Função que faz gravação e edição da tabela F28

@author Erick Dias
@since 13/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function GravaF28(nOp, cCodigo, cDescri, cValOri, cTpAliq, nAliq, cUrf, nPerURF, cChvMD5, nRedAliq)
Local cID := ""
If nOp == 1 //Incluiu

    RecLock("F28",.T.)
    F28->F28_FILIAL	    := xFilial("F28")
    F28->F28_ID		    := FWUUID("F28")  
    F28->F28_CODIGO		:= cCodigo
    F28->F28_DESC  		:= cDescri
    F28->F28_VALORI		:= cValOri
    F28->F28_TPALIQ		:= cTpAliq
    F28->F28_ALIQ  		:= nAliq
    F28->F28_URF   		:= cUrf
    F28->F28_UFRPER		:= nPerURF    
    F28->F28_ALTERA		:= "2" //Indica que não foi alterado

    If lCmpRedAliq
        F28->F28_REDALI  := nRedAliq
    EndIf

    If ( !Empty(cChvMD5) )
        F28->F28_CHVMD5 := cChvMD5
    EndIf

    F28->(MsUnLock())

ElseIf nOp ==2 //Alteração    
    RecLock("F28",.F.)
    F28->F28_ALTERA 		:= "1"//Indica que sofreu alterações
    F28->F28_DTALT  		:= Date()
    F28->F28_HRALT  		:= Time()
    F28->(MsUnLock())

EndIf

Return cId := F28->F28_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162HFor
Função que indica se o campo de fórmula deverá ou não estar habilitado,
e ter o seu conteúdo alterado.

@return - bool - Retorna verdadeiro se a opção de fórmula manual estiver selecionada

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162HFor()
return !lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} RetOperOri
Função que retorna o operando para a opção selecionada de origem de
base de cálculo.

@param -  cValOri - Opção selecionada no combo
@return - cOpcaoOri - Operando correspondente a origem selecionada

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function RetOperOri(cValOri)

Local cOpcaoOri := ""

IF cValOri == "01"
    cOpcaoOri := "ALQ_ICMS"
ElseIF cValOri == "02"
    cOpcaoOri := "ALQ_CREDPRESU"
ElseIF cValOri == "03"
    cOpcaoOri := "ALQ_ICMSST"
ElseIF cValOri == "04"
    cOpcaoOri := "ALQ_MANUAL"
ElseIF cValOri == "05"
    cOpcaoOri := "UN_REFFISCAL"
ElseIF cValOri == "07"
    cOpcaoOri := "ALIQ_TAB_PROGRESSIVA"
ElseIF cValOri == "08"
    cOpcaoOri := "ALIQ_NCM"
ElseIF cValOri == "09"
    cOpcaoOri := "PAUTA"
EndIF

Return cOpcaoOri

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162Form
Função que atualiza a fórmula da regra de base de cálculo.
Ao alterar algum operando do modo básico da regra, a fórmula 
será atualizada.

@return - .T.

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162Form(cFormula)

Local oModel        := FWModelActive()
Local cValOri 		:= oModel:GetValue ('FISA162',"F28_VALORI")
Local cOpcaoOri     := ""
Local cTpAliq       := ""
Local cCodURF       := ""
Local cVlAlqM       := ""
Local cPerURF       := 0
Local nPerURF       := 0
Local nVlAlqM       := 0
Local cPrefixo      := ""
Local nRedAliq      := 0
Local cRed          := ""

If lCmpRedAliq
    nRedAliq      := oModel:GetValue ('FISA162',"F28_REDALI")
Endif

Default cFormula    := ""

//Inicia a fórmula com operando de origem
cOpcaoOri   :=  RetOperOri(cValOri)

IF  cValOri == "06"

    //Primeiro limpa a fórmula
    xForClear("FORMULALQ", .F., "VIEW_FORMULA", .F.)

    //Abrir parentes 
    xForBtnAct(cFormula, "FORMULALQ", .F., "VIEW_FORMULA")

    //Indica que o botão de edição de fórmula ficará habilitado
    lclicked := .T.

    Return .T.

Endif

//Primeiro limpa a fórmula
xForClear("FORMULALQ", .F., "VIEW_FORMULA")

//Se operador estiver fazio então a fórmula não será montada!
If !Empty(cOpcaoOri)

    // Verifica se tem redução de alíquota
    If nRedAliq > 0

        //Obtenho o operando da redução de base de Aliquota
        cRed    := xFisTpForm('9') + cOperRedAliq

        // Abre parênteses para a redução de Aliquota
        xForBtnAct("(", "FORMULALQ", .F., "VIEW_FORMULA")
    Endif

    //Verifica se a alíquota é informada manualmente
    If cOpcaoOri == "ALQ_MANUAL"
        //Carrego as informações do campo de alíquota informado manualmente
        nVlAlqM := oModel:GetValue ('FISA162',"F28_ALIQ")
        //Carrego as informações do campo de tipo de alíquota
        cTpAliq := oModel:GetValue ('FISA162',"F28_TPALIQ")

        IF cTpAliq == '1' .and. nVlAlqM == 0
            cPrefixo:= xFisTpForm("0") //Operador primário
            //Adiciona o operador de origem/início na fórmula
            xForBtnAct(cPrefixo+"ZERO", "FORMULALQ", .F., "VIEW_FORMULA")
        Else
            If !Empty(cTpAliq)

                //Converto o número em caracter antes de ser adicionado na fórmula
                cVlAlqM := Alltrim(StrTran( Str(nVlAlqM ), ".", "," ))

                //Adiciona o percentual
                xForBtnAct(cVlAlqM, "FORMULALQ", .F., "VIEW_FORMULA")
            EndIf
        Endif
    //Alíquota por UFR
    ElseIf cOpcaoOri == "UN_REFFISCAL"

        //Carrego as informações do campo código URF
        cCodURF:= oModel:GetValue ('FISA162',"F28_URF")
        //Carrego as informações do campo de Percentual da URF
        nPerURF:= oModel:GetValue ('FISA162',"F28_UFRPER")

        If !Empty(cCodURF)

            nPerURF:= nPerURF/100
            //Converto o número em caracter antes de ser adicionado na fórmula
            cPerURF := Alltrim(StrTran( Str(nPerURF ), ".", "," ))

            //Adiciona o percentual
            cPrefixo:= xFisTpForm("4") //URF
            xForBtnAct(cPrefixo+cCodURF, "FORMULALQ", .F., "VIEW_FORMULA")

            //Adiciona o operador de multiplicação
            xForBtnAct("*", "FORMULALQ", .F., "VIEW_FORMULA")

            //Adiciona o operador de multiplicação
            xForBtnAct(cPerURF, "FORMULALQ", .F., "VIEW_FORMULA")

        EndIf

    ElseIF cOpcaoOri == "ALIQ_TAB_PROGRESSIVA" .or. cOpcaoOri == "ALIQ_NCM" .or. cOpcaoOri == "PAUTA"
            xForBtnAct(xFisTpForm("9") + cOpcaoOri, "FORMULALQ", .F., "VIEW_FORMULA")

    Else
        cPrefixo:= xFisTpForm("0") //Operador primário
        //Adiciona o operador de origem/início na fórmula
        xForBtnAct(cPrefixo+cOpcaoOri, "FORMULALQ", .F., "VIEW_FORMULA")
    EndIf

    //Se tiver redução de alíquota, adiciona o operador de redução
    If nRedAliq > 0
        //Adiciona o operador de multiplicação
        xForBtnAct("*", "FORMULALQ", .F., "VIEW_FORMULA")

        //Adiciona o operador de redução de alíquota
        xForBtnAct(cRed, "FORMULALQ", .F., "VIEW_FORMULA")

        //Fecha parênteses da redução de alíquota
        xForBtnAct(")", "FORMULALQ", .F., "VIEW_FORMULA")
    EndIf

    lclicked := .T.

EndiF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162AFor
Função executada quando usuário acionou edição manual na fórmula, 
função chamada no action do botão habilitar fórmulas.
Para isso preciso indicar no valor de origem a opção 06, que 
significa fórmula manual.
Além disso preciso também restaurar os demais campos para as opções
iniciais, e deixar estes campos desabilitados, já que a fórmula será 
construída manualmente, e não mais por meio dos combos, até mesmo
porq não seria possível representar todas as fórmulas nos combos, 
já que a fórmula é muito mais flexivel.

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162AFor()
Local oModel    := FWModelActive()
Local oFormul   := oModel:GetModel("FISA162")
Local oView     := 	FWViewActive()

//Adiciona o operador no final da fórmula
oFormul:SetValue('F28_VALORI',  "06")

//Atualizo a view
oview:Refresh( 'VIEW_CABECALHO')
oview:Refresh( 'VIEW_FORMULA')
oview:Refresh( 'VIEW_REGRA')
oview:Refresh( 'BOTOES')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa162HBtn
Esta função indica se o botão que habilita a edição da fórmula deverá estar
ou não habilitado.

Por padrão em um novo cadastro o botão estará habilitado.

@return bool - Retorna verdadeiro quando a opção de origem não é fórmula manual(06)

@author Renato Rezende
@since 04/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa162HBtn()
Return lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162F28
Função executada quando usuário entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA162F28()
Local oModel    := nil
Local cCodigo   := ""
Local cDescri   := ""
Local cFormula  := ""
Local cIdRegra  := ""
Local cAlias    := ""
Local cAltera   := ""

//Realiza pesquisa pela relação da F28 com CIN
cAlias := PesqCIN("F28")

DbSelectArea(cAlias)

//Caso não encontre diferenças finaliza processo
If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA162
oModel    := FWLoadModel('FISA162')

DbSelectArea("F28")
F28->(DbSetOrder(4)) // F28_FILIAL+F28_ID

While (!(cAlias)->(Eof()))

    If F28->(MsSeek(xFilial("F28") + (cAlias)->F28_ID))

        oModel:Activate()

        cCodigo   := oModel:GetValue ('FISA162',"F28_CODIGO")   // Código Regra
        cDescri   := oModel:GetValue ('FISA162',"F28_DESC")    // Descrição   
        cIdRegra  := oModel:GetValue ('FISA162','F28_ID')
        cAltera   := Iif(F28->F28_ALTERA =='2',"0","1")

        //Função que atualiza a fórmula da regra de Aliquota.
        Fsa162Form()

        cFormula    := oModel:GetValue ('FORMULALQ',"CIN_FORMUL")
        GravaCIN("1","2", cCodigo, cIdRegra, cDescri, cFormula,cAltera)

        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F28->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA162Hist
Função que exibirá Browse com o histórico de alteações da rotina

@author Erick Dias
@since 24/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA162Hist()
Local cFiltro   := ""
Local aColunas  := {}

//Adicionando as colunas de Data e horario de alteração, pois o UPDDISTR não altera o X3_BROWSE, por isso estou adicionado a coluna manualmente.
/* Posições dos arrays
1 - Título
2 - Codeblock para carregra a ~informação
3 - Tipo
4 - Alinhamento (1 alinhado a esquera)
5 - Tamanho
6 - Decimal
7 - Indica se permite alteração
*/
AADD(aColunas,{ STR0027, &("{ || IIf(F28->F28_ALTERA == '1','" + STR0028 + "','" + STR0029 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - Nõo alterado"
AADD(aColunas,{ STR0025, &("{ || F28->F28_DTALT }"), "D", "", 1, 8, 0, .f.}) //"Data de Alteração"
AADD(aColunas,{ STR0026, &("{ || F28->F28_HRALT }"), "C", "", 1, 8, 0, .f.}) //"Horário de Alteração"

//Atribuo o Alias para variavel pública 
c170AlsHist := "F28"

//Monto o filtro abaixo somente com linhas que foram alteradas e não estão mais vigentes
cFiltro :="F28_FILIAL == '" + xFilial("F28") + "'"
cFiltro	+= " .AND. F28_CODIGO == '" + F28->F28_CODIGO +  "'"

//Utilizo segundo índice para facilitar a visualização
F28->(DbSetOrder(6))

//Chamo a função auxiliar que montará o Browse com as regras alteradas.
FSA16XHist("F28", cFiltro, STR0024, aColunas) //"Histórico de alterações da Regra de Alíquotas"

//Retorno o Alias e filtro padrão
c170AlsHist := ""
F28->(DbSetOrder(1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChvMd5
Função para atualização do campo MD5.

@author Juliano Fernandes
@since 12/04/2024
@version P12.1.2310
@return cChvMd5, character, Chave MD5
/*/
//-------------------------------------------------------------------
static function GetChvMd5()

    local oModel := FWModelActive()
    local cChave := ''
    local cPrefixo := 'CONFITRIB-' 
    local cChvMd5 := ''
    local lIsClassification := FWIsInCallStack('IntegraRegras')

    if ( lIsClassification )
        cPrefixo := 'CLASSTRIB-'
    endif

    cChave := oModel:GetValue('FISA162', 'F28_TPALIQ')
    cChave += xFisSYard(oModel:GetValue('FORMULALQ', 'CIN_FORMUL'))

    cChvMd5 := cPrefixo + Md5(cChave)

return cChvMd5


/*/{Protheus.doc} FSA162SFoc
    Coloca o focus no campo CIN_FILTRO.

    @type Static Function
    @author anedino.santos
    @since 12/05/2025
    @version 12.1.2410
    @param oView, object, objeto da view em uso
    @param cIDView, character, nome da subview
/*/
static function FSA162SFoc(oView, cIDView,cField)
    oView:getViewObj(cIDView)[3]:getFWEditCtrl(cField):oCtrl:SetFocus()
return
