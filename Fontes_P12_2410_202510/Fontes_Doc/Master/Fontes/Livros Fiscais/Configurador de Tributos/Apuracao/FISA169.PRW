#Include "FISA169.ch"
#include "protheus.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FWEditPanel.CH"

PUBLISH MODEL REST NAME FISA169
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA169()

Esta rotina tem objetivo de realizar o cadastro das regras de apurções
para os tibutos genéricos

@author Erick G Dias
@since 19/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA169()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
IF AliasIndic("F2G")
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2G")
    oBrowse:SetDescription(STR0001) //"Regras de Apuração"
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0002,1,0) // Dicionário desatualizado, verifique as atualizações do motor tributário fiscal.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu.

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "FISA169" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo do cadastro das regras de apuração

@author Erick G Dias
@since 11/09/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura Pai do cabeçalho da rotina
Local oCabecalho := FWFormStruct(1, "F2G" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA169')

//Atribuindo cabeçalho para o modelo
oModel:AddFields("FISA169",,oCabecalho)

//Não permite alterar o conteúdo do campo F2G_CODIGO na edição
oCabecalho:SetProperty('F2G_CODIGO' , MODEL_FIELD_WHEN, {|| (oModel:GetOperation()==3 ) })

oModel:SetPrimaryKey( {"F2G_FILIAL","F2G_ID","F2G_CODIGO"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0003) //"Cadastro da regra de Apuração"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função que monta a view da rotina.

@author Erick G Dias    
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA169" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho := FWFormStruct(2, "F2G")
Local oView      := Nil

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO' , oCabecalho , 'FISA169' )

oCabecalho:AddGroup( 'GRUPO_ID' , STR0004 , '' , 2 )    //"Definição da Regra"
oCabecalho:AddGroup( 'GRUPO_MOV'   , STR0005 , '' , 2 ) //"Regras de Movimentação"

//Campos que fazem parte do grupo de definição da regra
oCabecalho:SetProperty( 'F2G_CODIGO'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )
oCabecalho:SetProperty( 'F2G_DESCRI'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_ID' )

//Campos que fazem parte do grupo de regras de movimentação.
oCabecalho:SetProperty( 'F2G_SAIDA'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MOV' )
oCabecalho:SetProperty( 'F2G_ENTRAD'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MOV' )
oCabecalho:SetProperty( 'F2G_DEVOL'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO_MOV' )

// Retirando campo de ID da view.
oCabecalho:RemoveField( 'F2G_ID'  )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA169CARG

Função que fará a cara inicial das regras de apuração, com os dois cadastros
de tributo cumulativo e tributo não cumulativo.

@author Erick G Dias
@since 19/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function FSA169CARG() 

Local aRegra := {{'000001', 'TRIBUTO NÃO CUMULATIVO', '2', '3', '2'},;
                {'000002', 'TRIBUTO CUMULATIVO', '2', '1', '2'}}
Local nX := 0

dbSelectArea("F2G")
F2G->(dbSetOrder(1))

For nX := 1 to Len(aRegra)

    If !F2G->(MsSeek(xFilial('F2G') + aRegra[nX, 1]))
        RecLock("F2G", .T.)
        F2G->F2G_FILIAL  := xFilial("F2G")
        F2G->F2G_ID      := FWUUID('F2G')
        F2G->F2G_CODIGO  := aRegra[nX, 1]
        F2G->F2G_DESCRI  := aRegra[nX, 2]
        F2G->F2G_SAIDA   := aRegra[nX, 3]
        F2G->F2G_ENTRAD  := aRegra[nX, 4]
        F2G->F2G_DEVOL   := aRegra[nX, 5]
        F2G->(MsUnlock())
    EndIf

Next nX

Return Nil

