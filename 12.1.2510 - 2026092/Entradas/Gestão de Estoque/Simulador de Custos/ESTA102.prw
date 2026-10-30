#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA102.CH"
#INCLUDE "FWMBROWSE.CH"

PUBLISH MODEL REST NAME ESTA102 SOURCE ESTA102

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA102
    Planos de Simulação - Simulador de Custos
    @type Function
    @author Squad Entradas
    @since 28/08/2026
    @version 12.1.2510 
/*/
//----------------------------------------------------------------------------------
Function ESTA102()
    Local oBrowse   := Nil
    Local lExecute  := FnVldSmlCt()

    If !FwAliasInDic("D5E")
		Help("",1,"D5E",,STR0001,1,0) //"Tabela D5E Não encontrada no dicionário de dados"
		Return
	EndIf

    If lExecute
        oBrowse := BrowseDef()
        If hasSmartX()
		    oBrowse:setSmartX() //define a utilização do novo browse
	    EndIf
        oBrowse:Activate()
    EndIf
    
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
    Definições do browse
    @type Function
    @author Squad Entradas
    @since 28/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse   := Nil
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("D5E") 
    oBrowse:SetDescription(STR0002) //"Planos de Simulação"
    oBrowse:SetMenuDef("ESTA102")
    
Return oBrowse

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
    Definições do Menu
    @type Function
    @author Squad Entradas
    @since 28/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.ESTA102" OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.ESTA102" OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.ESTA102" OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.ESTA102" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definições do modelo
    @type Function
    @author Squad Entradas
    @since 28/08/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruD5E  := FWFormStruct(1, "D5E")

    oModel := MPFormModel():New("ESTA102", /*bPre*/, /*bPos*/, /*bCommit*/)
    oModel:SetDescription(STR0002) //"Planos de Simulação"
    
    oModel:AddFields("D5EMASTER", /*cOwner*/, oStruD5E)
    oModel:GetModel("D5EMASTER"):SetDescription(FwX2Nome("D5E"))
    oModel:GetModel("D5EMASTER"):SetPrimaryKey({"D5E_FILIAL", "D5E_COD"})

Return oModel

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
    Definições da view
    @type Function
    @author Squad Entradas
    @since 25/03/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ViewDef()
    Local oView     := Nil
    Local oModel    := FWLoadModel("ESTA102")
    Local oStruD5E  := FWFormStruct(2, "D5E")
    
    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:CreateHorizontalBox("BOX_CABEC", 100)

    oView:AddField("VIEW_D5E", oStruD5E, "D5EMASTER")
    oView:SetOwnerView("VIEW_D5E", "BOX_CABEC")

Return oView
