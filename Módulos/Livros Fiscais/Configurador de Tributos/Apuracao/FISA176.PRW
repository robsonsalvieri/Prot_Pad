#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "FISA176.ch"

PUBLISH MODEL REST NAME FISA176
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA176()

Esta rotina tem objetivo de realizar o cadastro das regras de apurções
para os tibutos genéricos

@author Erick G Dias
@since 23/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA176()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2N")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2N")
    oBrowse:SetDescription(STR0001) //"Regra de Títulos da Apuração"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0)  //"Dicionário desatualizado, verifique as atualizações do motor tributário fiscal."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA176" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F2N" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA176',,{|oModel|ValidModel(oModel) })

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA176",,oCabecalho)

oModel:SetPrimaryKey( {"F2N_FILIAL","F2N_TRIB","F2N_RTIT"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0003)  //"Cadastro de Regra de Tìtulo para Apuração"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA176" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2N")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA176' )

oCabecalho:AddGroup( 'GRUPO_ID'     , "Definição da Regra" , '' , 2 )
oCabecalho:AddGroup( 'GRUPO_TITU'   , "Regras de Título"   , '' , 2 ) 
oCabecalho:AddGroup( 'GRUPO_GUIA'   , "Regra para Guia de Recolhimento" , '' , 2 )


//Campos que fazem parte do grupo de definição da regra
oCabecalho:SetProperty( 'F2N_TRIB'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )
oCabecalho:SetProperty( 'F2N_DTRIB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )

//Campos que fazem parte do grupo de regras de titulos
oCabecalho:SetProperty( 'F2N_RTIT'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TITU' )
oCabecalho:SetProperty( 'F2N_DTIT'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_TITU' )

If F2N->(Fieldpos("F2N_RGGUIA")) > 0 .And. F2N->(Fieldpos("F2N_DRGUIA")) > 0
    //Campos que fazem parte do grupo de regras de guia
    oCabecalho:SetProperty( 'F2N_RGGUIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_GUIA' )
    oCabecalho:SetProperty( 'F2N_DRGUIA'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO_GUIA' )
EndIf

//Aqui é a definição de exibir dois campos por linha
oView:SetViewProperty( "VIEW_CABECALHO", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

// Retirando campo de ID da view.
oCabecalho:RemoveField( 'F2N_FKKID'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 23/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ValidModel(oModel)

Local nOperation 	:= oModel:GetOperation()
Local cTrib 		:= oModel:GetValue ('FISA176',"F2N_TRIB")
Local lRet          := .T.
Local nRecno        := F2N->(RECNO())
Local aAreaF2N      := F2N->(GetArea())

//Validações para operações de inclusão e alteração.
IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

    dbSelectArea("F2N")
    dbSetOrder(1)
    If F2N->(MsSeek(xFilial('F2N') + cTrib ))
        //Na inclusão, se a informação existir já barro o usuário para não gravar informação duplicada
        If nOperation == MODEL_OPERATION_INSERT
            lRet    := .F.
        //Já na edição, somente certifico se o RECNO é do próprio registro, se for permite a edição, caso contrário barrará o usuário
        ElseIF nOperation == MODEL_OPERATION_UPDATE .AND. nRecno <> F2N->(RECNO())
            lRet    := .F.            
        EndIF

        IF !lRet
            Help( ,, 'Help',, STR0004, 1, 0 )              //"Código de Tributo já cadastrado"
        EndIF

    EndIF

EndIF

RestArea(aAreaF2N)

Return lRet

