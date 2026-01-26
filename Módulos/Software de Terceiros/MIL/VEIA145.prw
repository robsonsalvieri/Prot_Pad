#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA145.CH'
#INCLUDE "FWBROWSE.CH"

Function VEIA145()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VJU')
oBrowse:SetDescription( STR0001 ) //'Relacionamento modelo JD X Protheus'
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA145')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVJU := FWFormStruct(1, "VJU")

// Valid dos campos
bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA145001F_ValidVjuCodMar()")
oStrVJU:SetProperty('VJU_CODMAR', MODEL_FIELD_VALID, bAuxValid)

bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA145002F_ValidVjuGrumod()")
oStrVJU:SetProperty('VJU_GRUMOD', MODEL_FIELD_VALID, bAuxValid)

bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA145003F_ValidVjuModvei()")
oStrVJU:SetProperty('VJU_MODVEI', MODEL_FIELD_VALID, bAuxValid)


// Inicializador padrão
bAuxRelacao := FWBuildFeature(STRUCT_FEATURE_INIPAD, 'iIf ( !INCLUI, Posicione("VE1", 1, xFilial("VE1") + VJU->VJU_CODMAR, "VE1_DESMAR"),"" )')
oStrVJU:SetProperty("VJU_DESMAR", MODEL_FIELD_INIT, bAuxRelacao)

bAuxRelacao := FWBuildFeature(STRUCT_FEATURE_INIPAD, 'iIf ( !INCLUI, Posicione("VVR", 2, xFilial("VVR") + VJU->VJU_CODMAR + VJU->VJU_GRUMOD, "VVR_DESCRI"), "")')
oStrVJU:SetProperty("VJU_DESGRU", MODEL_FIELD_INIT, bAuxRelacao)

bAuxRelacao := FWBuildFeature(STRUCT_FEATURE_INIPAD, 'iIf ( !INCLUI, Posicione("VV2", 6, xFilial("VV2") + VJU->VJU_MODVEI, "VV2_DESMOD"), "")')
oStrVJU:SetProperty("VJU_DESMOD", MODEL_FIELD_INIT, bAuxRelacao)


//Gatilhos
VA145004F_Trigger( oStrVJU, FwStruTrigger("VJU_CODMAR","VJU_DESMAR","VE1->VE1_DESMAR",.T.,"VE1",1,"xFilial('VE1') + FWFldGet('VJU_CODMAR')","!Empty(FWFldGet('VJU_CODMAR'))") )
VA145004F_Trigger( oStrVJU, FwStruTrigger("VJU_GRUMOD","VJU_DESGRU","VVR->VVR_DESCRI",.T.,"VVR",2,"xFilial('VVR') + FWFldGet('VJU_CODMAR') + FWFldGet('VJU_GRUMOD')","!Empty(FWFldGet('VJU_GRUMOD'))") )
VA145004F_Trigger( oStrVJU, FwStruTrigger("VJU_MODVEI","VJU_DESMOD","VV2->VV2_DESMOD",.T.,"VV2",4,"xFilial('VV2') + FWFldGet('VJU_MODVEI')","!Empty(FWFldGet('VJU_MODVEI'))") )

oModel := MPFormModel():New('VEIA145',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VJUMASTER',/*cOwner*/ , oStrVJU)
oModel:SetPrimaryKey( { "VJU_FILIAL", "VJU_CODIGO" } )
oModel:SetDescription( STR0001 )
oModel:GetModel('VJUMASTER'):SetDescription( STR0002 ) //'Dados do relacionamento modelo JD X Protheus'
oModel:InstallEvent("VEIA145EVF", /*cOwner*/, VEIA145EVF():New("VEIA145"))


// Relação dos campos
oModel:AddRules( 'VJUMASTER', 'VJU_GRUMOD', 'VJUMASTER', 'VJU_CODMAR', 3)
oModel:AddRules( 'VJUMASTER', 'VJU_MODVEI', 'VJUMASTER', 'VJU_CODMAR', 3)
oModel:AddRules( 'VJUMASTER', 'VJU_MODVEI', 'VJUMASTER', 'VJU_GRUMOD', 3)

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVJU:= FWFormStruct(2, "VJU")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'VJU', 100)
oView:AddField('VIEW_VJU', oStrVJU, 'VJUMASTER')
oView:EnableTitleView('VIEW_VJU', STR0001 )
oView:SetOwnerView('VIEW_VJU','VJU')

Return oView

/*/{Protheus.doc} VA145001F_ValidVjuCodmar
    Valid do campo VJU_CODMAR
   
    @author Daniel Apolinario
    @since 03/05/2024
/*/
Function VA145001F_ValidVjuCodMar()

    Local cCodMar := FWFldGet("VJU_CODMAR")

    VE1->(dbSetOrder(1))
    lRet := VE1->(msSeek(xFilial("VE1") + cCodMar))
    
return lRet

/*/{Protheus.doc} VA145002F_ValidVjuGrumod
    Valid do campo VJU_GRUMOD

    @author Daniel Apolinário
    @since 03/05/2024
/*/
Function VA145002F_ValidVjuGrumod()

    Local cGruMod := FWFldGet("VJU_GRUMOD")
    Local cCodMar := FWFldGet("VJU_CODMAR")

    VVR->(DBSetOrder(2))
    lRet := VVR->(msSeek(xFilial("VVR") + cCodMar + cGruMod))

Return lRet

/*/{Protheus.doc} VA145001F_ValidVjuModvei
    Valid do campo VJU_MODVEI
   
    @author Daniel Apolinario
    @since 30/04/2024
/*/
Function VA145003F_ValidVjuModvei()
    Local cQuery  := ""
    Local lRet    := .f.
    
    cQuery += "SELECT R_E_C_N_O_ "
    cQuery += "FROM " + RetSQLName("VV2") 
    cQuery += "    WHERE VV2_FILIAL = '" + xFilial("VV2") +" '"
    cQuery += "    AND D_E_L_E_T_ = ' ' "
    cQuery += "    AND VV2_CODMAR = '" + FWFldGet("VJU_CODMAR") + "' "  // Trocar por FWFldGet()
    cQuery += "    AND VV2_GRUMOD = '" + FWFldGet("VJU_GRUMOD") + "' "
    cQuery += "    AND VV2_MODVEI = '" + FWFldGet("VJU_MODVEI") + "' "

    If FM_SQL(cQuery) > 0
        lRet := .t.
    EndIf

return lRet

/*/{Protheus.doc} nomeFunction
    Trigger dos campos VJU_CODMAR, VJU_GRUMOD, VJU_MODVEI 

    @author Daniel Apolinario
    @since 30/04/2024
/*/
Function VA145004F_Trigger(oAuxStru, aAuxTrigger)
    oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return