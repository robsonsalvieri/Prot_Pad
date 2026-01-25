#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "FISA161.ch" 
#Include "FWEditPanel.CH"

STATIC cOperRedBas  := "PERC_REDUCAO_BASE"
STATIC lCIN         := AliasIndic("CIN") .And. FindFunction("xFisFormul")

PUBLISH MODEL REST NAME FISA161

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA161()

Esta rotina é o cadastro das regras de composição da base de cálculo
dos tributos genéricos. Esta tela definirá como a base de cálculo será 
composta.

Esta rotina estará disponível somente na versão 12.

@author Erick G. Dias
@since 20/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA161()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F27")
    dbSelectArea("F27")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F27")
    oBrowse:SetFilterDefault("F27_ALTERA == '2'")
    oBrowse:SetDescription(STR0001) // Cadastro da composição da base de cálculo
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 20/062018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.FISA161' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.FISA161' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.FISA161' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.FISA161' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0014 ACTION 'VIEWDEF.FISA161' OPERATION 9 ACCESS 0 //'Copiar'
ADD OPTION aRotina TITLE STR0015 ACTION 'FSA161Hist'      OPERATION 4 ACCESS 0 //'Histórico de Alterações'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do perfil de produto com as tabelas F20, F24 e F25

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil
Local lOriTrb := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0 

//Estrutura da tabela F27 com os campos da composição da base de cálculo
Local oRegraBase := FWFormStruct(1, "F27" )
Local oFORMULBAS     := Iif(lCIN,FWFormStruct(1,"CIN"),nil) 

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA161',/*Pre-Validacao*/,{|oModel|ValidModel(oModel) },{|oModel|FSA161Grava(oModel)})

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA161",,oRegraBase)

//Verifico se tabela CIN existe
If lCIN  
    
    //Atribuindo estruturas para o modelo
    oModel:AddFields("FORMULBAS","FISA161",oFORMULBAS)
EndIF

