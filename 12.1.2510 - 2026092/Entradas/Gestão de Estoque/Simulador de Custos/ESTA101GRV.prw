#INCLUDE "TOTVS.CH"
#INCLUDE "ESTA101.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101Grv
    Modelo secundário exclusivo para gravação (Commit) dos dados das grids
    @type Function
    @author Squad Entradas
    @since 15/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101Grv()
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definições do modelo
    @type Function
    @author Squad Entradas
    @since 15/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   := MPFormModel():New("ESTA101Grv",,,)
    Local oStruD5B := FWFormStruct(1, "D5B")

    oModel:SetDescription(STR0009) //"Simulacao"
    
    oModel:AddFields("D5BMASTER", /*cOwner*/, oStruD5B)
    oModel:SetPrimaryKey({})
    
Return oModel
