#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSNOTLID

@author Nicole Luna
@since 25/10/2023
@version P12
@description Notificacoes Lidas
/*/
//-------------------------------------------------------------------
Function PLSNOTLID(cCodigo)

    Local oBrowse
    
    oBrowse := FWmBrowse():New()
    oBrowse:SetfilterDefault("@ '" + xfilial("BJH") + "' = BJH_FILIAL AND BJH_CODNOT = '" + cCodigo + "'")
    oBrowse:SetAlias( 'BJH' )
    oBrowse:SetDescription("Visualizações da Notícia") 
    oBrowse:SetMenuDef( 'PLSNOTLID' ) 
    oBrowse:ForceQuitButton()
    oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Nicole Luna
@since 25/10/2023
@version P12
@description MenuDef
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Private aRotina := {}

Return aRotina
