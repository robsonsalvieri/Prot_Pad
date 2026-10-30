#Include "FISA160L.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA160L
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA160L()

Esta rotina tem objetivo de realizar o cadastro das
Regras para geração da Guia de Escrituração

@author Renato Rezende
@since 17/09/2020
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA160L()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("CJ4")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("CJ4")
    oBrowse:SetDescription(STR0001) //"Regra para geração da Guia de Escrituração"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Renato Rezende
@since 17/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Return FWMVCMenu( "FISA160L" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras para geração da guia

@author Renato Rezende
@since 17/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "CJ4" )

Local lExMesSb := FieldPos("CJ4_MESFIX") > 0

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA160L',,{|oModel|VALIDACAO(oModel) })

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA160L",,oCabecalho)

//Configurações dos campos
oCabecalho:SetProperty('CJ4_CODIGO' , MODEL_FIELD_KEY   , .T. )

oCabecalho:SetProperty('CJ4_CODIGO' , MODEL_FIELD_VALID , {|| ( VldCod(oModel) )})
oCabecalho:SetProperty('CJ4_MODO'   , MODEL_FIELD_VALID , {|| (Fsa160LCpo("CJ4_MODO"))    })
oCabecalho:SetProperty('CJ4_CFVENC' , MODEL_FIELD_VALID , {|| (Fsa160LCpo("CJ4_CFVENC"))    })

