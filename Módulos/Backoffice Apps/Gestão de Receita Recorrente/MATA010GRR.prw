#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'MATA010GRR.CH'

//----------------------------------- MATA010GRR --------------------------------------
// Eventos para o cadastro de produtos voltado à integra com o GRR.
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA010GRR
Classe de eventos que relaciona o cadastro de produto à plataforma GRR

@author  Marcia Junko
@since   25/08/2022
/*/
//-------------------------------------------------------------------------------------
CLASS MATA010GRR FROM FWModelEvent

    Data cModelMaster   as Character

    Method New( cModelMaster ) Constructor
	Method VldActivate( oModel, cModelId )     
    Method ModelDefGRR( oModel )
    Method GRRCanActivate( oView )
	Method Destroy()

ENDCLASS

//---------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor

@param cModelMaster, caracter, Nome do modelo
@author  Marcia Junko
@since   25/08/2022
/*/
//---------------------------------------------------------
Method New( cModelMaster ) Class MATA010GRR

    Self:cModelMaster   := cModelMaster

Return Nil

//---------------------------------------------------------
/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de pre 
validação do Model. Esse evento ocorre uma vez no contexto 
do modelo principal.

@param oModel, object, Objeto do model
@param cModelId, caracter, nome do model
@author  Marcia Junko
@since   25/08/2022/*/
//---------------------------------------------------------
Method VldActivate( oModel, cModelId ) Class MATA010GRR

    Self:ModelDefGRR( oModel ) 

Return .T.

//---------------------------------------------------------
/*/{Protheus.doc} ModelDefGRR
Adiciona o sub-modelo de Dados Adicionais do Produto GRR ao modelo de Produtos

@param oModel, object, Model do cadastro de produtos

@author  Marcia Junko
@since   25/08/2022
/*/
//---------------------------------------------------------
Method ModelDefGRR( oModel ) Class MATA010GRR
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsável por destruir os atributos da classe como 
arrays e objetos.

@author  Marcia Junko
@since   25/08/2022
/*/
//-------------------------------------------------------------------
Method Destroy() Class MATA010GRR
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GRRCanActivate
Metodo chamado no objeto oView do produto no para habilitar a view da tabela HRG

@param oView, object, View do cadastro de produtos

@author  Marcia Junko
@since   25/08/2023
/*/
//-------------------------------------------------------------------
Method GRRCanActivate( oView ) Class MATA010GRR 
    oView:CreateHorizontalBox( 'FOLDER_HRG', 10 )
    oView:SetOwnerView( 'HRGDETAIL', 'FOLDER_HRG' )
    oView:EnableTitleView( 'HRGDETAIL', STR0002 )     //"Gestão de Receita Recorrente"
Return


//---------------------------------------------------------
/*/{Protheus.doc} M010GRRStruct
Adiciona o sub-modelo de Dados Adicionais do Produto GRR ao modelo de Produtos

@param nType, number, Indica o tipo de ação será executada. Sendo 1=Model e 2=View
@param oObj, object, Se nType=1 recebe oModel e se nType=2 recebe oView
@param cName, caracter, Nome da seção principal
@param cView, caracter, Nome da seção da view

@author  Marcia Junko
@since   29/08/2023
/*/
//---------------------------------------------------------
Function M010GRRStruct( nType, oObj, cName, cView ) 
    Local oStruct := Nil
    Local aRemoveFlds := {}

    oStruct := FWFormStruct( nType, 'HRG' )
    If nType == 1 
        // ----------------------------------------------
        //   Model HRG - produto recorrente do GRR
        // ----------------------------------------------
        oStruct:SetProperty( "HRG_RECURR", MODEL_FIELD_TITULO, STR0001 )   //"Produto Recorrente"

        oObj:AddFields( cName, "SB1MASTER", oStruct )
        oObj:SetRelation( cName, {{ 'HRG_FILIAL', 'xFilial("HRG")' }, { 'HRG_SRCFIL', 'xFilial("SB1")' }, { 'HRG_ALIAS', "'SB1'" }, { 'HRG_CODE', 'B1_COD' }}, ( 'HRG' )->(IndexKey(1)) )
        oObj:GetModel( cName ):SetDescription( STR0002 )     //"Gestão de Receita Recorrente"
        oObj:GetModel( cName ):SetOptional( .T. )
    Elseif nType == 2 
        // ----------------------------------------------
        //   View HRG - produto recorrente do GRR
        // ----------------------------------------------
        aRemoveFlds := { 'HRG_SRCFIL', 'HRG_ALIAS', 'HRG_CODE' }
        aEval( aRemoveFlds, {|x|  oStruct:RemoveField( x ) } )

        oStruct:SetProperty( "HRG_RECURR" , MVC_VIEW_TITULO, STR0001 )   //"Produto Recorrente"

        oObj:AddField( cView, oStruct, cName )
    EndIf

    oStruct := NIL
    FWFreeArray( aRemoveFlds )
Return Nil