//Não permite alterar o conteúdo do campo F27 na edição
oRegraBase:SetProperty('F27_CODIGO' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

//Somente permitirá informar tipo de redução quando o percentual de redução for maior que zero
oRegraBase:SetProperty('F27_TPRED' , MODEL_FIELD_WHEN, {|| oModel:GetValue ('FISA161',"F27_REDBAS") > 0 .And. oModel:GetValue('FISA161',"F27_VALORI")<>"11"  })

//Somente permitirá informar unidade de medida quando o valor de origem da base de cálculo for igual 02-Quantidade
oRegraBase:SetProperty('F27_UM' , MODEL_FIELD_WHEN, {|| oModel:GetValue ('FISA161',"F27_VALORI") $ '02/11' })

//Validação para não permitir informar código de perfil + tipo de perfil duplicado
oRegraBase:SetProperty('F27_CODIGO' , MODEL_FIELD_VALID, {||( VldCod(oModel) )})

If lCIN
    
    //O campo de fórmula ficará habilitado, somente após o valor de origem for igual a 11
    //A função Fsa161HFor() indica se deve ou não estar habilitado  

    
    oFORMULBAS:SetProperty('CIN_FORMUL' , MODEL_FIELD_WHEN, {||  .T. })    
    oFORMULBAS:SetProperty('CIN_CONSUL' , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") <> "ZZ" .And. FSA160HCon(oModel, "FORMULBAS", "CIN_TRIB") })

    oFORMULBAS:SetProperty('CIN_FILTRO' , MODEL_FIELD_WHEN, {||  Fsa161HFor() })
    oFORMULBAS:SetProperty('CIN_VAL'    , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") == "ZZ" })
    oFORMULBAS:SetProperty('CIN_TRIB'   , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") $ "05/Z1" } )

    If lOriTrb
        oFORMULBAS:SetProperty('CIN_ORITRB' , MODEL_FIELD_WHEN, {||  Fsa161HFor() .And. oModel:GetValue('FORMULBAS',"CIN_FILTRO") $ "05/Z1" } )
        oFORMULBAS:SetProperty('CIN_FILTRO' , MODEL_FIELD_VALID ,{|| xForGVld(oModel,"CIN_FILTRO","FORMULBAS")} )
    Endif

   //Os campos abaixo ficarão desabilitados quando o valor de origem for 11, fórmula manual
   //a função Fsa161HBtn() indica se os campos abaixo deverão ou não ficar habilitados
    oRegraBase:SetProperty('F27_DESCON' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_FRETE' ,  MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_SEGURO' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_DESPE' ,  MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_ICMDES' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    oRegraBase:SetProperty('F27_ICMRET' , MODEL_FIELD_WHEN, {|| oModel:GetValue('FISA161',"F27_VALORI")<>"11" })
    
    //Adicionei no valid dos campos abaixo a chamada da função Fsa161HBtn(), para atualizar a fórmula 
    oRegraBase:SetProperty('F27_VALORI' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_DESCON' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_FRETE'  , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_SEGURO' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_DESPE'  , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_ICMDES' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_ICMRET' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    oRegraBase:SetProperty('F27_REDBAS' , MODEL_FIELD_VALID, {||(Fsa161Form() .And. MyPositivo())})
    oRegraBase:SetProperty('F27_TPRED' , MODEL_FIELD_VALID, {||(Fsa161Form())})
    
    //Cria relacionamento entre a tabela F27 e CIN.
    oModel:SetRelation( 'FORMULBAS', {{'CIN_FILIAL', 'xFilial("CIN")'},{'CIN_IREGRA', 'F27_ID'}, {'CIN_TREGRA', "'1 '"}}, CIN->( IndexKey(3)))

EndIF

oModel:SetPrimaryKey( {"F27_FILIAL","F27_CODIGO","F27_ALTERA","F27_ID"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) // Cadastro de Perfil Tributário de Produto

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel    := FWLoadModel( "FISA161" ) 
Local lOriTrb := Len(FWSX3Util():GetFieldStruct("CIN_ORITRB")) > 0 
Local cCmpCIN := Iif(lOriTrb,"CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB/CIN_ORITRB","CIN_CONSUL/CIN_FILTRO/CIN_VAL/CIN_TRIB") 

//Criação da estrutura de dados utilizada na interface do cadastro
Local oRegraBase:= FWFormStruct(2, "F27")
Local oFormula  := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ "CIN_FORMUL"}), nil ) //Somente adiciona na view da fórmula o campo CIN_FORMUL
Local oRegra    := Iif(lCIN,FWFormStruct(2, "CIN", {|x| AllTrim( x ) $ cCmpCIN}), nil ) //Somente adiciona na view da regra o campo CIN_CONSUL

Local oView := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oRegraBase  , 'FISA161'   )

//Cria os grupos
oRegraBase:AddGroup( 'GRUPO_CABECALHO', STR0003,'', 2 ) //'Base de Cálculo'
oRegraBase:AddGroup( 'GRUPO_ADICOES_DEDUCOES', STR0004, '' , 2 ) //'Adições e Deduções'
oRegraBase:AddGroup( 'GRUPO_REDUCAO' , STR0005 , '' , 2 ) //'Redução de Base de Cálculo'
oRegraBase:AddGroup( 'GRUPO_BASE_QUANTIDADE', STR0006 , '' , 2 ) //'Detalhamento - Base de Cálculo por Quantidade'

//Define os campos do grupo do cabeçalho
oRegraBase:SetProperty( 'F27_CODIGO'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABECALHO' )
oRegraBase:SetProperty( 'F27_DESC'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABECALHO' )
oRegraBase:SetProperty( 'F27_VALORI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CABECALHO' )

//Define os campos do grupo das adições e subtrações
oRegraBase:SetProperty( 'F27_DESCON' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_FRETE'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_SEGURO' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_DESPE'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_ICMDES' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )
oRegraBase:SetProperty( 'F27_ICMRET' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ADICOES_DEDUCOES' )

//Define os campos do grupo da redução de base de cálculo
oRegraBase:SetProperty( 'F27_REDBAS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REDUCAO' )
oRegraBase:SetProperty( 'F27_TPRED'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_REDUCAO' )

//Define os campos do grupo do detalhamento da base de cálculo por unidade de medida
oRegraBase:SetProperty( 'F27_UM'     , MVC_VIEW_GROUP_NUMBER, 'GRUPO_BASE_QUANTIDADE' )
oRegraBase:SetProperty( 'F27_UMDESC' , MVC_VIEW_GROUP_NUMBER, 'GRUPO_BASE_QUANTIDADE' )

//Picture do campo código
oRegraBase:SetProperty('F27_CODIGO' , MVC_VIEW_PICT, "@!")

// //Se a tabela CIN existir então dividirei a tela em duas partes, uma para dados cadastrais da regr e outra com detalhamento da fórmula
If lCIN
    oFormula:SetProperty("CIN_FORMUL"  , MVC_VIEW_CANCHANGE, .F.)

    //Remove o campo da View
    oRegraBase:RemoveField("F27_ID")

    //Cria as views do operando e da fórmula    
    oView:AddField( 'VIEW_FORMULA' , oFormula, 'FORMULBAS')

    //Cria as view do campo regra
    oView:AddField( 'VIEW_REGRA' , oRegra, 'FORMULBAS')

    //Ajuste dos títulos dos campos de filtros de fórmula
    oRegra:SetProperty("CIN_CONSUL", MVC_VIEW_TITULO, "Consulta de Regras")
    oRegra:SetProperty("CIN_FILTRO", MVC_VIEW_TITULO, "Tipo da Regra a ser consultada")
    oRegra:SetProperty("CIN_VAL", MVC_VIEW_TITULO, "Valor a ser adicionado na fórmula")
    oRegra:SetProperty("CIN_TRIB", MVC_VIEW_TITULO, "Tributo para filtrar a consulta")

    If lOriTrb
        oRegra:SetProperty("CIN_ORITRB", MVC_VIEW_TITULO, "Referencia do Tributo")
    Endif

    //Ordem dos campos da CIN para realizarem filtros nas fórmulas
    oRegra:SetProperty("CIN_FILTRO" , MVC_VIEW_ORDEM, "01")
    oRegra:SetProperty("CIN_TRIB"   , MVC_VIEW_ORDEM, "02")
    oRegra:SetProperty("CIN_CONSUL" , MVC_VIEW_ORDEM, "03")
    oRegra:SetProperty("CIN_VAL"    , MVC_VIEW_ORDEM, "04")    

    If lOriTrb
        oRegra:SetProperty("CIN_ORITRB" , MVC_VIEW_ORDEM, "05")
    Endif

     //Divide a tela em duas pastas
     oView:CreateFolder( 'PASTAS' )
     oView:AddSheet( 'PASTAS', 'ABA01', "Definição da Base de Cálculo"       )
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
    oView:AddOtherObject("BOTOES", {|oPanel| xFisFormul(oPanel, "FORMULBAS","VIEW_FORMULA", "1", "F27_CODIGO", "FISA161", "CIN_CONSUL", "VIEW_REGRA")}) 

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

    oView:SetFieldAction("CIN_TRIB", { |oView, cIDView| FSA161SFoc(oView, cIDView,"CIN_FILTRO")})

EndIF

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161VORI
Função que montará as opções disponíveis para a origem da base de cálculo.
o X3_CBOX chamará esta função 

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA161VORI(lCarga)

Local aOpcoes   := {}
Local cRet      := ''
Local nI        := 0

Default lCarga  := .F.

/*
Ao adicionar novas opções é nescessario informar a segunda coluna com descrição da formula e terceira valor da formula
Desta forma ao processar FISA170 sera dado carga da tabela CIN
Quando não informar segunda ou terceira coluna não sera dado carga na CIN
*/

//          F27 Combo                        |      CIN Descrição         |  CIN Formula
AADD(aOpcoes,{"01=Valor da Mercadoria"       ,"Valor da Mercadoria"       ,"VAL_MERCADORIA" })
AADD(aOpcoes,{"02=Quantidade"                ,"Quantidade"                ,"QUANTIDADE"     })
AADD(aOpcoes,{"03=Valor Contábil"            ,"Valor Contábil"            ,"VAL_CONTABIL"   })
AADD(aOpcoes,{"04=Valor do Crédito Presumido","Valor do Crédito Presumido","VAL_CRED_PRESU" })
AADD(aOpcoes,{"05=Base de ICMS"              ,"Base de ICMS"              ,"BASE_ICMS"      })
AADD(aOpcoes,{"06=Base Original do ICMS"     ,"Base Original do ICMS"     ,"BASE_ORIG_ICMS" })
AADD(aOpcoes,{"07=Valor do ICMS"             ,"Valor do ICMS"             ,"VAL_ICMS"       })
AADD(aOpcoes,{"08=Valor do Frete"            ,"Valor do Frete"            ,"FRETE"          })
AADD(aOpcoes,{"09=Valor da Duplicata"        ,"Valor da Duplicata"        ,"VAL_DUPLICATA"  })
AADD(aOpcoes,{"10=Valor total do Item"       ,"Valor total do Item"       ,"TOTAL_ITEM"     })
If lCIN
    AADD(aOpcoes,{"11=Fórmula Manual"            ,""                          ,""               })
Endif

If lCarga
    Return aOpcoes
Endif

For nI:=1 To Len(aOpcoes)
    cRet += IIf(empty(cRet),'',';') + aOpcoes[nI][1]
Next

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Função responsável por realizar as validações do model 
Será acionada ao salvar o modelo.

@author Erick G Dias
@since 19/06/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local nRedBase 		:= oModel:GetValue ('FISA161',"F27_REDBAS")
Local cTpRed        := oModel:GetValue ('FISA161',"F27_TPRED")
Local cOrig         := oModel:GetValue ('FISA161',"F27_VALORI")
Local lRet          := .T.
Local cErrForml     := ""
Local oView 	    := nil

//VAlidações para operações de inclusão e alteração.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    If cOrig <> "11"
        //Validação de reducao base de cálculo sem fórmula manual
        
        //Se houver percentual de redução de base de cálculo informado exigirá o tipo de redução
        If nRedBase > 0 .AND. Empty(cTpRed)
            lRet:= .F.
            Help( ,, 'Help',, STR0008, 1, 0 ) // 'Por favor, informe o Tipo de Redução.'
        EndIf   

    Else
        //Validação de reducao base de cálculo utilizando fórmula manual        
       If nRedBase > 0 .AND. lCIN .And. !cOperRedBas $ oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
            //Neste caso não temos operando de redução na fórmula, porém temos o percentual preenchido no campo específico
            //Poderia alertar o usuário para limpar, mas acho melhor e sguro a própria rotina limpar este campo automaticamente
            
            //Zerando percentual
            oModel:SetValue ('FISA161',"F27_REDBAS",0) 
            
            //Atualizando a View
            oView 	:= 	FWViewActive()
            oview:Refresh( 'VIEW_CABECALHO')
            
        ElseIf  nRedBase == 0 .AND. lCIN .And. cOperRedBas $ oModel:GetValue ('FORMULBAS',"CIN_FORMUL")  
            //Aqui precisa informar o percentual de redução
            lRet:= .F.
            Help( ,, 'Help',, "Por favor, informe percentual de redução", 1, 0 )
        EndIF
    EndIF    

    //Se a tabela CIN existe então será verificada a sintaxe da fórmula antes de gravar
    If lRet .AND. lCIN .AND. !xForCheck("FORMULBAS", @cErrForml, .F., "1", "F27_CODIGO", "FISA161")
        lRet:= .F.
        Help( ,, 'Help',, "Erro de sintaxe da Fórmula: -" + CRLF + CRLF + cErrForml, 1, 0 ) // 'Erro na fórmula, por favor verifique
    EndIF

EndIF

//Validação da exclusão, para que não permita excluir caso este ID já tenha sido utilizado na gravação da F2D.
IF nOperation == MODEL_OPERATION_DELETE

    dbSelectArea("F2D")
    dbSetOrder(5)
    If F2D->(MsSeek(xFilial('F2D') + F27->F27_ID))
        lRet    := .F.
        Help( ,, 'Help',, STR0009, 1, 0 ) //"Esta regra já foi utilizada na gravação dos tributos genéricos e não poderá ser excluída!"
    EndIF

EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerfil
Função que valida se o código de perfil cadastrado já existe

@author Erich M. Buttner
@since 20/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodBase 	:= oModel:GetValue ('FISA161',"F27_CODIGO")
Local lRet      := .T.

//Verifico se o perfil já existe.
//Procura se já existe regra de base de cálculo com o mesmo código e ativa
If F27->( MsSeek ( xFilial('F27') + cCodBase + '2' ) )
    Help( ,, 'Help',, "Código já cadastrado!", 1, 0 ) 
    return .F.    
EndIF

//Não pode digitar operadores e () no código
If "*" $ cCodBase .Or. ;
   "/" $ cCodBase .Or. ;
   "-" $ cCodBase .Or. ;
   "+" $ cCodBase .Or. ;
   "(" $ cCodBase .Or. ;
   ")" $ cCodBase
    Help( ,, 'Help',, "Código da regra não pode conter os caracteres '*', '/', '+', '-', '(' e ')'", 1, 0 ) 
    return .F.
EndIF

IF " " $ Alltrim(cCodBase)
    Help( ,, 'Help',, "Código não pode conter espaço.", 1, 0 ) 
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161Grava
Função responsável por realizar a gravação da regra de base de alíquota
Aqui faremos o tratamento do histórico de alterações

@author Erick Dias
@since 13/07/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA161Grava(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cCodigo 		:= oModel:GetValue ('FISA161',"F27_CODIGO")
Local cDescri 		:= oModel:GetValue ('FISA161',"F27_DESC")
Local cValOri 		:= oModel:GetValue ('FISA161',"F27_VALORI")
Local cDesc 		:= oModel:GetValue ('FISA161',"F27_DESCON")
Local cFrete 		:= oModel:GetValue ('FISA161',"F27_FRETE")
Local cSeguro  		:= oModel:GetValue ('FISA161',"F27_SEGURO")
Local cDesp  		:= oModel:GetValue ('FISA161',"F27_DESPE")
Local cIcmsDes 		:= oModel:GetValue ('FISA161',"F27_ICMDES")
Local cIcmsRet 		:= oModel:GetValue ('FISA161',"F27_ICMRET")
Local nReduzBase	:= oModel:GetValue ('FISA161',"F27_REDBAS")
Local cTpReduz  	:= oModel:GetValue ('FISA161',"F27_TPRED")
Local cUm 	    	:= oModel:GetValue ('FISA161',"F27_UM")
Local cFormula     	:= ""
Local cIdRegra      := ""
Local lChvMD5       := F27->(FieldPos('F27_CHVMD5') > 0)
Local cChvMD5       := ""

If nOperation == MODEL_OPERATION_INSERT 

    If ( lCIN .And. lChvMD5 )
        cChvMD5 := GetChvMd5()
    EndIf

    //Chama função para gravar nova informação na tabela F27
    cIdRegra    := GravaF27(1, cCodigo, cDescri, cValOri, cDesc, cFrete, cSeguro, cDesp, cIcmsDes, cIcmsRet, nReduzBase, cTpReduz, cUm, cChvMD5)
    
    //Grava as informações da fórmula na tabela CIN
    If lCIN        
        cFormula    := oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
        GravaCIN("1","1", cCodigo, cIdRegra, cDescri, cFormula)        
    EndIF

ElseIF  nOperation == MODEL_OPERATION_UPDATE
    //Chama função para alterar registro atual
    cIdRegra    := GravaF27(2)
    //Grava as informações da fórmula na tabela CIN
    If lCIN
        //Chama função para editar a regra CIN
        GravaCIN("2",,, cIdRegra)        

        If ( lChvMD5 )
            cChvMD5 := GetChvMd5()
        EndIf
    EndIF
    
    //Agora chamo função para inserir novo registro
    cIdRegra := GravaF27(1, cCodigo, cDescri, cValOri, cDesc, cFrete, cSeguro, cDesp, cIcmsDes, cIcmsRet, nReduzBase, cTpReduz, cUm, cChvMD5)
    
    //Grava as informações da fórmula na tabela CIN
    If lCIN
        //Chama função para editar a regra CIN
        GravaCIN("2",,, cIdRegra)
        
        //Chama função para gravar nova linha na CIN
        cFormula    := oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
        GravaCIN("1","1", cCodigo, cIdRegra	, cDescri, cFormula)
    EndIF
    
ElseIf nOperation == MODEL_OPERATION_DELETE
    
    If lCIN
        //Chama função para excluir a regra CIN antes de excluir a F27
        GravaCIN("3",,, F27->F27_ID)
    EndIF

    //Faz exclusão do registro
    RecLock("F27",.F.)
	F27->(dbDelete())
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
Static Function GravaF27(nOp, cCodigo, cDescri, cValOri, cDesc, cFrete, cSeguro, cDesp, cIcmsDes, cIcmsRet, nReduzBase, cTpReduz, cUm, cChvMD5)
Local cId   := ""
If nOp == 1 //Incluiu
    RecLock("F27",.T.)
    F27->F27_FILIAL	    := xFilial("F27")
    F27->F27_ID		    := FWUUID("F27")
    F27->F27_CODIGO	    := cCodigo
    F27->F27_DESC  	    := cDescri
    F27->F27_VALORI	    := cValOri
    F27->F27_DESCON 	    := cDesc
    F27->F27_FRETE  	    := cFrete
    F27->F27_SEGURO	    := cSeguro
    F27->F27_DESPE 	    := cDesp
    F27->F27_ICMDES	    := cIcmsDes
    F27->F27_ICMRET	    := cIcmsRet
    F27->F27_REDBAS	    := nReduzBase
    F27->F27_TPRED 	    := cTpReduz
    F27->F27_UM    	    := cUm
    F27->F27_ALTERA		:= "2" //Indica que não foi alterado    

    If ( !Empty(cChvMD5) )
        F27->F27_CHVMD5 := cChvMD5
    EndIf

    MsUnLock()

ElseIf nOp ==2 //Alteração    
    RecLock("F27",.F.)
    F27->F27_ALTERA 		:= "1"//Indica que sofreu alterações
    F27->F27_DTALT  		:= Date()
    F27->F27_HRALT  		:= Time()
    MsUnLock()

EndIf

Return cId := F27->F27_ID

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161Form
Função que atualiza a fórmula da regra de base de cálculo.
Ao alterar algum operando do modo básico da regra, a fórmula 
será atualizada.

@return - .T.

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161Form(cFormula)

Local oModel        := FWModelActive()
Local cValOri 		:= oModel:GetValue ('FISA161',"F27_VALORI")
Local cOpcaoOri     := ""
Local cRed          := ""
Local lRedAnt       := .F. //Reduz antes das adições e subtrações
Local lRedDep       := .F. //Reduz depois das adições e subtrações
Local cPrefixo      := ""

Default cFormula    := ""

//Inicia a fórmula com operando de origem
cOpcaoOri   :=  RetOperOri(cValOri)

IF cValOri == "11" 
   
    //Primeiro limpa a fórmula
    xForClear("FORMULBAS", .F., "VIEW_FORMULA")

    //Envia a Formula    
    xForBtnAct(cFormula, "FORMULBAS", .F., "VIEW_FORMULA")    

    lclicked    := .T.
    
    Return .T.

Endif

//Primeiro limpa a fórmula
xForClear("FORMULBAS", .F., "VIEW_FORMULA")

//Se operador estiver fazio então a fórmula não será montada!
If !Empty(cOpcaoOri)
    
    //Verifica se tem redução de base de cálculo
    IF oModel:GetValue ('FISA161',"F27_REDBAS") > 0        
        
        //Obtenho o operando da redução de base de cálculo
        cRed    := xFisTpForm('9') + cOperRedBas
        
        //Atualiza as variaveis de controle d eredução
        lRedAnt := oModel:GetValue ('FISA161',"F27_TPRED") == "1" //Reduz antes das adições e deduções        
        lRedDep := oModel:GetValue ('FISA161',"F27_TPRED") == "2" //Reduz depois das adições e deduções                

        //Se a redução acontecer antes então já devo abrir parentes aqui!
        IF lRedAnt .OR. lRedDep 
            xForBtnAct("(", "FORMULBAS", .F., "VIEW_FORMULA")
        EndIF

    EndIF

    //"0" = Operador primário
    cPrefixo:= xFisTpForm("0")
    //Adiciona o operador de origem/início na fórmula
    xForBtnAct(cPrefixo+RetOperOri(cValOri), "FORMULBAS", .F., "VIEW_FORMULA")

    //Se a redução for antes, então multiplico pelo percentual de redução e fecho os parenteses
    IF lRedAnt         
        //Adiciona o operador de multiplicação
        xForBtnAct("*", "FORMULBAS", .F., "VIEW_FORMULA")
    
        //Adiciona o percentual
        xForBtnAct(cRed, "FORMULBAS", .F., "VIEW_FORMULA")
    
        //Fecha o parentes
        xForBtnAct(")", "FORMULBAS", .F., "VIEW_FORMULA")
    
    EndIF
    
    //Verifica se precisa adicionar o operando de desconto na fórmula    
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_DESCON"),cPrefixo+"DESCONTO"        ) , "FORMULBAS", .F., "VIEW_FORMULA" )

    //Verifica se precisa adicionar o operando de frete na fórmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_FRETE"),cPrefixo+"FRETE"            ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de SEGURO na fórmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_SEGURO"),cPrefixo+"SEGURO"          ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de despesas na fórmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_DESPE"), cPrefixo+"DESPESAS"        ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de ICMS Deson na fórmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_ICMDES"),cPrefixo+"ICMS_DESONERADO" ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Verifica se precisa adicionar o operando de ICMS Retido na fórmula
    xForBtnAct( AddOperComb(oModel:GetValue ('FISA161',"F27_ICMRET"),cPrefixo+"ICMS_RETIDO"     ) , "FORMULBAS", .F. , "VIEW_FORMULA")

    //Se reduz depois das adicções e subtrações
    IF lRedDep
    
        //Fecha o parentes
        xForBtnAct(")", "FORMULBAS", .F., "VIEW_FORMULA")
        
        //Adiciona o operador de multiplicação
        xForBtnAct("*", "FORMULBAS", .F., "VIEW_FORMULA")
        
        //Adiciona o percentual
        xForBtnAct( cRed , "FORMULBAS", .F., "VIEW_FORMULA")
    
    EndIF   
    //Indica que o botão de edição de fórmula ficará habilitado novamente
    lclicked := .T.
EndiF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetOperOri
Função que retorna o operando para a opção selecionada de origem de
base de cálculo.

@param -  cValOri - Opção selecionada no combo
@return - cOpcaoOri - Operando correspondente a origem selecionada

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function RetOperOri(cValOri)

Local cOpcaoOri := ""

IF cValOri == "01"
    cOpcaoOri := "VAL_MERCADORIA"
ElseIF cValOri == "02"
    cOpcaoOri := "QUANTIDADE"
ElseIF cValOri == "03"
    cOpcaoOri := "VAL_CONTABIL
ElseIF cValOri == "04"
    cOpcaoOri := "VAL_CRED_PRESU"
ElseIF cValOri == "05"
    cOpcaoOri := "BASE_ICMS"
ElseIF cValOri == "06"
    cOpcaoOri := "BASE_ORIG_ICMS"
ElseIF cValOri == "07"
    cOpcaoOri := "VAL_ICMS"
ElseIF cValOri == "08"
    cOpcaoOri := "FRETE"
ElseIF cValOri == "09"
    cOpcaoOri := "VAL_DUPLICATA"
ElseIF cValOri == "10"
    cOpcaoOri := "TOTAL_ITEM"
EndIF

Return cOpcaoOri

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperComb
Função que adiciona operador e operando dos campos da onda 1 do
configurador, das opções do combo.

@param -  cOpc - Indica se soma, subtrai ou sem ação
@param -  cOperando - Operando a ser adicionado na fórmula

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function AddOperComb(cOpc, cOperando)

Local cOperador := ""

IF cOpc == "2" //Subtração
    cOperador := "- "
ElseIF cOpc == "3" //Adição
    cOperador := "+ "
EndIF
//Se tem operador então seguirei 
If Len(cOperador) > 0
    //Adiciona o operador
    xForBtnAct(cOperador , "FORMULBAS", .F., "VIEW_FORMULA" )

    //Adiciona operando
    xForBtnAct(cOperando , "FORMULBAS", .F., "VIEW_FORMULA" )
EndIF

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161HFor
Função que indica se o campo de fórmula deverá ou não estar habilitado,
e ter o seu conteúdo alterado.

@return - bool - Retorna verdadeiro se a opção de fórmula manual estiver selecionada

@author Erick Dias
@since 30/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161HFor()
return !lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161AFor
Função executada quando usuário acionou edição manual na fórmula, 
função chamada no action do botão habilitar fórmulas.
Para isso preciso indicar no valor de origem a opção 11, que 
significa fórmula manual.
Além disso preciso também restaurar os demais campos para as opções
iniciais, e deixar estes campos desabilitados, já que a fórmula será 
construída manualmente, e não mais por meio dos combos, até mesmo
porq não seria possível representar todas as fórmulas nos combos, 
já que a fórmula é muito mais flexivel.

@author Erick Dias
@since 31/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161AFor()
Local oModel     := FWModelActive()
Local oFormul   := oModel:GetModel("FISA161")
Local oView 	:= 	FWViewActive()
    
//Adiciona o operador no final da fórmula
oFormul:SetValue('F27_VALORI',  "11")

//Aqui retornarei todos os campos para estado inicial
oFormul:LoadValue('F27_DESCON', Criavar("F27_DESCON"))
oFormul:LoadValue('F27_FRETE',  Criavar("F27_FRETE"))
oFormul:LoadValue('F27_SEGURO', Criavar("F27_SEGURO"))
oFormul:LoadValue('F27_DESPE',  Criavar("F27_DESPE"))
oFormul:LoadValue('F27_ICMDES', Criavar("F27_ICMDES"))
oFormul:LoadValue('F27_ICMRET', Criavar("F27_ICMRET"))
oFormul:LoadValue('F27_TPRED' , Criavar("F27_TPRED"))    

//Atualizo a view
oview:Refresh( 'VIEW_CABECALHO')
oview:Refresh( 'VIEW_REGRA')
oview:Refresh( 'VIEW_FORMULA')
oview:Refresh( 'BOTOES')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa161HBtn
Esta função indica se o botão que habilita a edição da fórmula deverá estar
ou não habilitado.

Por padrão em um novo cadastro o botão estará habilitado.

@return bool - Retorna verdadeiro quando a opção de origem não é fórmula manual(11)

@author Erick Dias
@since 31/01/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function Fsa161HBtn()
Return lclicked

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161F27
Função executada quando usuário entrada na rotina FISA170
Esta rotina faz carga na tabela CIN conforme as regras definidas 
Esta rotina deve ser executada epenas quando existir regras cadastradas antes da existencia de formulas

@author Rafael S Oliveira
@since 07/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA161F27()
Local oModel    := nil
Local cCodigo   := ""
Local cDescri   := ""
Local cFormula  := ""
Local cIdRegra  := ""
Local cAlias    := ""
Local cAltera   := ""

//Realiza pesquisa pela relação da F27 com CIN
cAlias := PesqCIN("F27")

DbSelectArea(cAlias)

//Caso não encontre diferenças finaliza processo
If ((cAlias)->(Eof()))
    (cAlias)->(dbCloseArea())
    return
Endif

//Model da rotina FISA161
oModel    := FWLoadModel('FISA161')

DbSelectArea("F27")
F27->(DbSetOrder(3)) // F27_FILIAL+F27_ID

While (!(cAlias)->(Eof()))

    If F27->(MsSeek(xFilial("F27") + (cAlias)->F27_ID))

        oModel:Activate()

        cCodigo   := oModel:GetValue ('FISA161',"F27_CODIGO")   // Código Regra
        cDescri   := oModel:GetValue ('FISA161',"F27_DESC")    // Descrição   
        cIdRegra  := oModel:GetValue ('FISA161','F27_ID')
        cAltera   := Iif(F27->F27_ALTERA == '2',"0","1")

        //Função que atualiza a fórmula da regra de base de cálculo.
        Fsa161Form()

        cFormula    := oModel:GetValue ('FORMULBAS',"CIN_FORMUL")
        GravaCIN("1","1", cCodigo, cIdRegra, cDescri, cFormula,cAltera)

        oModel:DeActivate()
    Endif
    (cAlias)->(dbSkip())
End

oModel:Destroy()
F27->(DbCloseArea())
(cAlias)->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MyPositivo
Função auxiliar de validação do percentual de redução de base de cálculo

@author Erick Dias
@since 14/02/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Static Function MyPositivo()
Local oModel        := FWModelActive()
Return oModel:GetValue ('FISA161',"F27_REDBAS") >= 0


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA161Hist
Função que exibirá Browse com o histórico de alteações da rotina

@author Erick Dias
@since 25/06/2020
@version P12.1.30

/*/
//-------------------------------------------------------------------
Function FSA161Hist()
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
AADD(aColunas,{ STR0019, &("{ || IIf(F27->F27_ALTERA == '1','" + STR0020 + "','" + STR0021 + "') }"), "C", "", 1, 1, 0, .f.}) //"Status - ALterado - Nõo alterado"
AADD(aColunas,{ STR0017, &("{ || F27->F27_DTALT }"), "D", "", 1, 8, 0, .f.}) //"Data de Alteração"
AADD(aColunas,{ STR0018, &("{ || F27->F27_HRALT }"), "C", "", 1, 8, 0, .f.}) //"Horário de Alteração"

//Atribuo o Alias para variavel pública 
c170AlsHist := "F27"

//Monto o filtro abaixo somente com linhas que foram alteradas e não estão mais vigentes
cFiltro :="F27_FILIAL == '" + xFilial("F27") + "'"
cFiltro	+= " .AND. F27_CODIGO == '" + F27->F27_CODIGO +  "'"

//Utilizo segundo índice para facilitar a visualização
F27->(DbSetOrder(5))

//Chamo a função auxiliar que montará o Browse com as regras alteradas.
FSA16XHist("F27", cFiltro, STR0016 , aColunas) //"Histórico de alterações da Regra de Base de Cálculo"

//Retorno o Alias e filtro padrão
c170AlsHist := ""
F27->(DbSetOrder(1))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChvMd5
Função para atualização do campo MD5.

@author Juliano Fernandes
@since 15/04/2024
@version P12.1.2310
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

    cChave := xFisSYard(oModel:GetValue('FORMULBAS', 'CIN_FORMUL'))

    cChvMd5 := cPrefixo + Md5(cChave)

return cChvMd5


/*/{Protheus.doc} FSA161SFoc
    Coloca o focus no campo CIN_FILTRO.

    @type Static Function
    @author anedino.santos
    @since 12/05/2025
    @version 12.1.2410
    @param oView, object, objeto da view em uso
    @param cIDView, character, nome da subview
/*/
static function FSA161SFoc(oView, cIDView,cField)
    oView:getViewObj(cIDView)[3]:getFWEditCtrl(cField):oCtrl:SetFocus()
return