oCabecalho:SetProperty('CJ4_CODIGO' , MODEL_FIELD_WHEN  , {|| (oModel:GetOperation() == 3 ) })
oCabecalho:SetProperty('CJ4_MAJSEP'  , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_ORIDES' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_IMPEXP' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_IE'     , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_QTDDIA' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_CFVENC") == "1" } )
oCabecalho:SetProperty('CJ4_DTFIXA' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_CFVENC") $ "2|3|4" } )
If lExMesSb
   oCabecalho:SetProperty('CJ4_MESFIX' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_CFVENC") == "4" } ) 
EndIf
oCabecalho:SetProperty('CJ4_CNPJ'   , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_IEGUIA' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_UF'     , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_INFCOM' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )
oCabecalho:SetProperty('CJ4_DESINF' , MODEL_FIELD_WHEN  , {|| oModel:GetValue('FISA160L',"CJ4_MODO") == "1" } )

oModel:SetPrimaryKey( {"CJ4_FILIAL","CJ4_CODIGO"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0001) //"Regra para geração da Guia de Escrituração"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Renato Rezende    
@since 17/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA160L" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "CJ4")
Local oView      := Nil
Local lExMesSb := CJ4->(FieldPos("CJ4_MESFIX")) > 0

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA160L' )

oCabecalho:AddGroup( 'GRUPO_ID'     , STR0003 , '' , 2 )  //"Definição da Regra"
oCabecalho:AddGroup( 'GRUPO_MODO'   , STR0004 , '' , 2 )  //"Modo para geração da Guia"
oCabecalho:AddGroup( 'GRUPO_CONF'   , STR0005 , '' , 2 )  //"Critérios para geração da Guia"
oCabecalho:AddGroup( 'GRUPO_VENC'   , "Vencimento da GNRE" , '' , 2 )  //"Vencimento da GNRE"
oCabecalho:AddGroup( 'GRUPO_COMP'   , "Informações Complementares da GNRE" , '' , 2 )  //"Informações Complementares da GNRE"


//Campos que fazem parte do grupo de definição da regra
oCabecalho:SetProperty( 'CJ4_CODIGO'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )
oCabecalho:SetProperty( 'CJ4_DESCR'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )

//Campos que fazem parte do grupo de regras de titulos
oCabecalho:SetProperty( 'CJ4_MODO'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MODO' )
oCabecalho:SetProperty( 'CJ4_VTELA'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MODO' )
oCabecalho:SetProperty( 'CJ4_MAJSEP'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MODO' )

//Campos que fazem parte do grupo de regras de guia
oCabecalho:SetProperty( 'CJ4_ORIDES'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CONF' )
oCabecalho:SetProperty( 'CJ4_IMPEXP'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CONF' )
oCabecalho:SetProperty( 'CJ4_IE'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_CONF' )

//Campos que fazem parte do grupo de vencimento da GNRE
oCabecalho:SetProperty( 'CJ4_CFVENC'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
oCabecalho:SetProperty( 'CJ4_QTDDIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
oCabecalho:SetProperty( 'CJ4_DTFIXA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
If lExMesSb
    oCabecalho:SetProperty( 'CJ4_MESFIX'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_VENC' )
EndIf

//Campos que fazem parte do grupo de informações complementares da GNRE
oCabecalho:SetProperty( 'CJ4_CNPJ'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_IEGUIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_UF'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_INFCOM'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )
oCabecalho:SetProperty( 'CJ4_DESINF'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_COMP' )

//Ajuste dos títulos dos campos de filtros de fórmula
oCabecalho:SetProperty("CJ4_MODO"  , MVC_VIEW_TITULO, STR0006)    //"Modo para Geração da Guia de Escrituração"
oCabecalho:SetProperty("CJ4_VTELA" , MVC_VIEW_TITULO, STR0007)   //"Visualiza Guia no Momento da Geração da Nota"
oCabecalho:SetProperty("CJ4_MAJSEP", MVC_VIEW_TITULO, "Guia de Majoração")   //"Visualiza Guia no Momento da Geração da Nota"
oCabecalho:SetProperty("CJ4_ORIDES", MVC_VIEW_TITULO, STR0008)  //"UF de Origem e Destino"
oCabecalho:SetProperty("CJ4_IMPEXP", MVC_VIEW_TITULO, STR0009)  //"Importação ou Exportação"
oCabecalho:SetProperty("CJ4_IE"    , MVC_VIEW_TITULO, STR0010)      //"Inscrição Estadual na UF de Destino"
oCabecalho:SetProperty("CJ4_DTFIXA", MVC_VIEW_TITULO, STR0016)  //"Data do Dia Fixo"
oCabecalho:SetProperty("CJ4_QTDDIA", MVC_VIEW_TITULO, STR0015)  //"Quantidade de Dias a Somar"
If lExMesSb
    oCabecalho:SetProperty("CJ4_MESFIX", MVC_VIEW_TITULO, "Quantidade de Meses")  //"Quantidade de Meses"
EndIf

//Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CABECALHO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fsa160LCpo
Função que valida os campos

@author Renato Rezende    
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Function Fsa160LCpo(cCampo)

Local oModel        := FWModelActive()
Local cModoGera 	:= oModel:GetValue ('FISA160L',"CJ4_MODO")
Local cCfcVenc      := oModel:GetValue ('FISA160L',"CJ4_CFVENC")
Local oCabecalho	:= oModel:GetModel("FISA160L")
Local lExMesSb := CJ4->(FieldPos("CJ4_MESFIX")) > 0

If cCampo == "CJ4_MODO"
    //Limpa o conteúdo dos campos abaixo
    If cModoGera <> '1'
        //grupo de regras de titulos
        oCabecalho:LoadValue('CJ4_VTELA' , Criavar("CJ4_VTELA") )
        oCabecalho:LoadValue('CJ4_MAJSEP' , Criavar("CJ4_MAJSEP") )        
        
        //grupo de regras de guia
        oCabecalho:LoadValue('CJ4_ORIDES', Criavar("CJ4_ORIDES") )
        oCabecalho:LoadValue('CJ4_IMPEXP', Criavar("CJ4_IMPEXP") )
        oCabecalho:LoadValue('CJ4_IE'    , Criavar("CJ4_IE") )
        
        //grupo de informações complementares da GNRE
        oCabecalho:LoadValue('CJ4_CNPJ'  , Criavar("CJ4_CNPJ") )
        oCabecalho:LoadValue('CJ4_IEGUIA', Criavar("CJ4_IEGUIA") )
        oCabecalho:LoadValue('CJ4_UF'    , Criavar("CJ4_UF") )
        oCabecalho:LoadValue('CJ4_INFCOM', Criavar("CJ4_INFCOM") )
        oCabecalho:LoadValue('CJ4_DESINF', " " )
        
        //grupo de vencimento da GNRE
        oCabecalho:LoadValue('CJ4_CFVENC', Criavar("CJ4_CFVENC") )
        oCabecalho:LoadValue('CJ4_QTDDIA', Criavar("CJ4_QTDDIA") )
        oCabecalho:LoadValue('CJ4_DTFIXA', Criavar("CJ4_DTFIXA") )
        If lExMesSb
            oCabecalho:LoadValue('CJ4_MESFIX', Criavar("CJ4_MESFIX") )
        EndIf
    EndIf
ElseIf cCampo == "CJ4_CFVENC"
    If cCfcVenc <> '1'
        oCabecalho:LoadValue('CJ4_QTDDIA' , Criavar("CJ4_QTDDIA") )
        If lExMesSb .And. cCfcVenc <> '4'
            oCabecalho:LoadValue('CJ4_MESFIX' , Criavar("CJ4_MESFIX") )
        EndIf
    Else
        oCabecalho:LoadValue('CJ4_DTFIXA', Criavar("CJ4_DTFIXA") )
        If lExMesSb
            oCabecalho:LoadValue('CJ4_MESFIX' , Criavar("CJ4_MESFIX") )
        EndIf
    EndIf
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCod
Função que valida se o código da regra

@author Renato Rezende
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function VldCod(oModel)

Local cCodigo 	:= oModel:GetValue ('FISA160L',"CJ4_CODIGO")
Local lRet      := .T.

//Procura se já existe regra com o mesmo código
CJ4->(DbSetOrder(1))
If CJ4->( MsSeek ( xFilial('CJ4') + cCodigo ) )
    Help( ,, 'Help',, STR0011, 1, 0 ) //"Código já cadastrado!"
    return .F.    
EndIF

//Não pode digitar operadores e () no código
If "*" $ cCodigo .Or. ;
   "/" $ cCodigo .Or. ;
   "-" $ cCodigo .Or. ;
   "+" $ cCodigo .Or. ;
   "(" $ cCodigo .Or. ;
   ")" $ cCodigo
    Help( ,, 'Help',, STR0012, 1, 0 ) //"Código da regra não pode conter os caracteres '*', '/', '+', '-', '(' e ')'"
    return .F.
EndIF

IF " " $ Alltrim(cCodigo)
    Help( ,, 'Help',, STR0013, 1, 0 ) //"Código não pode conter espaço."
    Return .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Validacao
Função que realiza as validações do modelo

@param		oModel  - Objeto    - Objeto do modelo FISA160L
@Return     lRet    - Booleano  - Retorno com validação, .T. pode gravar, .F. não poderá gravar.

@author Renato Rezende
@since 18/09/2020
@version P12.1.31

/*/
//-------------------------------------------------------------------
Static Function Validacao(oModel)

Local lRet          := .T.
Local cModoGera     := oModel:GetValue ('FISA160L',"CJ4_MODO" )
Local cOriDest      := oModel:GetValue ('FISA160L',"CJ4_ORIDES" )
Local cImpExp       := oModel:GetValue ('FISA160L',"CJ4_IMPEXP" )
Local cIE           := oModel:GetValue ('FISA160L',"CJ4_IE" )
Local cCfcVenc      := oModel:GetValue ('FISA160L',"CJ4_CFVENC")
Local nDtFixa       := oModel:GetValue ('FISA160L',"CJ4_DTFIXA" )
Local nSomaDt       := oModel:GetValue ('FISA160L',"CJ4_QTDDIA" )
Local nMesFixo      := 0
Local nOperation 	:= oModel:GetOperation()
Local lExMesSb := CJ4->(FieldPos("CJ4_MESFIX")) > 0

If lExMesSb
    nMesFixo := oModel:GetValue ('FISA160L',"CJ4_MESFIX" )
EndIf

//Validações na inclusão ou alteração do cadastro
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    //Se o campo como será gerada a guia estiver em branco os outros campos de decisão não poderão estar preenchidos
    If Empty(cModoGera)
        If !Empty(cOriDest) .Or. !Empty(cImpExp) .Or. !Empty(cIE)    
            lRet:= .F.
            Help( ,, 'Help',, STR0014, 1, 0 ) //"Campo obrigatório não preenchido: Modo para Geração da Guia de Escrituração (CJ4_MODO)"
        EndIf
    EndIF
    //Não deixar data com o valor zero
    If cCfcVenc == '1' .And. !(nSomaDt > 0 .and. nSomaDt <= 31)
        lRet:= .F.
        Help( ,, 'Help',, STR0018, 1, 0 )
    Else
        If cCfcVenc $ '2|3' .And. nDtFixa == 0 
            lRet:= .F.            
        ElseIf cCfcVenc == '4' .And. (nDtFixa == 0 .Or. nMesFixo == 0)
            lRet:= .F.            
        EndIf
        If !lRet
            Help( ,, 'Help',, STR0017, 1, 0 ) //"O Valor dos campos Data do Dia Fixo (CJ4_DTFIXA) ou Quantidade de Dias a Somar (CJ4_QTDDIA) não podem ficar com o valor zero!"
        EndIf
    Endif
EndIf

Return lRet
