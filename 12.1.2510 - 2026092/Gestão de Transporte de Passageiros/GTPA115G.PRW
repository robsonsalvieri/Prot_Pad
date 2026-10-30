#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE 'GTPA115G.CH'

/*/{Protheus.doc} GTPA115
    Programa em MVC do cadastro de Bilhetes (Passagens) noShow
    @type  Function
    @author José Carlos
    @since 29/10/2024
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example
    GTPA115G()
    @see (links_or_references)
/*/
Function GTPA115G()
    Local oBrowse := Nil
	If ( !FindFunction("GTPHASACCESS") .Or.;
			( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) )

		oBrowse:= FWMBrowse():New()
		oBrowse:SetAlias("H7W")
		oBrowse:SetDescription("Cadastro de Passagens Bilhetes noShow")
		oBrowse:SetMenuDef('GTPA115G')
        oBrowse:Activate()

    EndIf 
Return 

/*/{Protheus.doc} MenuDef
    Função responsável pela montagem de aRotina - opções do menu do browse
    @type  Static Function
    @author José Carlos
    @since 29/10/2024
    @version 1
    @param 
    @return aRotina, array, Array com as opções de Menu
    @example
    aRotina := MenuDef()
    @see (links_or_references)
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GTPA115G' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.GTPA115G' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.GTPA115G' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.GTPA115G' OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
    Função que define o modelo de dados para o cadastro de Bilhetes 
    @type  Static Function
    @author José Carlos
    @since 29/10/2024
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
    Local oStru := FWFormStruct( 1, 'H7W', /*bAvalCampo*/,/*lViewUsado*/ )
    Local oModel

    oModel := MPFormModel():New('GTPA115G', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields( 'H7WMASTER', /*cOwner*/, oStru, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    oModel:SetDescription( 'Bilhetes noShow' )
    oModel:GetModel( 'H7WMASTER' ):SetDescription( 'Cadastro Bilhetes noShow' )

Return oModel

/*/{Protheus.doc} ViewDef
    Função que define o modelo de dados para o cadastro de Bilhetes 
    @type  Static Function
    @author José Carlos
    @since 29/10/2024
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
	Local oView		 := nil
	Local oModel	 := FwLoadModel("GTPA115G")
    Local oStrU 	 := FWFormStruct( 2, "H7W",,.F. )

    oView := FWFormView():New()
    oView:SetModel( oModel )

    oView:AddField( 'VIEW_H7W', oStru, 'H7WMASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_H7W', 'TELA' )

Return(oView) 
