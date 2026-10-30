#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"

////////////////////////////////////////////////////////////////////////////////////////////////////*
//
//MODEL E VIEW UTILIZADOS NO FONTE health.plan.delinquency.monitor.interface
//
////////////////////////////////////////////////////////////////////////////////////////////////////*/

//////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef
@version P12
/*/
Static Function MenuDef()
   
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.PLREASONCONT" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.PLREASONCONT" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.PLREASONCONT" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.PLREASONCONT" OPERATION 5 ACCESS 0
Return aRotina

//////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef
@version P12
/*/
Static Function ModelDef()

    Local oStruBRZ := FWFormStruct( 1, "BRZ", /*bAvalCampo*/,/*lViewUsado*/ )
    Local oModel   := NIL

    oModel := MPFormModel():New("PLREASONCON", /*bPreValidacao*/,, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields( "BRZMASTER", /*cOwner*/, oStruBRZ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    oModel:SetDescription( "Contatos Realizados" )
    oModel:GetModel( "BRZMASTER" ):SetDescription( "Contatos Realizados" )

Return oModel

//////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef
@version P12
/*/
Static Function ViewDef()
    
    Local oModel   := FWLoadModel( "PLREASONCONT" )
    Local oStruBRZ := FWFormStruct( 2, "BRZ" )
    Local oView    := NIL

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( "VIEW_BRZ", oStruBRZ, "BRZMASTER" )
    oView:CreateHorizontalBox( "TELA" , 100 )
    oView:SetOwnerView( "VIEW_BRZ", "TELA" )
    oView:SetAfterOkButton({||totvs.protheus.health.delinquency.monitor.DelinquencyInterface():updateMessage()})
    oView:SetViewCanActivate({||validateOpeningView()})
  
Return oView

//////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------
/*/{Protheus.doc} validateOpeningView
Não permite realizar nenhuma ação caso não exista um beneficiário
posicionado no grid de beneficiários
@version P12
/*/
Static Function validateOpeningView()
    
    Local lRetOpView := .T.
    
    If EMPTY(BENEINAD->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))
        
        FWAlertWarning("<big>Nenhum beneficiário foi posicionado</big>", "Atenção")
        lRetOpView := .F.
    EndIf
return lRetOpView










