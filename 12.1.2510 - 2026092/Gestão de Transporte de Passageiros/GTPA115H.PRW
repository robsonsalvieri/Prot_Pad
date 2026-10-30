#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'GTPA115H.CH'

/*/{Protheus.doc} GTPA115H
    Programa em MVC do cadastro de Mapa de viagem
    @type  Function
    @author João Pires
    @since 03/12/2024
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example
    GTPA115H()
    @see (links_or_references)
/*/
Function GTPA115H()
    Local oBrowse := Nil
	If ( !FindFunction("GTPHASACCESS") .Or.;
			( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) )

		oBrowse:= FWMBrowse():New()
		oBrowse:SetAlias("H7X")
		oBrowse:SetDescription(STR0001) //"Cadastro de Mapa de viagens"
		oBrowse:SetMenuDef('GTPA115H')
        oBrowse:Activate()

    EndIf 
Return 

/*/{Protheus.doc} MenuDef
    Função responsável pela montagem de aRotina - opções do menu do browse
    @type  Static Function
    @author João Pires
    @since 03/12/2024
    @version 1
    @param 
    @return aRotina, array, Array com as opções de Menu
    @example
    aRotina := MenuDef()
    @see (links_or_references)
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.GTPA115H' OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.GTPA115H' OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPA115H' OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPA115H' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para o cadastro de Mapa de viagem 
    @type  Static Function
    @author João Pires
    @since 03/12/2024
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
    Local oStru := FWFormStruct( 1, 'H7X', /*bAvalCampo*/,/*lViewUsado*/ )
    Local oModel

    oModel := MPFormModel():New('GTPA115H', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields( 'H7XMASTER', /*cOwner*/, oStru, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    oModel:SetDescription( STR0006 ) //"Mapa de viagens"
    oModel:GetModel( 'H7XMASTER' ):SetDescription( STR0001 ) //'Cadastro Mapa de viagens'

Return oModel

/*/{Protheus.doc} ViewDef
    Função que define o modelo de dados para o cadastro de Mapa de viagens 
    @type  Static Function
    @author João Pires
    @since 03/12/2024
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
	Local oView		 := nil
	Local oModel	 := FwLoadModel("GTPA115H")
    Local oStrU 	 := FWFormStruct( 2, "H7X",,.F. )

    oView := FWFormView():New()
    oView:SetModel( oModel )

    oView:AddField( 'VIEW_H7X', oStru, 'H7XMASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_H7X', 'TELA' )

Return(oView) 
